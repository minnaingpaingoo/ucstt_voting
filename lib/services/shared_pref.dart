import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{
  static String userIdKey ="USERKEY";
  static String userNameKey ="USERNAMEKEY";
  static String userEmailKey ="USEREMAILKEY";
  static String userClassNameKey ="USERCLASSNAMEKEY";

  Future<bool> saveUserId(String getUserId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserName(String getUserName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserClassName(String getUserClassName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userClassNameKey, getUserClassName);
  }

  Future<String?> getUserId() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserName() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserEmail() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserClassName() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userClassNameKey);
  }

  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreferenceHelper.userIdKey);
    await prefs.remove(SharedPreferenceHelper.userNameKey);
    await prefs.remove(SharedPreferenceHelper.userEmailKey);
    await prefs.remove(SharedPreferenceHelper.userClassNameKey);
  }

}