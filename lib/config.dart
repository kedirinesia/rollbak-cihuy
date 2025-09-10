// @dart=2.9

import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/utils/debug_helper.dart';

String appName = configAppBloc.namaApp.valueWrapper?.value;
String packageName = configAppBloc.packagename.valueWrapper?.value;
String prefixUrlInvite = "https://payuni.page.link/";
