import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/screens/edit_employee_screen.dart';
import 'package:untitled/screens/employee_details.dart';

class EmployeeListWidget extends StatefulWidget {
  final Query<Object?> query;
  final Function refreshDepartments;
  final Function? onEmployeeDeleted;

  const EmployeeListWidget({
    Key? key,
    required this.query,
    required this.refreshDepartments,
    this.onEmployeeDeleted,
  }) : super(key: key);

  @override
  _EmployeeListWidgetState createState() => _EmployeeListWidgetState();
}

class _EmployeeListWidgetState extends State<EmployeeListWidget> {
  List<DocumentSnapshot> employees = [];
  bool isLoading = true;
  Stream<QuerySnapshot>? _employeeStream;

  final List<List<Color>> _gradients = [
    [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
    [const Color(0xFF10B981), const Color(0xFF6EE7B7)],
    [const Color(0xFF7C3AED), const Color(0xFFA78BFA)],
    [const Color(0xFFEF4444), const Color(0xFFFCA5A5)],
    [const Color(0xFFF59E0B), const Color(0xFFFCD34D)],
    [const Color(0xFF0891B2), const Color(0xFF67E8F9)],
  ];

  final List<Color> _avatarBg = [
    const Color(0xFFDBEAFE),
    const Color(0xFFD1FAE5),
    const Color(0xFFEDE9FE),
    const Color(0xFFFEE2E2),
    const Color(0xFFFEF3C7),
    const Color(0xFFCFFAFE),
  ];

  final List<Color> _avatarText = [
    const Color(0xFF2563EB),
    const Color(0xFF10B981),
    const Color(0xFF7C3AED),
    const Color(0xFFEF4444),
    const Color(0xFFF59E0B),
    const Color(0xFF0891B2),
  ];

  @override
  void initState() {
    super.initState();
    _setupEmployeeStream();
  }

  @override
  void didUpdateWidget(EmployeeListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _setupEmployeeStream();
    }
  }

  void _setupEmployeeStream() {
    setState(() => isLoading = true);
    _employeeStream = widget.query.snapshots();
    _employeeStream!.listen(
      (snapshot) {
        if (mounted) {
          setState(() {
            employees = snapshot.docs;
            isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => isLoading = false);
          Get.snackbar(
            "Error",
            "Failed to load employees: $error",
            backgroundColor: const Color(0xFFFEE2E2),
            colorText: const Color(0xFF991B1B),
          );
        }
      },
    );
  }

  Future<void> deleteEmployee(String id, int index) async {
    setState(() => employees.removeAt(index));
    if (widget.onEmployeeDeleted != null) widget.onEmployeeDeleted!();

    try {
      final employeesRef = FirebaseFirestore.instance.collection('employee');
      final employeeDoc = await employeesRef.doc(id).get();

      if (employeeDoc.exists) {
        final employeeId = employeeDoc['id'];
        final assetDocs = await FirebaseFirestore.instance
            .collection('assets')
            .where('assinee_id', isEqualTo: employeeId)
            .get();

        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var assetDoc in assetDocs.docs) {
          batch.delete(assetDoc.reference);
        }
        await batch.commit();
        await employeesRef.doc(id).delete();

        Get.snackbar(
          "Success",
          "Employee and all associated assets deleted successfully",
          backgroundColor: const Color(0xFFD1FAE5),
          colorText: const Color(0xFF065F46),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to delete: $error",
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void navigateToEditScreen(BuildContext context, DocumentSnapshot employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmployeeScreen(
          id: employee.id,
          name: employee['name'],
          designation: employee['designation'],
          department: employee['department'],
        ),
      ),
    ).then((_) {
      widget.refreshDepartments();
      if (widget.onEmployeeDeleted != null) widget.onEmployeeDeleted!();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A), strokeWidth: 2.5),
      );
    }

    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: const Color(0xFFEBF2FF), shape: BoxShape.circle),
              child: const Icon(Icons.people_outline_rounded, color: Color(0xFF1E3A8A), size: 32),
            ),
            const SizedBox(height: 14),
            const Text(
              'No employees found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try a different department filter',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final ci = index % _gradients.length;
        final imgUrl = employee['img'] ?? '';
        final hasImg = imgUrl.isNotEmpty;

        return Dismissible(
          key: Key(employee.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => deleteEmployee(employee.id, index),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            // Replace the card Container decoration:
            decoration: BoxDecoration(
              // Subtle gradient background instead of flat white
              gradient: LinearGradient(
                colors: [Colors.white, _avatarBg[ci].withValues(alpha: 0.3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gradients[ci][0].withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: _gradients[ci][0].withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 24),
                const SizedBox(height: 4),
                const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmployeeDetailScreen(employee)),
              ).then((_) {
                widget.refreshDepartments();
                if (widget.onEmployeeDeleted != null) {
                  widget.onEmployeeDeleted!();
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, _avatarBg[ci].withValues(alpha: 0.35)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gradients[ci][0].withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: _gradients[ci][0].withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Colored left accent bar
                  Container(
                    width: 4,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _gradients[ci],
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          // Avatar with colored ring
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: _gradients[ci]),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: _avatarBg[ci],
                              backgroundImage: hasImg ? NetworkImage(imgUrl) : null,
                              onBackgroundImageError: (_, __) {},
                              child: !hasImg
                                  ? Text(
                                      employee['name'][0].toUpperCase(),
                                      style: TextStyle(
                                        color: _avatarText[ci],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name + designation + dept badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  employee['designation'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _avatarBg[ci],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    employee['department'] ?? '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _avatarText[ci],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Edit button
                          GestureDetector(
                            onTap: () => navigateToEditScreen(context, employee),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF2FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBFD7FF)),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF2563EB),
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
