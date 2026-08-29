import 'auth_service.dart';

class AuthServiceImplementation implements AuthService {
  @override
  Future<OidcUserSession?> checkExistingAuth(String issuerUrl, String clientId) async {
    return null;
  }

  @override
  Future<OidcUserSession?> login(String issuerUrl, String clientId) async {
    // Mock simulation for non-web / VM test environments
    await Future.delayed(const Duration(milliseconds: 300));
    return OidcUserSession(
      userInfo: {
        'sub': '1',
        'name': 'Student One',
        'email': 'student01@university.ac.th',
        'preferred_username': 'student01',
      },
      idTokenClaims: {
        'iss': issuerUrl,
        'sub': '1',
        'aud': clientId,
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'name': 'Student One',
        'email': 'student01@university.ac.th',
      },
      rawIdToken: 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAiLCJzdWIiOiIxIn0...',
      accessToken: 'sample_access_token_oidc',
    );
  }
}

AuthService getAuthService() => AuthServiceImplementation();
