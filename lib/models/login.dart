class Login {
  final bool loggedIn;
  final String userName;
  final String fullName;
  final String facilityId;
  final String facilityName;
  final String language;
  final String credit;

  Login({
    required this.loggedIn,
    required this.userName,
    required this.fullName,
    required this.facilityId,
    required this.facilityName,
    required this.language,
    required this.credit,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      loggedIn: json['loggedIn'],
      userName: json['userNm'],
      fullName: json['fullName'],
      facilityId: json['facId'],
      facilityName: json['facNm'],
      language: json['lang'],
      credit: json['credit'],
    );
  }
}