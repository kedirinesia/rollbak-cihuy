// @dart=2.9

class MetodePaymentModel {
  final String name;
  final String paymentMethod;
  final String paymentID;
  final String paymentCode;
  final String paymentImg;
  final String merchantRefId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final bool status;

  MetodePaymentModel({
    this.name,
    this.paymentMethod,
    this.paymentID,
    this.paymentCode,
    this.paymentImg,
    this.merchantRefId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.status,
  });

  factory MetodePaymentModel.fromJson(dynamic json) {
    return MetodePaymentModel(
      name: json['name'],
      paymentMethod: json['payment_method'],
      paymentID: json['payment_id'],
      paymentCode: json['payment_code'],
      paymentImg: json['payment_image_url'],
      merchantRefId: json['merchant_ref_id'],
      customerName: json['customer'] != null ? json['customer']['name'] : '-',
      customerPhone: json['customer'] != null ? json['customer']['phone'] : '-',
      customerEmail: json['customer'] != null ? json['customer']['email'] : '-',
      status: json['status'],
    );
  }
}
