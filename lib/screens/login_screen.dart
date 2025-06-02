import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:project/services/auth_service.dart'; // Import AuthService
import 'package:project/utils/haptics.dart'; // Import Haptics

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // Optional: Define route name
  // static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false; // To show loading indicator on button press

  // Handle primary login button press
  Future<void> _handleLogin() async {
    if (_isLoading) return; // Prevent multiple clicks

    AppHaptics.mediumImpact();
    setState(() { _isLoading = true; });

    // Access AuthService - listen: false because we only call a method, not rebuild on change here
    final authService = Provider.of<AuthService>(context, listen: false);

    // Simulate login - In real app, pass controller text etc.
    await authService.login();

    // No need to manually navigate here, the listener in main.dart will handle it.
    // Just reset loading state if login fails (though our fake one always succeeds)
    // However, it's good practice to check mounted state after await
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // Placeholder for "Create" button
  void _handleCreate() {
    AppHaptics.lightImpact();
    print('Create button pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Implement Create Account Flow')),
    );
  }

  // Placeholder for "ITMO ID" button
  void _handleItmoLogin() {
    AppHaptics.lightImpact();
    print('ITMO ID login pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Implement ITMO ID Login')),
    );
  }

  // Placeholder for "Google" button
  void _handleGoogleLogin() {
    AppHaptics.lightImpact();
    print('Google login pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Implement Google Login')),
    );
  }


  @override
  void dispose() {
    _phoneController.dispose();
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
                const Text(
                  'Welcome back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black, // Adjust color if needed
                  ),
                ),
                const SizedBox(height: 48), // Spacing

                // Phone Input Field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Padding( // Use prefixIcon for "+7 "
                      padding: EdgeInsets.only(left: 15.0, right: 10.0, top: 12.0, bottom: 12.0),
                      child: Text('+7', style: TextStyle(fontSize: 16)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0), // Allow prefix icon to be smaller
                    hintText: '(999) 999 - 9999',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded border
                      borderSide: BorderSide(color: Colors.grey.shade400), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: theme.primaryColor), // Focused border color
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Create and Login Buttons Row
                Row(
                  children: [
                    // Create Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleCreate,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryButtonColor, // Text/Icon color
                          side: const BorderSide(color: primaryButtonColor), // Border color
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100), // Fully rounded
                          ),
                        ),
                        child: const Text('Create'),
                      ),
                    ),
                    const SizedBox(width: 16), // Spacing between buttons
                    // Login Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryButtonColor, // Button background
                          foregroundColor: Colors.white, // Text/Icon color
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100), // Fully rounded
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox( // Show loading indicator
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // "Or Login with" Separator
                Text(
                  'Or Login with',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Social/Other Login Buttons Row
                Row(
                  children: [
                    // ITMO ID Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner_sharp), // Placeholder icon
                        label: const Text('ITMO ID'),
                        onPressed: _handleItmoLogin,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87, // Text/Icon color
                          side: BorderSide(color: Colors.grey.shade400), // Border color
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Slightly rounded
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Google Login Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 10), // Adjust padding for logo
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Use an Asset Image or a package for the Google logo
                        child: Image.asset(
                          'assets/google_logo.png', // ** IMPORTANT: Add google_logo.png to your assets folder **
                          height: 24, // Adjust size as needed
                        ),
                        // Alternative using a simple Text 'G' if you don't have the logo asset
                        // child: Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                    ),
                  ],
                ),
                // SizedBox at bottom for potential extra spacing if needed
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}