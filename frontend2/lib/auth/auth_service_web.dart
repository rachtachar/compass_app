import 'package:openid_client/openid_client.dart' as oidc;
import 'package:openid_client/openid_client_browser.dart' as oidc_browser;
import 'auth_service.dart';

class AuthServiceImplementation implements AuthService {
  @override
  Future<OidcUserSession?> checkExistingAuth(String issuerUrl, String clientId) async {
    try {
      final issuer = await oidc.Issuer.discover(Uri.parse(issuerUrl));
      final client = oidc.Client(issuer, clientId);
      final authenticator = oidc_browser.Authenticator(
        client,
        scopes: ['openid', 'profile', 'email'],
      );

      final c = await authenticator.credential;
      if (c != null) {
        final info = await c.getUserInfo();
        final tokenResponse = await c.getTokenResponse();
        final idToken = tokenResponse.idToken;

        return OidcUserSession(
          userInfo: {
            'sub': info.subject,
            'name': info.name,
            'email': info.email,
            'preferred_username': info.preferredUsername,
            'given_name': info.givenName,
            'family_name': info.familyName,
          },
          idTokenClaims: idToken.claims.toJson(),
          rawIdToken: idToken.toCompactSerialization(),
          accessToken: tokenResponse.accessToken,
        );
      }
    } catch (_) {
      // Not authenticated or error
    }
    return null;
  }

  @override
  Future<OidcUserSession?> login(String issuerUrl, String clientId) async {
    final issuer = await oidc.Issuer.discover(Uri.parse(issuerUrl));
    final client = oidc.Client(issuer, clientId);
    final authenticator = oidc_browser.Authenticator(
      client,
      scopes: ['openid', 'profile', 'email'],
    );

    final c = await authenticator.credential;
    if (c == null) {
      authenticator.authorize();
      return null;
    } else {
      final info = await c.getUserInfo();
      final tokenResponse = await c.getTokenResponse();
      final idToken = tokenResponse.idToken;

      return OidcUserSession(
        userInfo: {
          'sub': info.subject,
          'name': info.name,
          'email': info.email,
          'preferred_username': info.preferredUsername,
          'given_name': info.givenName,
          'family_name': info.familyName,
        },
        idTokenClaims: idToken.claims.toJson(),
        rawIdToken: idToken.toCompactSerialization(),
        accessToken: tokenResponse.accessToken,
      );
    }
  }
}

AuthService getAuthService() => AuthServiceImplementation();
