class User {
  final String phone;
  final String? iin;
  final String? name;
  final String? surname;
  final String? patronymic;
  final String token;

  User({
    required this.phone,
    this.iin,
    this.name,
    this.surname,
    this.patronymic,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phone: json['phone'] ?? '',
      iin: json['iin'],
      name: json['name'],
      surname: json['surname'],
      patronymic: json['patronymic'],
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'iin': iin,
      'name': name,
      'surname': surname,
      'patronymic': patronymic,
      'token': token,
    };
  }
}
