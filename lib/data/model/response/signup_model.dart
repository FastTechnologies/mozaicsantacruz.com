class SignUpModel {
  String fName;
  String lName;
  String phone;
  String email;
  String password;
  int restaurantId;
  String referralCode;


  SignUpModel({this.fName, this.lName, this.phone, this.email='', this.password,this.restaurantId,this.referralCode});

  SignUpModel.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    password = json['password'];
    restaurantId = json['restaurant_id'];
    referralCode = json['referral_code'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['f_name'] = this.fName;
    data['l_name'] = this.lName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['password'] = this.password;
    data['restaurant_id'] = this.restaurantId;
    data['referral_code'] = this.referralCode;


    return data;
  }
}
