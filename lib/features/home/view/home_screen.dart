import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ripehash/app/constants/app_strings.dart';
import 'package:ripehash/features/home/view/widgets/feature_card.dart';
import 'package:ripehash/features/home/view/widgets/bottom_nav_bar.dart';
import 'package:ripehash/features/home/view/compress_photo_screen.dart';
import 'package:ripehash/features/home/view/advanced_compress_screen.dart';
import 'package:ripehash/features/home/view/resize_compress_screen.dart';
import 'package:ripehash/features/home/view/crop_compress_screen.dart';
import 'package:ripehash/features/home/view/convert_format_screen.dart';
import 'package:ripehash/features/home/view/gallery_screen.dart';
import 'package:ripehash/features/home/view/settings_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          // Crown icon for premium features
          IconButton(
            icon: Icon(MdiIcons.crown, color: Colors.amber),
            onPressed: () {
              // Show premium features dialog
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    // Show different screens based on the selected tab
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const GalleryScreen();
      case 2:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feature cards grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                // Compress Photo
                FeatureCard(
                  title: AppStrings.compressPhoto,
                  icon: Icons.compress,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompressPhotoScreen(),
                      ),
                    );
                  },
                ),
                
                // Advanced Compress
                FeatureCard(
                  title: AppStrings.advancedCompress,
                  icon: Icons.auto_awesome,
                  color: Colors.blue,
                  isPremium: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvancedCompressScreen(),
                      ),
                    );
                  },
                ),
                
                // Resize + Compress
                FeatureCard(
                  title: AppStrings.resizeCompress,
                  icon: Icons.photo_size_select_large,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResizeCompressScreen(),
                      ),
                    );
                  },
                ),
                
                // Crop + Compress
                FeatureCard(
                  title: AppStrings.cropCompress,
                  icon: Icons.crop,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CropCompressScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Convert Photo Format button
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.blue),
              title: const Text(AppStrings.convertFormat),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConvertFormatScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Compressed Images'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Change Language'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle),
            title: const Text('Remove Ads'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text('Others', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.headset_mic),
            title: const Text('Customer Support'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}