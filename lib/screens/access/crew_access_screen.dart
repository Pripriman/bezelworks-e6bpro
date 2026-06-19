import 'package:flutter/material.dart';

import '../../config/app_env.dart';
import '../../runtime/alert_relay.dart';
import '../../runtime/backend_bus.dart';
import '../../runtime/pulse_beacon.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../../widgets/bezel_card.dart';
import '../../widgets/compute_button.dart';

class CrewAccessScreen extends StatefulWidget {
  final VoidCallback onDone;
  const CrewAccessScreen({super.key, required this.onDone});

  @override
  State<CrewAccessScreen> createState() => _CrewAccessScreenState();
}

class _CrewAccessScreenState extends State<CrewAccessScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _createMode = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!AppEnv.hasSupabase) {
      _toast('Accounts are unavailable right now.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_createMode) {
        final res = await BackendBus.enroll(_email.text.trim(), _pass.text);
        PulseBeacon.registration();
        final uid = res.user?.id;
        if (uid != null) await AlertRelay.bindCrew(uid);
        _toast('Account created. Check your inbox to confirm.');
      } else {
        final res = await BackendBus.signIn(_email.text.trim(), _pass.text);
        PulseBeacon.login();
        final uid = res.user?.id;
        if (uid != null) await AlertRelay.bindCrew(uid);
      }
      if (!mounted) return;
      widget.onDone();
    } catch (e) {
      _toast(_humanError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _humanError(Object e) {
    final s = e.toString();
    if (s.contains('Invalid login')) return 'Wrong email or password.';
    if (s.contains('already registered')) {
      return 'This email is already registered.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _toast('Enter your email first, then tap reset.');
      return;
    }
    try {
      await BackendBus.resetPassword(email);
      _toast('Password reset link sent.');
    } catch (_) {
      _toast('Could not send reset link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BezelPalette.consoleGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: EngraveLink(
                    label: 'SKIP FOR NOW',
                    onPressed: _busy ? null : widget.onDone,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_createMode ? 'CREATE LOGBOOK' : 'CREW ACCESS',
                    style: BezelType.engraved(16, color: BezelPalette.amber)),
                const SizedBox(height: 10),
                Text(
                  'An account backs up your aircraft profiles across devices and powers alerts. It is optional — every computation runs fully offline.',
                  style: BezelType.body(),
                ),
                const SizedBox(height: 24),
                BezelCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: BezelType.bodyStrong(),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty || !t.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pass,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          style: BezelType.bodyStrong(),
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          validator: (v) {
                            if ((v ?? '').length < 6) {
                              return 'At least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (!_createMode) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: EngraveLink(
                              label: 'FORGOT PASSWORD?',
                              onPressed: _busy ? null : _forgotPassword,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        ComputeButton(
                          label: _createMode ? 'CREATE ACCOUNT' : 'SIGN IN',
                          busy: _busy,
                          onPressed: _busy ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _createMode = !_createMode),
                  child: Text(
                    _createMode
                        ? 'I already have an account'
                        : 'New here? Create an account',
                    style: BezelType.bodyStrong(color: BezelPalette.amber),
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
