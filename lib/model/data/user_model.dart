
class UserModel {
  final String displayName;      // Your name
  final String privateIdentity;  // Ramal SIP (ex: 7001)
  final String password;         // Ramal password

  UserModel({
    required this.displayName,
    required this.privateIdentity,
    required this.password,
  });
}
