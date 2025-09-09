import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/layout/app_layout.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final usernameCtrl = TextEditingController(text: 'Master Builder 1000');
  final nameCtrl = TextEditingController(text: 'Bob DaBuilder');
  final phoneCtrl = TextEditingController(text: '(123) - 456 - 7890');
  final emailCtrl = TextEditingController(text: 'bobdabuIlder@gmail.com');
  final passCtrl = TextEditingController(text: '***************');

  @override
  void dispose() {
    usernameCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.lg,
        ),
        child: Column(
          children: [
            const SizedBox(height: Spacing.lg),
            const CircleAvatar(
              radius: 56,
              backgroundImage: AssetImage('assets/images/bob.jpg'),
            ),
            const SizedBox(height: Spacing.lg),

            // username “chip” with larger yellow outline
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sandyYellow, width: 3),
              ),
              child: TextField(
                controller: usernameCtrl,
                decoration: const InputDecoration(
                  hintText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: AppColors.ebonyClay,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Spacing.sm),

            _LabeledField(label: 'Full Name', controller: nameCtrl),
            const SizedBox(height: Spacing.md),
            _LabeledField(
              label: 'Phone Number',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Spacing.md),
            _LabeledField(
              label: 'Email',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: Spacing.md),
            _LabeledField(
              label: 'Password',
              controller: passCtrl,
              obscure: true,
            ),

            const SizedBox(height: Spacing.xl),

            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: save -> API call
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Saved!')));
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.ebonyClay,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: const TextStyle(color: AppColors.ebonyClay),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
