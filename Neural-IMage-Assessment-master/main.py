"""
file - main.py
Main script to train the aesthetic model on the AVA dataset.

Copyright (C) Yunxiao Shi 2017 - 2021
NIMA is released under the MIT license. See LICENSE for the fill license text.
"""

import argparse #인자값 처리
import os #모듈 호출

import numpy as np
import matplotlib #차트/플롯 그리기
# matplotlib.use('Agg')
import matplotlib.pyplot as plt #그래프그리기

import torch
import torch.autograd as autograd
import torch.optim as optim

import torchvision.transforms as transforms
import torchvision.datasets as dsets
import torchvision.models as models

from torch.utils.tensorboard import SummaryWriter

from dataset.dataset import AVADataset

from model.model import *


def main(config):

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")  #장치선택, GPU 사용 확인 > 불가능 시 CPU사용
    writer = SummaryWriter()

    #텐서 변환 : 훈련 및 검증 이미지에 대한 전처리 단계 정의. 크기조정, 임의로 자르기, 수평 뒤집기, 텐서로 변환 및 정규화
    train_transform = transforms.Compose([
        transforms.Scale(256),
        transforms.RandomCrop(224),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(), 
        transforms.Normalize(mean=[0.485, 0.456, 0.406], 
            std=[0.229, 0.224, 0.225])])

    val_transform = transforms.Compose([
        transforms.Scale(256),
        transforms.RandomCrop(224),
        transforms.ToTensor(), 
        transforms.Normalize(mean=[0.485, 0.456, 0.406], 
            std=[0.229, 0.224, 0.225])])

    #모델 초기화: VGG16모델 불러옴. NIMA에 전달
    base_model = models.vgg16(pretrained=True)
    model = NIMA(base_model)

    #모델 로딩: 'config.warm_start' = 'Ture'면 사전 훈련된 모델의 가중치 체크 포인트 파일에서 로드
    if config.warm_start:
        model.load_state_dict(torch.load(os.path.join(config.ckpt_path, 'epoch-%d.pth' % config.warm_start_epoch)))
        print('Successfully loaded model epoch-%d.pth' % config.warm_start_epoch)

    if config.multi_gpu:
        model.features = torch.nn.DataParallel(model.features, device_ids=config.gpu_ids)
        model = model.to(device)
    else:
        model = model.to(device)

    conv_base_lr = config.conv_base_lr #특정레이어
    dense_lr = config.dense_lr #분류기 레이어
    #옵티마이저 설정: SGD옵티마이저 설정. 특성레이어와 분류기 레이어에 대해 다른 학습률 지정
    optimizer = optim.SGD([
        {'params': model.features.parameters(), 'lr': conv_base_lr},
        {'params': model.classifier.parameters(), 'lr': dense_lr}],
        momentum=0.9
        )

    param_num = 0
    for param in model.parameters():
        if param.requires_grad:
            param_num += param.numel()
    print('Trainable params: %.2f million' % (param_num / 1e6))

    if config.train:
        #데이터 로딩: 훈련 및 검증 데이터셋 로드. AVADataset사용. CSV파일에서 이미지 경로와 레이블 읽어옴. 앞서 정의한 변환 적용
        trainset = AVADataset(csv_file=config.train_csv_file, root_dir=config.img_path, transform=train_transform) # 훈련 데이터셋 생성
        valset = AVADataset(csv_file=config.val_csv_file, root_dir=config.img_path, transform=val_transform) # 검증 데이터셋 생성

        train_loader = torch.utils.data.DataLoader(trainset, batch_size=config.train_batch_size,
            shuffle=True, num_workers=config.num_workers) # 훈련 데이터셋에대한 데이터 로더 생성. 미니배치 단위로 데이터 로드, 데이터 섞고 병렬로 처리
        val_loader = torch.utils.data.DataLoader(valset, batch_size=config.val_batch_size,
            shuffle=False, num_workers=config.num_workers) # 검증 데이터셋에대한 데이터 로더 생성. 미니배치 단위로 데이터 로드, 데이터 섞지않고 평가
        # for early stopping
        count = 0 # 조기종료를 위한 카운터 초기화
        init_val_loss = float('inf') # 초기 검증 손실 무한대 설정
        train_losses = [] # 에폭에서의 훈련 저장 빈 리스트
        val_losses = [] # 에폭에서의 검증 손실을 저장할 빈 리스트

        for epoch in range(config.warm_start_epoch, config.epochs): #훈련루프
            batch_losses = []
            for i, data in enumerate(train_loader): #Forward pass, 손실계산, 역전파 및 최적화
                images = data['image'].to(device)
                labels = data['annotations'].to(device).float()
                outputs = model(images)
                outputs = outputs.view(-1, 10, 1)

                optimizer.zero_grad()

                loss = emd_loss(labels, outputs)
                batch_losses.append(loss.item())

                loss.backward()

                optimizer.step()

                print('Epoch: %d/%d | Step: %d/%d | Training EMD loss: %.4f' % (epoch + 1, config.epochs, i + 1, len(trainset) // config.train_batch_size + 1, loss.data[0]))
                writer.add_scalar('batch train loss', loss.data[0], i + epoch * (len(trainset) // config.train_batch_size + 1))

            avg_loss = sum(batch_losses) / (len(trainset) // config.train_batch_size + 1)
            train_losses.append(avg_loss)
            print('Epoch %d mean training EMD loss: %.4f' % (epoch + 1, avg_loss))

            # exponetial learning rate decay 기하급수적 학습률 감소
            if config.decay:
                if (epoch + 1) % 10 == 0:
                    conv_base_lr = conv_base_lr * config.lr_decay_rate ** ((epoch + 1) / config.lr_decay_freq)
                    dense_lr = dense_lr * config.lr_decay_rate ** ((epoch + 1) / config.lr_decay_freq)
                    optimizer = optim.SGD([
                        {'params': model.features.parameters(), 'lr': conv_base_lr},
                        {'params': model.classifier.parameters(), 'lr': dense_lr}],
                        momentum=0.9
                    )

            # do validation after each epoch 훈련 주기 끝난 후 검증 수행
            batch_val_losses = []
            for data in val_loader: #Forward pass 및 검증 손실 계산
                images = data['image'].to(device)
                labels = data['annotations'].to(device).float()
                with torch.no_grad():
                    outputs = model(images)
                outputs = outputs.view(-1, 10, 1)
                val_loss = emd_loss(labels, outputs)
                batch_val_losses.append(val_loss.item())
            avg_val_loss = sum(batch_val_losses) / (len(valset) // config.val_batch_size + 1)
            val_losses.append(avg_val_loss)
            print('Epoch %d completed. Mean EMD loss on val set: %.4f.' % (epoch + 1, avg_val_loss))
            writer.add_scalars('epoch losses', {'epoch train loss': avg_loss, 'epoch val loss': avg_val_loss}, epoch + 1)

            # 조기종료 : 검증 손실을 모니터링하고, 일정한 에폭동안 검증 손실이 개선되지 않으면 훈련 조기종료
            # Use early stopping to monitor training
            if avg_val_loss < init_val_loss:
                init_val_loss = avg_val_loss
                # save model weights if val loss decreases
                print('Saving model...')
                if not os.path.exists(config.ckpt_path):
                    os.makedirs(config.ckpt_path)
                torch.save(model.state_dict(), os.path.join(config.ckpt_path, 'epoch-%d.pth' % (epoch + 1)))
                print('Done.\n')
                # reset count
                count = 0
            elif avg_val_loss >= init_val_loss:
                count += 1
                if count == config.early_stopping_patience:
                    print('Val EMD loss has not decreased in %d epochs. Training terminated.' % config.early_stopping_patience)
                    break

        print('Training completed.')

        '''
        # use tensorboard to log statistics instead
        if config.save_fig:
            # plot train and val loss
            epochs = range(1, epoch + 2)
            plt.plot(epochs, train_losses, 'b-', label='train loss')
            plt.plot(epochs, val_losses, 'g-', label='val loss')
            plt.title('EMD loss')
            plt.legend()
            plt.savefig('./loss.png')
        '''

    # 테스트 : 테스트 데이터셋을 사용해 훈련된 모델 평가
    if config.test: # config에 따라 테스트 수행 여부 확인. True = 실행
        model.eval() # 모델을 평가모드로 설정, 일부 층들이 활성화 되지 않도록
        # compute mean score
        test_transform = val_transform # 테스트 데이터 = 검증 데이터로 초기화
        testset = AVADataset(csv_file=config.test_csv_file, root_dir=config.img_path, transform=val_transform) # 테스트 데이터 로드 > 변환
        test_loader = torch.utils.data.DataLoader(testset, batch_size=config.test_batch_size, shuffle=False, num_workers=config.num_workers) # 작게 데이터 로더 생성. config에서 배치크기, 워커수 등 가져옴

        mean_preds = [] # 예측된 평균 저장 빈 리스트 생성
        std_preds = [] # 예측된 표준편차 저장 빈 리스트 생성
        for data in test_loader: # 미니배치 테스트에 반복시키기
            image = data['image'].to(device) # 이미지 cpu에 올림. 디바이스 config에서 가져옴
            output = model(image) # 모델에 이미지 전달, 예측
            output = output.view(10, 1) # 모델 출력(10, 1)로 변경
            predicted_mean, predicted_std = 0.0, 0.0 # 예측된 평균, 표준편차 초기화
            for i, elem in enumerate(output, 1): # 반복하면서 평균 계산
                predicted_mean += i * elem
            for j, elem in enumerate(output, 1):# 반복하면서 표준편차 계산
                predicted_std += elem * (j - predicted_mean) ** 2
            predicted_std = predicted_std ** 0.5
            mean_preds.append(predicted_mean) #예측된 평균값 리스트에 추가
            std_preds.append(predicted_std)#예측된 표준편차값 리스트에 추가
        # Do what you want with predicted and std...


if __name__ == '__main__': #스크립트 직접 실행될 때 실행되는 부분

    parser = argparse.ArgumentParser() #명령행 인자 피싱을 위한 객체 생성

    # input parameters 입력 매개변수에 대한 설정: 이미지경로, 훈련, 검증, 테스트에 사용될 csv파일 경로 설정
    parser.add_argument('--img_path', type=str, default='./data/images')
    parser.add_argument('--train_csv_file', type=str, default='./data/train_labels.csv')
    parser.add_argument('--val_csv_file', type=str, default='./data/val_labels.csv')
    parser.add_argument('--test_csv_file', type=str, default='./data/test_labels.csv')

    # training parameters 훈련 매개변수에 대한 설정 : 
    parser.add_argument('--train',action='store_true') # 각각 훈련을 사용할지 여부 설정
    parser.add_argument('--test', action='store_true') # 각각 테스트를 사용할지 여부 설정
    parser.add_argument('--decay', action='store_true') # 각각 학습률 감소를 사용할지 여부 설정
    parser.add_argument('--conv_base_lr', type=float, default=5e-3) # 특성 레이어에 대한 학습률을 설정
    parser.add_argument('--dense_lr', type=float, default=5e-4) # 분류기 레이어에 대한 학습률을 설정
    parser.add_argument('--lr_decay_rate', type=float, default=0.95) # 학습률 감소의 속도 설정
    parser.add_argument('--lr_decay_freq', type=int, default=10) # 학습률 빈도 설정
    parser.add_argument('--train_batch_size', type=int, default=128) # 훈련 크기 설정
    parser.add_argument('--val_batch_size', type=int, default=128) # 검증 크기 설정
    parser.add_argument('--test_batch_size', type=int, default=1) # 테스트 배치 크기 설정
    parser.add_argument('--num_workers', type=int, default=2) # 데이터 로더에 사용할 워커 수 설정
    parser.add_argument('--epochs', type=int, default=100) # 총 에폭 수 설정

    # misc
    parser.add_argument('--ckpt_path', type=str, default='./ckpts') # 체크포인트 파일 저장경로 설정
    parser.add_argument('--multi_gpu', action='store_true') # 여러 gpu 사용 여부 설정
    parser.add_argument('--gpu_ids', type=list, default=None) # 사용할 gpu id 설정
    parser.add_argument('--warm_start', action='store_true') # 사전 훈련된 모델의 가중치 로드 설정
    parser.add_argument('--warm_start_epoch', type=int, default=0) # 에폭 설정
    parser.add_argument('--early_stopping_patience', type=int, default=10) # 조기종료를 위한 기다리는 에폭 수 설정
    parser.add_argument('--save_fig', action='store_true') # 그래프 저장여부 설정

    config = parser.parse_args() # 설정 파싱해 config객체에 저장

    main(config) # main 함수 호출 훈련 평가 실행