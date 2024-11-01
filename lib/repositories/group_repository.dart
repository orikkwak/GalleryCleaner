import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupRepository {
  final NetworkHelper _networkHelper = NetworkHelper();

  // 서버에 그룹이 존재하는지 확인하는 메서드
  Future<bool> isGroupExistsOnServer(String uniqueID) async {
    if (await _networkHelper.isServerConnected()) {
      final url = Uri.parse('${_networkHelper.serverUrl}/groups/$uniqueID');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      }
    }
    return false;
  }

  // 서버에 그룹을 업로드하는 메서드
  Future<void> uploadGroupToServer(GroupModel group) async {
    if (await _networkHelper.isServerConnected()) {
      final url = Uri.parse('${_networkHelper.serverUrl}/groups');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(group.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to upload group: ${response.body}');
      }
    } else {
      print('Server not connected, cannot upload group.');
    }
  }
}
