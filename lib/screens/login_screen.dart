import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:project/services/auth_service.dart'; // Import AuthService
import 'package:project/utils/haptics.dart'; // Import Haptics
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // Optional: Define route name
  // static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    AppHaptics.mediumImpact();
    setState(() { _isLoading = true; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    AppHaptics.mediumImpact();
    setState(() { _isLoading = true; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;

    AppHaptics.mediumImpact();
    setState(() { _isLoading = true; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Use theme for styling

    // Define the primary button color from the image (adjust as needed)
    const primaryButtonColor = Color(0xFF6750A4); // Example purple color

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme background
      // Optional: Remove AppBar if not needed on login screen
      // appBar: AppBar(title: Text('Login')),
      body: SafeArea( // Ensure content avoids status bar etc.
        child: Center( // Center the content vertically
          child: SingleChildScrollView( // Allow scrolling on small screens
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center column content
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
              children: <Widget>[
                // Welcome Text
                Text(
                  _isRegistering ? 'Create Account' : 'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48), // Spacing

                // Email Input Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login/Register Button
                ElevatedButton(
                  onPressed: _isRegistering ? _handleRegister : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isRegistering ? 'Register' : 'Login'),
                ),
                const SizedBox(height: 16),

                // Toggle Register/Login
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isRegistering ? 'Already have an account? Login' : 'Don\'t have an account? Register',
                    style: TextStyle(color: primaryButtonColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider with "or" text
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In Button
                OutlinedButton(
                  onPressed: _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/google_logo.svg',
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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