import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_here/core/utils/linkedin_utils.dart';
import 'package:linked_here/features/auth/presentation/bloc/auth_bloc.dart';

/// Screen where the user enters their LinkedIn profile URL after
/// signing in.
class ProfileSetupScreen extends StatefulWidget {
  /// Creates a [ProfileSetupScreen].
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final slug = extractLinkedInSlug(_controller.text.trim());
    if (slug == null) return;

    context.read<AuthBloc>().add(AuthLinkedInSlugSubmitted(slug));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: avoid_types_on_closure_parameters, context.select requires the type annotation to infer the Bloc type.
    final profile = context.select((AuthBloc bloc) => bloc.state.profile);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current.status == AuthStatus.error,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Setup'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile != null) ...[
                    Text(
                      'Welcome, ${profile.displayName}!',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your LinkedIn profile URL so '
                      'others can find you nearby.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'LinkedIn Profile URL',
                      hintText: 'https://www.linkedin.com/in/your-name',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your LinkedIn URL';
                      }
                      if (!isValidLinkedInInput(value.trim())) {
                        return 'Invalid LinkedIn URL or slug';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can paste a full URL or just your slug '
                    '(e.g. "john-doe")',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.status == AuthStatus.loading;

                      return FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: Text(
                          isLoading ? 'Saving...' : 'Continue',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
