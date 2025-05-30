
class UserModel {
  final String displayName;      // Nome visível no app
  final String privateIdentity;  // Ramal SIP (ex: 7001)
  final String password;         // Senha do ramal

  UserModel({
    required this.displayName,
    required this.privateIdentity,
    required this.password,
  });
}
