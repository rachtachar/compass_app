import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CompassJwtApp());
}

class CompassJwtApp extends StatelessWidget {
  const CompassJwtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compass JWT Auth • Frontend 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFFD97706),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _accessToken;
  String? _refreshToken;
  String _baseUrl = 'http://localhost:8000';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStoredTokens();
  }

  Future<void> _loadStoredTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      _baseUrl = prefs.getString('base_url') ?? 'http://localhost:8000';
      _loading = false;
    });
  }

  Future<void> _onLoggedIn(String access, String refresh, String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
    await prefs.setString('base_url', baseUrl);
    setState(() {
      _accessToken = access;
      _refreshToken = refresh;
      _baseUrl = baseUrl;
    });
  }

  Future<void> _onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    setState(() {
      _accessToken = null;
      _refreshToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_accessToken != null) {
      return DashboardScreen(
        accessToken: _accessToken!,
        refreshToken: _refreshToken ?? '',
        baseUrl: _baseUrl,
        onLogout: _onLogout,
        onTokenRefreshed: (newAccess) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', newAccess);
          setState(() {
            _accessToken = newAccess;
          });
        },
      );
    }

    return LoginScreen(
      initialBaseUrl: _baseUrl,
      onLoginSuccess: _onLoggedIn,
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String initialBaseUrl;
  final Function(String access, String refresh, String baseUrl) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.initialBaseUrl,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _baseUrlCtrl;
  final _usernameCtrl = TextEditingController(text: 'student01');
  final _passwordCtrl = TextEditingController(text: 'test1234');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _baseUrlCtrl = TextEditingController(text: widget.initialBaseUrl);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final baseUrl = _baseUrlCtrl.text.trim().replaceAll(RegExp(r'/$'), '');
    final url = Uri.parse('$baseUrl/api/token/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final access = data['access'] as String;
        final refresh = data['refresh'] as String;
        widget.onLoginSuccess(access, refresh, baseUrl);
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['detail'] ?? 'Login failed (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e\nMake sure backend1 is running on $baseUrl';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & Header
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          size: 36,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Compass Travel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        'JWT Stateless Authentication (DRF)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 24),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Backend URL Field
                      TextFormField(
                        controller: _baseUrlCtrl,
                        decoration: InputDecoration(
                          labelText: 'Backend Base URL',
                          prefixIcon: const Icon(Icons.dns_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter backend URL' : null,
                      ),
                      const SizedBox(height: 14),

                      // Username Field
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter username' : null,
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter password' : null,
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Sign In via JWT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Text(
                          '💡 Test user: student01 / test1234\n🔑 SimpleJWT: POST /api/token/',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String accessToken;
  final String refreshToken;
  final String baseUrl;
  final VoidCallback onLogout;
  final Function(String newAccess) onTokenRefreshed;

  const DashboardScreen({
    super.key,
    required this.accessToken,
    required this.refreshToken,
    required this.baseUrl,
    required this.onLogout,
    required this.onTokenRefreshed,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _bookings = [];
  bool _loadingBookings = true;
  String? _bookingsError;
  bool _refreshingToken = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {'error': 'Invalid JWT format'};
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload);
    } catch (e) {
      return {'error': 'Failed to decode: $e'};
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _loadingBookings = true;
      _bookingsError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/api/bookings/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _bookings = data['bookings'] ?? [];
          _loadingBookings = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _bookingsError = 'Access token expired or unauthorized (401). Try clicking "Refresh Token".';
          _loadingBookings = false;
        });
      } else {
        setState(() {
          _bookingsError = 'Error ${response.statusCode}: ${response.body}';
          _loadingBookings = false;
        });
      }
    } catch (e) {
      setState(() {
        _bookingsError = 'Failed to load bookings: $e';
        _loadingBookings = false;
      });
    }
  }

  Future<void> _refreshToken() async {
    setState(() {
      _refreshingToken = true;
      _statusMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': widget.refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'] as String;
        widget.onTokenRefreshed(newAccess);
        setState(() {
          _statusMessage = '✅ Access token successfully refreshed!';
        });
        _fetchBookings();
      } else {
        setState(() {
          _statusMessage = '❌ Failed to refresh token: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error refreshing token: $e';
      });
    } finally {
      setState(() => _refreshingToken = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final claims = _decodeJwt(widget.accessToken);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text('Compass Travel • Protected Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Data',
            onPressed: _fetchBookings,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Banner
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: const Color(0xFF0F766E),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.account_circle, size: 40, color: Colors.white),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${claims['username'] ?? 'User'}!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                claims['email'] != null && claims['email'].toString().isNotEmpty
                                    ? claims['email']
                                    : 'Authenticated via DRF SimpleJWT',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _refreshingToken ? null : _refreshToken,
                          icon: _refreshingToken
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.autorenew_rounded),
                          label: const Text('Refresh Token'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDE68A),
                            foregroundColor: const Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_statusMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_statusMessage!, style: const TextStyle(fontSize: 13, color: Color(0xFF065F46))),
                  ),
                  const SizedBox(height: 16),
                ],

                // Protected Bookings Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.flight_takeoff_rounded, color: Color(0xFF0F766E)),
                                SizedBox(width: 8),
                                Text(
                                  'Protected Bookings (/api/bookings/)',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_bookings.length} Items',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        if (_loadingBookings)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_bookingsError != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _bookingsError!,
                              style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                            ),
                          )
                        else if (_bookings.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('No bookings found.'),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _bookings.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _bookings[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.1),
                                  child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF0F766E))),
                                ),
                                title: Text(
                                  item['destination_name'] ?? 'Trip',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Start: ${item['start_date'] ?? 'N/A'} • End: ${item['end_date'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  '฿${item['price'] ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // JWT Token Inspector Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Color(0xFFD97706)),
                            SizedBox(width: 8),
                            Text(
                              'JWT Token Claims Inspector (Stateless)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            const JsonEncoder.withIndent('  ').convert(claims),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
