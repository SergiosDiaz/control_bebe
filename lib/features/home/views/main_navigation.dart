import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import 'home_view.dart';
import '../../diapers/views/diapers_view.dart';
import '../../feeding/views/feeding_view.dart';
import '../../weight/views/weight_view.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    void goToHome() => setState(() => _currentIndex = 0);
    final screens = [
      HomeView(
        onNavigateToTab: (i) => setState(() => _currentIndex = i),
        onTitleTap: goToHome,
      ),
      DiapersView(onTitleTap: goToHome),
      FeedingView(onTitleTap: goToHome),
      WeightView(onTitleTap: goToHome),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Inicio',
                  isSelected: _currentIndex == 0,
                  color: AppTheme.primaryBlue,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.water_drop_outlined,
                  activeIcon: Icons.water_drop,
                  label: 'Pañales',
                  isSelected: _currentIndex == 1,
                  color: AppTheme.primaryBlue,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.local_drink_outlined,
                  activeIcon: Icons.local_drink,
                  label: 'Comida',
                  isSelected: _currentIndex == 2,
                  color: AppTheme.primaryPink,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.monitor_weight_outlined,
                  activeIcon: Icons.monitor_weight,
                  label: 'Peso',
                  isSelected: _currentIndex == 3,
                  color: AppTheme.primaryOrange,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 28,
              color: isSelected ? color : AppTheme.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
