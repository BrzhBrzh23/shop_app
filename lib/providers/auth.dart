import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/error/exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/helpers/config.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  
  Timer? _authTimer;

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_expiryDate != null && _expiryDate!.isAfter(DateTime.now())) {
      return _token!;
    } else {
      return '';
    }
  }

  String get userId {
    return _userId.toString();
  }

  Future authentificate(
      String? email, String? password, String? urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$APIkey');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpsException(responseData['error']['message']);
      } else {
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expiryDate = DateTime.now().add(
          Duration(
              seconds: int.parse(
            responseData['expiresIn'],
          )),
        );
        autoLogOut();
        notifyListeners();

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        });
        prefs.setString('userData', userData);
      }
      print(json.decode(response.body));
    } catch (e) {
      throw e;
    }
  }

  Future signUp(String email, String password) async {
    return authentificate(email, password, 'signUp');
  }

  Future logIn(String email, String password) async {
    return authentificate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json
        .decode(prefs.getString('userData').toString()) as Map<String, dynamic>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
