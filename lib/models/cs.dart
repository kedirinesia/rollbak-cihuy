// @dart=2.9

class CustomerService {
  String title;
  String icon;
  String contact;
  String link;

  CustomerService({this.title, this.icon, this.contact, this.link});

  factory CustomerService.fromJson(dynamic json) {
    return CustomerService(
        title: json['title'],
        icon: json['icon'],
        contact: json['contact'],
        link: json['link']);
  }
}
