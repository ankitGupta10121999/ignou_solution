class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? name;
  final String? phone;
  final String? address;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pincode;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.address,
    this.landmark,
    this.city,
    this.state,
    this.pincode,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      landmark: data['landmark'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      pincode: data['pincode'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
