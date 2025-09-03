import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Settings header
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Account section
          _buildSectionHeader(context, 'Account'),
          _buildSettingTile(
            context,
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Manage your account details',
            onTap: () {
              // Navigate to profile screen
            },
          ),
          _buildSettingTile(
            context,
            icon: MdiIcons.crown,
            title: 'Premium',
            subtitle: 'Upgrade to Premium for more features',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'UPGRADE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              // Show premium options
            },
          ),
          
          // App preferences section
          _buildSectionHeader(context, 'App Preferences'),
          _buildSettingTile(
            context,
            icon: Icons.dark_mode,
            title: 'Theme',
            subtitle: 'Light, Dark, or System default',
            onTap: () {
              // Show theme options
              _showThemeOptions(context);
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // Show language options
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.image_outlined,
            title: 'Default Image Quality',
            subtitle: 'Set default compression quality',
            onTap: () {
              // Show quality options
              _showQualityOptions(context);
            },
          ),
          
          // Support section
          _buildSectionHeader(context, 'Support'),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with using the app',
            onTap: () {
              // Navigate to help screen
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.star_outline,
            title: 'Rate App',
            subtitle: 'Rate us on the App Store',
            onTap: () {
              // Open app store rating
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.share_outlined,
            title: 'Share App',
            subtitle: 'Share with friends and family',
            onTap: () {
              // Share app
            },
          ),
          
          // Legal section
          _buildSectionHeader(context, 'Legal'),
          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Show privacy policy
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // Show terms of service
            },
          ),
          
          // App info
          const SizedBox(height: 24),
          Center(
            child: Text(
              'RipeHash v1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
  
  Widget _buildSettingTile(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  void _showThemeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light Theme'),
            onTap: () {
              // Set light theme
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Theme'),
            onTap: () {
              // Set dark theme
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_system_daydream),
            title: const Text('System Default'),
            onTap: () {
              // Set system theme
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  
  void _showQualityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Default Compression Quality',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: const Text('High Quality (90%)'),
            subtitle: const Text('Larger file size, better quality'),
            onTap: () {
              // Set high quality
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Medium Quality (70%)'),
            subtitle: const Text('Balanced size and quality'),
            onTap: () {
              // Set medium quality
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Low Quality (50%)'),
            subtitle: const Text('Smaller file size, reduced quality'),
            onTap: () {
              // Set low quality
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Custom...'),
            onTap: () {
              // Show custom quality slider
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}