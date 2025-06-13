// @dart=2.9
import 'package:rxdart/rxdart.dart';

class ApiBloc extends Object {
  final sigVendor = BehaviorSubject<String>();
  final apiUrl = BehaviorSubject<String>();
  final apiUrlKasir = BehaviorSubject<String>();

  void dispose() {
    sigVendor.close();
    apiUrl.close();
    apiUrlKasir.close();
  }
}

final apiBloc = ApiBloc();

String apiUrl = apiBloc.apiUrl.value ?? 'https://milea.flutters.dev/api/v1';
String apiUrlKasir = apiBloc.apiUrlKasir.value;
String sigVendor = apiBloc.sigVendor.value;
