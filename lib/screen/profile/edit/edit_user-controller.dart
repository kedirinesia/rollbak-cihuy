import 'package:flutter/material.dart';
import 'package:mobile/screen/profile/edit/edit_user.dart';

abstract class EditUserController extends State<EditUser> with TickerProviderStateMixin {
  TextEditingController nama = TextEditingController();
  TextEditingController namaMerchant = TextEditingController();
  TextEditingController alamat = TextEditingController();
}