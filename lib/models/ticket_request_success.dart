class TicketSuccessResponse {
  String? sId;
  String? event;
  String? ticketType;
  String? couponCode;
  int? quantity;
  int? squadLimit;
  Customer? customer;
  Payment? payment;
  String? createdAt;
  String? updatedAt;
  String? qrCodeBase64;
  int? iV;
  bool? checkedIn;

  TicketSuccessResponse({
    this.sId,
    this.event,
    this.ticketType,
    this.couponCode,
    this.quantity,
    this.squadLimit,
    this.customer,
    this.payment,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.checkedIn,
    qrCodeBase64,
  });

  TicketSuccessResponse.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    event = json['event'];
    ticketType = json['ticketType'];
    couponCode = json['couponCode'];
    quantity = json['quantity'];
    squadLimit = json['squadLimit'];
    qrCodeBase64 = json['qrCodeBase64'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    payment =
        json['payment'] != null ? Payment.fromJson(json['payment']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    checkedIn = json['checkedIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['event'] = event;
    data['ticketType'] = ticketType;
    data['couponCode'] = couponCode;
    data['quantity'] = quantity;
    data['squadLimit'] = squadLimit;
    data['qrCodeBase64'] = qrCodeBase64;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['checkedIn'] = checkedIn;
    return data;
  }
}

class Customer {
  String? name;
  String? email;
  String? phone;

  Customer({this.name, this.email, this.phone});

  Customer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}

class Payment {
  int? amount;
  String? method;
  String? currency;
  String? status;
  String? reference;

  Payment(
      {this.amount, this.method, this.currency, this.status, this.reference});

  Payment.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    method = json['method'];
    currency = json['currency'];
    status = json['status'];
    reference = json['reference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['method'] = method;
    data['currency'] = currency;
    data['status'] = status;
    data['reference'] = reference;
    return data;
  }
}
