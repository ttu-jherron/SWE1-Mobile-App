import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/data/data_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final usernameCtrl = TextEditingController(text: 'Master Builder 1000');
  final firstNameCtrl = TextEditingController(text: 'Bob');
  final lastNameCtrl = TextEditingController(text: 'DaBuilder');
  final phoneCtrl = TextEditingController(text: '(123) - 456 - 7890');
  final emailCtrl = TextEditingController(text: 'bobdabuIlder@gmail.com');
  // final passCtrl = TextEditingController(text: '***************'); // handled later by Clerk

  bool _saving = false;
  bool _prefilled = false;
  late String _initialUsername;
  late String _initialEmail;

  @override
  void initState() {
    super.initState();
    _initialUsername = usernameCtrl.text.trim();
    _initialEmail = emailCtrl.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromSources());
  }

  Future<void> _prefillFromSources() async {
    final auth = ClerkAuth.of(context);
    final u = auth.user;
    Map<String, dynamic>? backend;
    try {
      final dh = DataHandler.fromContext(context);
      //backend = await dh.backendFetchProfile(force: true);
    } catch (_) {
      // ignore; will fall back to Clerk-only data
    }

    if (!mounted) return;
    setState(() {
      final backendUsername = backend?['username'] as String?;
      final backendEmail = backend?['email'] as String?;
      final backendFirst = backend?['first_name'] as String?;
      final backendLast = backend?['last_name'] as String?;
      final backendPhone = backend?['phone_number'] as String?;

      usernameCtrl.text =
          (backendUsername?.trim().isNotEmpty == true ? backendUsername : u?.username)?.trim() ?? '';
      emailCtrl.text =
          (backendEmail?.trim().isNotEmpty == true ? backendEmail : u?.email)?.trim() ?? '';
      firstNameCtrl.text = (backendFirst ?? u?.firstName ?? '').trim();
      lastNameCtrl.text = (backendLast ?? u?.lastName ?? '').trim();
      phoneCtrl.text = (backendPhone ?? '').trim();

      _initialUsername = usernameCtrl.text.trim();
      _initialEmail = emailCtrl.text.trim();
      _prefilled = true; // stop showing loader even if backend failed
    });
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    // passCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final auth = ClerkAuth.of(context);
      final user = auth.user;
      if (user == null) throw Exception('Not signed in');

      final newUsername = usernameCtrl.text.trim();
      final newEmail = emailCtrl.text.trim();

      //TODO add Clerk api calls and user updates
      /*
      // Clerk-managed updates
      if (newUsername.isNotEmpty && newUsername != _initialUsername) {
        await user.update(username: newUsername);
        _initialUsername = newUsername;
      }
      if (newEmail.isNotEmpty && newEmail != _initialEmail) {
        // If verification is required, switch to add+verify flow later.
        await user.update(emailAddress: newEmail);
        _initialEmail = newEmail;
      }
      */

      // TODO Remove Username and Email from backend and transition to clerk
      // Backend-managed updates (PATCH users/{clerkId})
      final dh = DataHandler.fromContext(context);
      /*
      await dh.updateUserProfile(
        clerkId: user.id,
        firstName: _emptyToNull(firstNameCtrl.text),
        lastName: _emptyToNull(lastNameCtrl.text),
        phoneNumber: _emptyToNull(phoneCtrl.text),
        // Temporary until Clerk owns these fully
        username: _emptyToNull(newUsername),
        email: _emptyToNull(newEmail),
      );
      */

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _emptyToNull(String? v) {
    final t = v?.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    // Show loader until backend fetch/prefill completes
    if (!_prefilled) {
      return AppLayout(
        currentIndex: 3,
        popOnCurrentTabTap: true,
        body: const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return AppLayout(
      currentIndex: 3,
      popOnCurrentTabTap: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.lg,
        ),
        child: Column(
          children: [
            // Add "X" close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close, color: AppColors.ebonyClay),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            // TODO Re-enable and use backend profile image URL
            /*
            const CircleAvatar(
              radius: 56,
              backgroundImage: AssetImage('assets/images/bob.jpg'),
            ),
            */
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

            // Split full name into first/last (backend-managed)
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ebonyClay,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'First Name',
                          controller: firstNameCtrl,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: _LabeledField(
                          label: 'Last Name',
                          controller: lastNameCtrl,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),

            _LabeledField(
              label: 'Phone Number',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Spacing.md),

            // Email (Clerk-managed)
            _LabeledField(
              label: 'Email',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: Spacing.md),

            // Password (handled later by Clerk)
            // _LabeledField(
            //   label: 'Password',
            //   controller: passCtrl,
            //   obscure: true,
            // ),

            const SizedBox(height: Spacing.xl),

            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
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
