import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';

import '../organiser_login_page.dart';
import 'blocked_page.dart';
import 'defaults_page.dart';
import 'favourites_page.dart';
import 'organiser_cubit.dart';

class OrganiserProfilePage extends StatelessWidget {
  const OrganiserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.person, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: AppTheme.paddingLarge),
          _ReadOnlyField(label: 'Username', value: user.username),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'Email', value: user.email),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'First Name', value: user.firstName),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'Last Name', value: user.lastName),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'Location', value: user.location),
          const SizedBox(height: AppTheme.paddingLarge),
          const Divider(),
          _NavigationTile(
            icon: Icons.star,
            title: 'Favourites',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<AuthCubit>()),
                    BlocProvider.value(value: context.read<OrganiserCubit>()),
                  ],
                  child: const FavouritesPage(),
                ),
              ),
            ),
          ),
          _NavigationTile(
            icon: Icons.block,
            title: 'Blocked',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<AuthCubit>()),
                    BlocProvider.value(value: context.read<OrganiserCubit>()),
                  ],
                  child: const BlockedPage(),
                ),
              ),
            ),
          ),
          _NavigationTile(
            icon: Icons.settings,
            title: 'Defaults',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<AuthCubit>()),
                    BlocProvider.value(value: context.read<OrganiserCubit>()),
                  ],
                  child: const DefaultsPage(),
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.cancelColor),
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OrganiserLoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
