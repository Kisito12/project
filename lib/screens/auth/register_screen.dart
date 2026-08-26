import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/company.dart';
import '../../services/app_state.dart';
import '../../services/company_service.dart';

enum _AccountKind { newCompany, joinCompany }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyPhoneController = TextEditingController();

  _AccountKind _kind = _AccountKind.newCompany;
  String? _selectedCompanyId;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    _companyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_kind == _AccountKind.joinCompany && _selectedCompanyId == null) {
      setState(() => _error = 'Choose a company to join');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      final authService = appState.authService;
      final uid = await authService.createAuthAccount(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String companyId;
      UserRole role;
      if (_kind == _AccountKind.newCompany) {
        final company = await CompanyService().createCompany(
          Company(
            id: '',
            name: _companyNameController.text.trim(),
            contactEmail: _emailController.text.trim(),
            phone: _companyPhoneController.text.trim(),
            status: CompanyStatus.pending,
            ownerId: uid,
            createdAt: DateTime.now(),
          ),
        );
        companyId = company.id;
        role = UserRole.companyAdmin;
      } else {
        companyId = _selectedCompanyId!;
        role = UserRole.companyWorker;
      }

      await authService.createUserProfile(
        AppUser(
          uid: uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: role,
          companyId: companyId,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Registration failed');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Password must be 6+ characters' : null,
                ),
                const SizedBox(height: 20),
                SegmentedButton<_AccountKind>(
                  segments: const [
                    ButtonSegment(
                      value: _AccountKind.newCompany,
                      label: Text('Register a company'),
                      icon: Icon(Icons.apartment),
                    ),
                    ButtonSegment(
                      value: _AccountKind.joinCompany,
                      label: Text('Join a company'),
                      icon: Icon(Icons.badge_outlined),
                    ),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (s) => setState(() => _kind = s.first),
                ),
                const SizedBox(height: 16),
                if (_kind == _AccountKind.newCompany) ...[
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(labelText: 'Company name'),
                    validator: (v) => (_kind == _AccountKind.newCompany &&
                            (v == null || v.trim().isEmpty))
                        ? 'Enter your company name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _companyPhoneController,
                    decoration: const InputDecoration(labelText: 'Company phone'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your company account starts as "pending" until the platform '
                    'approves it. You\'ll be the company admin.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ] else
                  StreamBuilder<List<Company>>(
                    stream: CompanyService().watchApprovedCompanies(),
                    builder: (context, snapshot) {
                      final companies = snapshot.data ?? [];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (companies.isEmpty) {
                        return const Text(
                          'No approved companies yet. Ask your company admin to '
                          'register first, or register a company yourself.',
                        );
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCompanyId,
                        decoration: const InputDecoration(labelText: 'Your company'),
                        items: companies
                            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCompanyId = v),
                      );
                    },
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
