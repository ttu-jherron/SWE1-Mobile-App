import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/colors.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:mobile_app/core/widgets/loading_screen.dart';
import 'package:mobile_app/app.dart'; // for routeObserver

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  Future<Map<String, dynamic>>? _backendFuture;
  Future<void>? _splashFuture;

  Timer? _retryTimer;
  int _retryAttempts = 0;
  bool _subscribed = false; // avoid double-subscribing RouteObserver

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure we’re in profile context even on first mount
      try {
        final dh = DataHandler.fromContext(context);
        dh.enterProfileContext();
      } catch (_) {}
      _resetAndStartFetch();
      _startRetryLoop(); // also start bounded retry on first entry (no cache/offline cases)
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_subscribed && route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    // Leave profile context when this widget is disposed
    try {
      DataHandler.fromContext(context).exitProfileContext();
    } catch (_) {}
    _stopRetryLoop();
    if (_subscribed) {
      routeObserver.unsubscribe(this);
      _subscribed = false;
    }
    super.dispose();
  }

  // Entered Profile tab
  @override
  void didPush() {
    _enterAndFetch();
  }

  // Returned to Profile tab
  @override
  void didPopNext() {
    _enterAndFetch();
  }

  // Navigating away from Profile tab
  @override
  void didPushNext() {
    _leaveProfile();
  }

  // Popping Profile tab
  @override
  void didPop() {
    _leaveProfile();
  }

  void _enterAndFetch() {
    final dh = DataHandler.fromContext(context);
    dh.enterProfileContext();
    _resetAndStartFetch();
    _startRetryLoop();
  }

  void _leaveProfile() {
    DataHandler.fromContext(context).exitProfileContext();
    _stopRetryLoop();
  }

  void _resetAndStartFetch() {
    _backendFuture = null;
    _splashFuture = null;
    _startFetch();
  }

  void _startFetch() {
    final auth = ClerkAuth.of(context);
    if (auth.user == null) return;
    final dh = DataHandler(auth: auth);

    // 100ms splash per navigation
    _splashFuture = Future.delayed(const Duration(milliseconds: 100));

    // Force a backend fetch; fallback to cache on timeout
    setState(() {
      _backendFuture = dh
          .backendFetchProfile(force: true)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => dh.cachedBackendProfile ?? <String, dynamic>{},
          );
    });
  }

  // Bounded retry loop to handle offline->online while Profile is open.
  // IMPORTANT: rebuild the Future each attempt so FutureBuilder updates.
  void _startRetryLoop() {
    _stopRetryLoop();
    final dh = DataHandler.fromContext(context);
    final noCache = dh.cachedBackendProfile == null || dh.cachedBackendProfile!.isEmpty;
    if (!noCache) return;

    // Try immediately once and rebuild the future
    setState(() {
      _backendFuture = dh
          .backendFetchProfile(force: true)
          .timeout(const Duration(seconds: 5), onTimeout: () => dh.cachedBackendProfile ?? <String, dynamic>{});
    });

    _retryAttempts = 0;
    _retryTimer = Timer.periodic(const Duration(seconds: 5), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      final handler = DataHandler.fromContext(context);
      final hasCache = handler.cachedBackendProfile != null && handler.cachedBackendProfile!.isNotEmpty;
      if (hasCache) {
        t.cancel();
        return;
      }
      _retryAttempts += 1;
      if (_retryAttempts > 6) { // ~30s total, then stop
        t.cancel();
        return;
      }
      // Rebuild the future each attempt
      setState(() {
        _backendFuture = handler
            .backendFetchProfile(force: true)
            .timeout(const Duration(seconds: 5), onTimeout: () => handler.cachedBackendProfile ?? <String, dynamic>{});
      });
    });
  }

  void _stopRetryLoop() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempts = 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);

    if (auth.user == null) {
      return AppLayout(
        currentIndex: 3,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dataHandler = DataHandler(auth: auth);

    // Ensure builders have futures even on first build
    _splashFuture ??= Future.delayed(const Duration(milliseconds: 100));
    _backendFuture ??= dataHandler
        .backendFetchProfile(force: true)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => dataHandler.cachedBackendProfile ?? <String, dynamic>{},
        );

    return AppLayout(
      currentIndex: 3,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: dataHandler.backendProfileStream,
        initialData: dataHandler.cachedBackendProfile,
        builder: (context, streamSnap) {
          final streamData = streamSnap.data ?? <String, dynamic>{};

          return FutureBuilder<void>(
            future: _splashFuture,
            builder: (context, splashSnap) {
              final inSplash = splashSnap.connectionState == ConnectionState.waiting;

              if (inSplash) {
                return const LoadingScreen();
              }

              return FutureBuilder<Map<String, dynamic>>(
                future: _backendFuture,
                builder: (context, backendSnap) {
                  final futureData = backendSnap.data ?? <String, dynamic>{};
                  final effective =
                      streamData.isNotEmpty ? streamData
                      : futureData.isNotEmpty ? futureData
                      : (dataHandler.cachedBackendProfile ?? <String, dynamic>{});

                  final String? profileImageUrl = effective['image_url'] ?? effective['imageUrl'];
                  final String email = effective['email'] ?? effective['Email'] ?? 'No Email';
                  final String username = effective['username'] ?? email;

                  final String firstName = effective['first_name'] ?? effective['firstName'] ?? '';
                  final String lastName = effective['last_name'] ?? effective['lastName'] ?? '';
                  final String fullName = "$firstName $lastName".trim();
                  final String displayFullName = fullName.isEmpty ? "No access to backend" : fullName;
                  final String phoneNumber =
                      effective['phone_number'] ?? effective['phoneNumber'] ?? 'No access to backend';

                  final bool avatarLoading =
                      backendSnap.connectionState == ConnectionState.waiting &&
                      streamData.isEmpty &&
                      (dataHandler.cachedBackendProfile == null ||
                       dataHandler.cachedBackendProfile!.isEmpty);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xl,
                      vertical: Spacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: Spacing.lg),
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: _buildProfileAvatar(
                              profileImageUrl,
                              loading: avatarLoading,
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Text(
                          username,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.lg),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // EDITABLE: Full Name (now split into First / Last when editing)
                                _InlineEditableFullName(
                                  firstName: firstName,
                                  lastName: lastName,
                                  underline: false,
                                ),
                                const SizedBox(height: Spacing.lg),
                                // EDITABLE: Phone Number
                                _InlineEditableField(
                                  label: 'Phone Number',
                                  initialValue: phoneNumber,
                                  underline: false,
                                  keyboardType: TextInputType.phone,
                                  saveKey: 'phone_number',
                                ),
                                const SizedBox(height: Spacing.lg),
                                // EDITABLE: Email
                                _InlineEditableField(
                                  label: 'Email',
                                  initialValue: email,
                                  underline: true,
                                  keyboardType: TextInputType.emailAddress,
                                  saveKey: 'email',
                                  validator: (v) {
                                    final s = v.trim();
                                    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
                                    return ok ? null : 'Enter a valid email';
                                  },
                                ),
                                const SizedBox(height: Spacing.lg),
                                // EDITABLE: Password
                                const _InlineEditablePassword(
                                  label: 'Password',
                                  saveKey: 'password',
                                ),
                                const SizedBox(height: Spacing.xl),
                              ],
                            ),
                          ),
                        ),
                       
                        SizedBox(
                          width: 128,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await dataHandler.clearAllCache();
                              await auth.signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                              }
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            child: const Center(child: Text('Sign Out')),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(String? imageUrl, {bool loading = false}) {
    // While fetching with no data yet: show a spinner in a neutral grey circle
    if (loading) {
      return Container(
        width: 128,
        height: 128,
        color: Colors.grey.shade300,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    // If we have an image URL, load it with a simple grey placeholder
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: 128,
        height: 128,
        placeholder: (context, _) => Container(
          width: 128,
          height: 128,
          color: Colors.grey.shade300,
        ),
        errorWidget: (context, url, error) => Container(
          width: 128,
          height: 128,
          color: Colors.grey.shade400,
          child: const Icon(Icons.person, size: 48, color: Colors.white),
        ),
      );
    }

    // No image: neutral grey placeholder
    return Container(
      width: 128,
      height: 128,
      color: Colors.grey.shade400,
      child: const Icon(Icons.person, size: 48, color: Colors.white),
    );
  }
}

class _InlineEditableField extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool underline;
  final TextInputType keyboardType;
  final String saveKey; // used only in TODO comment
  final String? Function(String value)? validator;

  const _InlineEditableField({
    required this.label,
    required this.initialValue,
    required this.saveKey,
    this.underline = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<_InlineEditableField> createState() => _InlineEditableFieldState();
}

class _InlineEditableFieldState extends State<_InlineEditableField> {
  late String _value;
  bool _editing = false;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _ctrl.text = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant _InlineEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent value changes (e.g., from stream), refresh when not editing
    if (!_editing && oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() {
      _ctrl.text = _value;
      _editing = true;
    });
  }

  void _cancel() {
    setState(() {
      _ctrl.text = _value;
      _editing = false;
    });
  }

  void _save() {
    final newVal = _ctrl.text.trim();
    if (widget.validator != null) {
      final err = widget.validator!(newVal);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        return;
      }
    }
    if (newVal == _value) {
      setState(() => _editing = false);
      return;
    }
    setState(() {
      _value = newVal;
      _editing = false;
    });

    // TODO: Persist to backend via DataHandler (example API)
    // final dh = DataHandler.fromContext(context);
    // await dh.updateProfileField(widget.saveKey, newVal);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
    );

    if (!_editing) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: labelStyle),
            const SizedBox(height: Spacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _value,
                    style: TextStyle(
                      color: AppColors.ebonyClay, // was Colors.black87
                      decoration: widget.underline ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                  tooltip: 'Edit',
                  onPressed: _startEdit,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: labelStyle),
          const SizedBox(height: Spacing.xs),
          TextSelectionTheme(
            data: TextSelectionThemeData(
              selectionColor: AppColors.ebonyClay.withOpacity(0.25),
              selectionHandleColor: AppColors.ebonyClay, // “blob”
            ),
            child: TextField(
              controller: _ctrl,
              keyboardType: widget.keyboardType,
              cursorColor: AppColors.ebonyClay,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.sandyYellow, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
                style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineEditablePassword extends StatefulWidget {
  final String label;
  final String saveKey; // used only in TODO comment

  const _InlineEditablePassword({
    required this.label,
    required this.saveKey,
  });

  @override
  State<_InlineEditablePassword> createState() => _InlineEditablePasswordState();
}

class _InlineEditablePasswordState extends State<_InlineEditablePassword> {
  bool _editing = false;
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _startEdit() => setState(() => _editing = true);
  void _cancel() {
    _newCtrl.clear();
    _confirmCtrl.clear();
    setState(() => _editing = false);
  }

  void _save() {
    final p1 = _newCtrl.text;
    final p2 = _confirmCtrl.text;
    if (p1.isEmpty || p2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter and confirm your new password.')));
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    // TODO: Persist to backend via DataHandler (example API)
    // final dh = DataHandler.fromContext(context);
    // await dh.updatePassword(p1);

    _cancel(); // close editor after "saving"
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
    );

    if (!_editing) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: labelStyle),
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '***************',
                    style: TextStyle(color: AppColors.ebonyClay), // was Colors.black87
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                  tooltip: 'Edit',
                  onPressed: _startEdit,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: labelStyle),
          const SizedBox(height: Spacing.xs),
          TextSelectionTheme(
            data: TextSelectionThemeData(
              selectionColor: AppColors.ebonyClay.withOpacity(0.25),
              selectionHandleColor: AppColors.ebonyClay, // “blob”
            ),
            child: TextField(
              controller: _newCtrl,
              obscureText: _obscure1,
              cursorColor: AppColors.ebonyClay,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                labelText: 'New password',
                labelStyle: const TextStyle(color: Colors.black54),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.sandyYellow, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextSelectionTheme(
            data: TextSelectionThemeData(
              selectionColor: AppColors.ebonyClay.withOpacity(0.25),
              selectionHandleColor: AppColors.ebonyClay, // “blob”
            ),
            child: TextField(
              controller: _confirmCtrl,
              obscureText: _obscure2,
              cursorColor: AppColors.ebonyClay,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                labelText: 'Confirm password',
                labelStyle: const TextStyle(color: Colors.black54),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.sandyYellow, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
                style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineEditableFullName extends StatefulWidget {
  final String firstName;
  final String lastName;
  final bool underline;

  const _InlineEditableFullName({
    required this.firstName,
    required this.lastName,
    this.underline = false,
  });

  @override
  State<_InlineEditableFullName> createState() => _InlineEditableFullNameState();
}

class _InlineEditableFullNameState extends State<_InlineEditableFullName> {
  late String _first;
  late String _last;
  bool _editing = false;

  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _first = widget.firstName;
    _last = widget.lastName;
    _firstCtrl.text = _first;
    _lastCtrl.text = _last;
  }

  @override
  void didUpdateWidget(covariant _InlineEditableFullName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing &&
        (oldWidget.firstName != widget.firstName || oldWidget.lastName != widget.lastName)) {
      _first = widget.firstName;
      _last = widget.lastName;
      _firstCtrl.text = _first;
      _lastCtrl.text = _last;
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() {
      _firstCtrl.text = _first;
      _lastCtrl.text = _last;
      _editing = true;
    });
  }

  void _cancel() {
    setState(() {
      _firstCtrl.text = _first;
      _lastCtrl.text = _last;
      _editing = false;
    });
  }

  void _save() {
    final newFirst = _firstCtrl.text.trim();
    final newLast = _lastCtrl.text.trim();
    final changed = newFirst != _first || newLast != _last;
    if (!changed) {
      setState(() => _editing = false);
      return;
    }
    setState(() {
      _first = newFirst;
      _last = newLast;
      _editing = false;
    });

    // TODO: Persist both fields via DataHandler:
    // final dh = DataHandler.fromContext(context);
    // await dh.updateProfileFields({'first_name': _first, 'last_name': _last});
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
    );

    final combined = '$_first $_last'.trim().isEmpty ? 'No access to backend' : '$_first $_last'.trim();

    if (!_editing) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full Name', style: labelStyle),
            const SizedBox(height: Spacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    combined,
                    style: TextStyle(
                      color: AppColors.ebonyClay,
                      decoration: widget.underline ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                  tooltip: 'Edit',
                  onPressed: _startEdit,
                ),
              ],
            ),
          ],
        ),
      );
    }

    InputDecoration _dec(String label) => InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.sandyYellow, width: 2),
          ),
        );

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Full Name', style: labelStyle),
            const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Expanded(
                child: TextSelectionTheme(
                  data: TextSelectionThemeData(
                    selectionColor: AppColors.ebonyClay.withOpacity(0.25),
                    selectionHandleColor: AppColors.ebonyClay,
                  ),
                  child: TextField(
                    controller: _firstCtrl,
                    cursorColor: AppColors.ebonyClay,
                    style: const TextStyle(color: Colors.black87),
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('First'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextSelectionTheme(
                  data: TextSelectionThemeData(
                    selectionColor: AppColors.ebonyClay.withOpacity(0.25),
                    selectionHandleColor: AppColors.ebonyClay,
                  ),
                  child: TextField(
                    controller: _lastCtrl,
                    cursorColor: AppColors.ebonyClay,
                    style: const TextStyle(color: Colors.black87),
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Last'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
                style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}