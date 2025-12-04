import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_navigation_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  int _countdown = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Pre-fill with example OTP: 697549
    _controllers[0].text = '6';
    _controllers[1].text = '9';
    _controllers[2].text = '7';
    _controllers[3].text = '5';
    _controllers[4].text = '4';
    _controllers[5].text = '9';
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto-verify when all 6 digits are entered
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      // Navigate to main app after successful verification
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _handleResend() {
    if (_canResend) {
      _startCountdown();
      // Handle resend OTP logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding =
        (size.width * 0.08).clamp(16.0, 32.0); // responsive padding
    final titleFontSize = (size.width * 0.08).clamp(24.0, 34.0);
    final bodyFontSize = (size.width * 0.04).clamp(14.0, 18.0);
    final spacingLarge = (size.height * 0.05).clamp(32.0, 48.0);
    final spacingMedium = (size.height * 0.025).clamp(18.0, 28.0);
    final buttonHeight = (size.height * 0.065).clamp(48.0, 60.0);
    final otpBoxSize = (size.width * 0.12).clamp(44.0, 60.0);

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
                'Almost there',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: spacingMedium * 0.8),
              // Description
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Please enter the 6-digit code sent to your email ',
                    ),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: Color(0xFFE53E3E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text: ' for verification.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacingLarge),
              // OTP input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: otpBoxSize,
                    height: otpBoxSize + 8,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: otpBoxSize * 0.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE53E3E),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => _onOtpChanged(index, value),
                    ),
                  );
                }),
              ),
              SizedBox(height: spacingLarge),
              // Verify button
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Resend code section
              Center(
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: 'Didn\'t receive any code? '),
                          TextSpan(
                            text: 'Resend Again',
                            style: TextStyle(
                              fontSize: 14,
                              color: _canResend
                                  ? const Color(0xFFE53E3E)
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _canResend
                                ? (TapGestureRecognizer()..onTap = _handleResend)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Request new code in 00:${_countdown.toString().padLeft(2, '0')}s',
                      style: TextStyle(
                        fontSize: bodyFontSize * 0.9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

