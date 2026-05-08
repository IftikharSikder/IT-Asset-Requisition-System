import 'package:flutter/material.dart';

class TotalAssetsCard extends StatelessWidget {
  final int totalAssets;
  final Map<String, int>? categoryBreakdown;

  const TotalAssetsCard({Key? key, required this.totalAssets, this.categoryBreakdown})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2456CA), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL ASSETS',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$totalAssets',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // Category breakdown
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _categoryBox(
                  Icons.laptop_rounded,
                  '${categoryBreakdown?['Electronics'] ?? 0}',
                  'Electronics',
                  const Color(0xFFEBF2FF),
                  const Color(0xFF2563EB),
                  const Color(0xFFDBEAFE),
                ),
                const SizedBox(width: 8),
                _categoryBox(
                  Icons.chair_rounded,
                  '${categoryBreakdown?['Furniture'] ?? 0}',
                  'Furniture',
                  const Color(0xFFF0FDF4),
                  const Color(0xFF10B981),
                  const Color(0xFFD1FAE5),
                ),
                const SizedBox(width: 8),
                _categoryBox(
                  Icons.build_rounded,
                  '${categoryBreakdown?['Others'] ?? 0}',
                  'Others',
                  const Color(0xFFFFFBEB),
                  const Color(0xFFF59E0B),
                  const Color(0xFFFDE68A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBox(
    IconData icon,
    String count,
    String label,
    Color bg,
    Color iconColor,
    Color ringColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ringColor.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: iconColor),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
