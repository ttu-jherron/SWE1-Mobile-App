import 'package:flutter/material.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import 'widgets/app_text_field.dart';
import 'widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final codeCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _verifyCode() async {
    final _auth = ClerkAuth.of(context);
    setState(() { _loading = true; });
    try {
      await _auth.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        code: codeCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification successful!')),
        );
        Navigator.pop(context); // Or navigate to home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() { _loading = false; });
      }
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ebonyClay,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyClay,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.sandyYellow),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: Spacing.xxl),
                AppTextField(
                  controller: codeCtrl,
                  label: 'Verification Code',
                  hint: 'Enter 6-digit code',
                  borderColor: AppColors.sandyYellow,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: Spacing.xl),
                PrimaryButton(
                  text: _loading ? '' : 'Verify',
                  variant: ButtonVariant.yellowFilled,
                  onPressed: _verifyCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
