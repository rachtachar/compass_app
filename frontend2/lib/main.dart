import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth/auth_service.dart';
import 'auth/auth_service_export.dart';

void main() {
  runApp(const CompassOidcApp());
}

class CompassOidcApp extends StatelessWidget {
  const CompassOidcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compass OIDC Client • Frontend 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF059669),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const OidcHomeScreen(),
    );
  }
}

class OidcHomeScreen extends StatefulWidget {
  const OidcHomeScreen({super.key});

  @override
  State<OidcHomeScreen> createState() => _OidcHomeScreenState();
}

class _OidcHomeScreenState extends State<OidcHomeScreen> {
  final AuthService _authService = getAuthService();
  String _issuerUrl = 'http://localhost:8000';
  String _clientId = 'flutter-web-client-12345';
  bool _loading = false;
  String? _statusMessage;
  String? _errorMessage;

  // Authenticated user state
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _idTokenClaims;
  String? _rawIdToken;
  Map<String, dynamic>? _discoveryDoc;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
    _fetchDiscoveryDoc();
  }

  Future<void> _fetchDiscoveryDoc() async {
    try {
      final res = await http.get(Uri.parse('$_issuerUrl/.well-known/openid-configuration'));
      if (res.statusCode == 200) {
        setState(() {
          _discoveryDoc = jsonDecode(res.body);
        });
      }
    } catch (_) {
      // Discovery not reachable yet
    }
  }

  Future<void> _checkExistingAuth() async {
    try {
      setState(() => _loading = true);
      final session = await _authService.checkExistingAuth(_issuerUrl, _clientId);
      if (session != null) {
        setState(() {
          _isAuthenticated = true;
          _userInfo = session.userInfo;
          _idTokenClaims = session.idTokenClaims;
          _rawIdToken = session.rawIdToken;
          _statusMessage = 'Successfully authenticated with OIDC Provider!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'OIDC check error: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithOidc() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final session = await _authService.login(_issuerUrl, _clientId);
      if (session != null) {
        setState(() {
          _isAuthenticated = true;
          _userInfo = session.userInfo;
          _idTokenClaims = session.idTokenClaims;
          _rawIdToken = session.rawIdToken;
          _statusMessage = 'Successfully signed in with OIDC!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to OpenID Provider: $e\nEnsure backend2 is running at $_issuerUrl';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
      _userInfo = null;
      _idTokenClaims = null;
      _rawIdToken = null;
      _statusMessage = 'Logged out successfully.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Compass OIDC • Frontend 2',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: _logout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Banner Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'OAuth 2.0 + OpenID Connect (OIDC)',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Decentralized Identity Provider (OP)',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Connects to Django django-oidc-provider server using Authorization Code Flow + PKCE with RS256 Cryptographic Signatures.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status / Error Messages
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade900, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_statusMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_statusMessage!, style: TextStyle(color: Colors.green.shade900, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Main Content: Login or User Details
                if (!_isAuthenticated) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'OpenID Client Configuration',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _issuerUrl,
                            onChanged: (v) => _issuerUrl = v.trim(),
                            decoration: InputDecoration(
                              labelText: 'Issuer URL (OP)',
                              hintText: 'http://localhost:8000',
                              prefixIcon: const Icon(Icons.cloud_queue_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            initialValue: _clientId,
                            onChanged: (v) => _clientId = v.trim(),
                            decoration: InputDecoration(
                              labelText: 'Client ID',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loading ? null : _loginWithOidc,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: const Text(
                              'Sign in with OIDC (django-oidc-provider)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFC7D2FE)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ℹ️ How OIDC Flow works:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3730A3))),
                                SizedBox(height: 4),
                                Text('1. Discovers endpoints from /.well-known/openid-configuration', style: TextStyle(fontSize: 12, color: Color(0xFF4338CA))),
                                Text('2. Opens Django login page (localhost:8000/admin/login/)', style: TextStyle(fontSize: 12, color: Color(0xFF4338CA))),
                                Text('3. Enter student01 / test1234', style: TextStyle(fontSize: 12, color: Color(0xFF4338CA))),
                                Text('4. Redirects back to localhost:50000 with Auth Code & retrieves ID Token', style: TextStyle(fontSize: 12, color: Color(0xFF4338CA))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // User Profile & ID Token Claims
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0xFF4F46E5),
                                child: Icon(Icons.person, color: Colors.white, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userInfo?['name'] ?? _userInfo?['preferred_username'] ?? 'OIDC User',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _userInfo?['email'] ?? 'No email provided',
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '✓ OIDC Verified',
                                  style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          const Text('User Info (getUserInfo())', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(_userInfo),
                              style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF4ADE80), fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('ID Token Claims (RS256 Decoded)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(_idTokenClaims),
                              style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF38BDF8), fontSize: 12),
                            ),
                          ),
                          if (_rawIdToken != null) ...[
                            const SizedBox(height: 20),
                            const Text('Raw ID Token (Paste to jwt.io)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                _rawIdToken!,
                                style: const TextStyle(fontFamily: 'monospace', color: Color(0xFFFBBF24), fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Discovery Document Inspector
                if (_discoveryDoc != null) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      leading: const Icon(Icons.explore_outlined, color: Color(0xFF4F46E5)),
                      title: const Text(
                        'OIDC Discovery Document (/.well-known/openid-configuration)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(_discoveryDoc),
                              style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF93C5FD), fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
