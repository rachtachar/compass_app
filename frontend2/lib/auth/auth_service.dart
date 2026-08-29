class OidcUserSession {
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> idTokenClaims;
  final String rawIdToken;
  final String? accessToken;

  OidcUserSession({
    required this.userInfo,
    required this.idTokenClaims,
    required this.rawIdToken,
    this.accessToken,
  });
}

abstract class AuthService {
  Future<OidcUserSession?> checkExistingAuth(String issuerUrl, String clientId);
  Future<OidcUserSession?> login(String issuerUrl, String clientId);
}
