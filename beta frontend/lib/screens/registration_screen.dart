import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import 'main_navigation_screen.dart';
import '../core/auth/auth_controller.dart';
import '../features/auth/data/auth_repository.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _loading = false;
  final AuthRepository _authRepo = AuthRepository();
  String _selectedRole = 'CONSUMER';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding =
        (size.width * 0.08).clamp(16.0, 32.0); // responsive padding
    final titleFontSize = (size.width * 0.08).clamp(24.0, 34.0);
    final subtitleFontSize = (size.width * 0.04).clamp(14.0, 18.0);
    final spacingLarge = (size.height * 0.05).clamp(32.0, 48.0);
    final spacingMedium = (size.height * 0.025).clamp(16.0, 28.0);
    final spacingSmall = (size.height * 0.015).clamp(10.0, 18.0);
    final buttonHeight = (size.height * 0.065).clamp(48.0, 60.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacingLarge),
              // Title
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: spacingSmall),
              // Subtitle
              Text(
                'by creating a free account.',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: spacingLarge * 0.8),
              // Full name field
              _buildTextField(
                controller: _nameController,
                hintText: 'Full name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: spacingMedium * 0.6),
              // Email field
              _buildTextField(
                controller: _emailController,
                hintText: 'Valid email',
                icon: Icons.email_outlined,
              ),
              SizedBox(height: spacingMedium * 0.6),
              // Phone number field
              _buildTextField(
                controller: _phoneController,
                hintText: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: spacingMedium * 0.6),
              // Password field
              _buildPasswordField(
                controller: _passwordController,
                hintText: 'Strong Password',
                icon: Icons.lock_outline,
              ),
              SizedBox(height: spacingMedium * 0.6),
              // Role selection
              _buildRoleSelector(),
              SizedBox(height: spacingSmall),
              // Terms and conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFE53E3E),
                    checkColor: Colors.white,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          children: [
                            const TextSpan(text: 'By checking the box you agree to our '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: const TextStyle(
                                color: Color(0xFFE53E3E),
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle Terms and Conditions navigation
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacingMedium),
              // Continue with Google button
              _buildGoogleButton(buttonHeight),
              SizedBox(height: spacingMedium * 0.8),
              // Next button
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          if (name.isEmpty || email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill name, email, and password'),
                                backgroundColor: Color(0xFFE53E3E),
                              ),
                            );
                            return;
                          }
                          if (!_agreeToTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please accept Terms & Conditions'),
                                backgroundColor: Color(0xFFE53E3E),
                              ),
                            );
                            return;
                          }
                          setState(() => _loading = true);
                          try {
                            // Signup and get user
                            final user = await _authRepo.signup(
                              name: name,
                              email: email,
                              password: password,
                              role: _selectedRole,
                            );
                            
                            // Update AuthController with user
                            if (mounted) {
                              final authController = Provider.of<AuthController>(context, listen: false);
                              authController.setUser(user);
                              
                              // Also refresh user from backend to get full profile (phone, etc.)
                              try {
                                await authController.refreshUser();
                              } catch (e) {
                                // If refresh fails, still use the user from signup
                                debugPrint('Failed to refresh user after signup: $e');
                              }
                            }
                            
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => MainNavigationScreen(initialIndex: 0)),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sign up failed: ${e.toString()}'),
                                backgroundColor: const Color(0xFFE53E3E),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_loading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else ...[
                        const Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacingMedium),
              // Login link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(text: 'Already a member? '),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: Color(0xFFE53E3E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacingSmall * 1.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: Icon(icon, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(double height) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: () {
          // Handle Google sign in - navigate directly to main app or OTP
          // For now, navigate to main app (you can change this to OTP if needed)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigationScreen(
                initialIndex: 0,
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am registering as',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleOptionTile(
                title: 'Consumer',
                subtitle: 'Book venues & services',
                isSelected: _selectedRole == 'CONSUMER',
                icon: Icons.event_available,
                onTap: () {
                  setState(() {
                    _selectedRole = 'CONSUMER';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleOptionTile(
                title: 'Owner',
                subtitle: 'Create & manage listings',
                isSelected: _selectedRole == 'OWNER',
                icon: Icons.storefront,
                onTap: () {
                  setState(() {
                    _selectedRole = 'OWNER';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

}

class _RoleOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleOptionTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? const Color(0xFFE53E3E) : Colors.grey.shade300;
    final bgColor = isSelected ? const Color(0xFFFFE5E8) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: isSelected
                    ? const Color(0xFFE53E3E)
                    : Colors.grey.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  size: 18, color: Color(0xFFE53E3E)),
          ],
        ),
      ),
    );
  }
}
