// ini fitur bar dibawah yg sebelumnya untuk beranda,
// riwayat pengajuan dan profil sudah dinonaktifkan dan ada dibeberapa file integrasinya
// yaitu difile confirm_ktp..., referral_screen, home_screen, prepare_karip../ sudah dinonaktifkan code ini
// FloatingBottomNavigationBar(
//             isVisible: _isBottomNavBarVisible,
//             currentIndex: 2,
//             onTapItem: (newIndex) {
//               Navigator.of(context).pop(newIndex);
//             },
//           ),

import 'package:flutter/material.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar_item.dart';

class FloatingBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTapItem;
  final bool isVisible;
  final Duration duration;

  const FloatingBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTapItem,
    this.isVisible = true,
    this.duration = const Duration(milliseconds: 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: duration,
      bottom: isVisible ? 16.0 : 0.0,
      left: 25.0,
      right: 25.0,
      child: AnimatedOpacity(
        duration: duration,
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36.0),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 0),
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 8.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingBottomNavigationBarItem(
                  onTap: () {
                    onTapItem(0);
                  },
                  text: 'Beranda',
                  assetNameInactive: 'assets/icon/home_icon.png',
                  assetNameActive: 'assets/icon/home_icon_active.png',
                  isActive: currentIndex == 0,
                ),
                // FloatingBottomNavigationBarItem(
                //   onTap: () {
                //     onTapItem(1);
                //   },
                //   text: 'Jenis Produk',
                //   assetNameInactive: 'assets/icon/application_icon.png',
                //   assetNameActive: 'assets/icon/application_icon_active.png',
                //   isActive: currentIndex == 1,
                // ),
                FloatingBottomNavigationBarItem(
                  onTap: () {
                    onTapItem(1);
                  },
                  text: 'Pengajuan',
                  assetNameInactive: 'assets/icon/submission_icon.png',
                  assetNameActive: 'assets/icon/submission_icon_active.png',
                  isActive: currentIndex == 1,
                ),
                FloatingBottomNavigationBarItem(
                  onTap: () {
                    onTapItem(2);
                  },
                  text: 'Akun',
                  assetNameInactive: 'assets/icon/account_icon.png',
                  assetNameActive: 'assets/icon/account_icon_active.png',
                  isActive: currentIndex == 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
