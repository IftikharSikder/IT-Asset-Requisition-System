import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controllers/employee_details_controller.dart';
import 'package:untitled/screens/employee_asset_details.dart';
import 'package:untitled/utils/helper.dart';

import 'asset_dialog.dart';

class AssetListItem extends StatelessWidget {
  final Map<String, dynamic> asset;
  final int index;
  final EmployeeDetailsController controller;
  final DocumentSnapshot employee;

  const AssetListItem({
    Key? key,
    required this.asset,
    required this.index,
    required this.controller,
    required this.employee,
  }) : super(key: key);

  _CategoryStyle _style(String category) {
    switch (category) {
      case 'Electronics':
        return _CategoryStyle(
          bg: const Color(0xFFEBF2FF),
          iconColor: const Color(0xFF2563EB),
          ring: const Color(0xFFBFD7FF),
          gradient: [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
        );
      case 'Furniture':
        return _CategoryStyle(
          bg: const Color(0xFFF0FDF4),
          iconColor: const Color(0xFF10B981),
          ring: const Color(0xFFBBF7D0),
          gradient: [const Color(0xFF10B981), const Color(0xFF6EE7B7)],
        );
      default:
        return _CategoryStyle(
          bg: const Color(0xFFFFFBEB),
          iconColor: const Color(0xFFF59E0B),
          ring: const Color(0xFFFDE68A),
          gradient: [const Color(0xFFF59E0B), const Color(0xFFFCD34D)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = asset['category'] ?? 'Others';
    final s = _style(category);

    return GestureDetector(
      onTap: () =>
          Get.to(() => EmployeeAssetsDetailScreen(serialNumber: asset['sn'], employee: employee)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDF5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left gradient accent bar
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: s.gradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  children: [
                    // Icon box
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: s.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: s.ring),
                      ),
                      child: Icon(
                        AssetHelpers.getCategoryIcon(category),
                        color: s.iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + SN + category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset['name'] ?? 'Unknown Asset',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.qr_code_rounded, size: 11, color: const Color(0xFFCBD5E1)),
                              const SizedBox(width: 3),
                              Text(
                                asset['sn'] ?? 'N/A',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: s.bg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: s.ring),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: s.iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Column(
                      children: [
                        _iconBtn(
                          Icons.edit_rounded,
                          const Color(0xFFEBF2FF),
                          const Color(0xFF2563EB),
                          () => AssetDialogs.showEditAssetDialog(context, controller, asset, index),
                        ),
                        const SizedBox(height: 6),
                        _iconBtn(
                          Icons.delete_rounded,
                          const Color(0xFFFEE2E2),
                          const Color(0xFFEF4444),
                          () =>
                              AssetDialogs.showDeleteConfirmationDialog(context, controller, index),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

class _CategoryStyle {
  final Color bg, iconColor, ring;
  final List<Color> gradient;
  const _CategoryStyle({
    required this.bg,
    required this.iconColor,
    required this.ring,
    required this.gradient,
  });
}
