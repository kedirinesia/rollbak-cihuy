
class CustomerService {
  String title;
  String icon;
  String contact;
  String link;

  CustomerService({required this.title, required this.icon, required this.contact, required this.link});

  factory CustomerService.fromJson(dynamic json) {
    return CustomerService(
        title: json['title'],
        icon: json['icon'],
        contact: json['contact'],
        link: json['link']);
  }
}
