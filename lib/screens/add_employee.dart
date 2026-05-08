import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imgController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  RxInt lastEmployeeId = 0.obs;
  RxBool isLoading = false.obs;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _getLastEmployeeId();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _getLastEmployeeId() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      lastEmployeeId.value = snapshot.docs.first['id'];
    }
  }

  void addEmployee() {
    String name = nameController.text.trim();
    String img = imgController.text.trim();
    String designation = designationController.text.trim();
    String department = departmentController.text.trim();

    if (name.isEmpty || img.isEmpty || designation.isEmpty || department.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
    int newEmployeeId = lastEmployeeId.value + 1;

    FirebaseFirestore.instance
        .collection('employee')
        .add({
          "name": name,
          "id": newEmployeeId,
          "img": img,
          "designation": designation,
          "department": department,
        })
        .then((_) {
          lastEmployeeId.value = newEmployeeId;
          isLoading.value = false;
          Get.snackbar(
            "Success",
            "Employee added successfully",
            backgroundColor: const Color(0xFFD1FAE5),
            colorText: const Color(0xFF065F46),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
          if (mounted) Navigator.of(context).pop();
        })
        .catchError((error) {
          isLoading.value = false;
          Get.snackbar(
            "Error",
            "Failed to add employee: ${error.toString()}",
            backgroundColor: const Color(0xFFFEE2E2),
            colorText: const Color(0xFF991B1B),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          // ── Background gradient header ─────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.32,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2456CA), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: -30,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Main scrollable content ────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Back nav + title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Employee',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Fill in the details below',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Avatar preview + card
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        child: Column(
                          children: [
                            // Avatar preview
                            Builder(
                              builder: (_) {
                                final url = imgController.text.trim();
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Avatar circle
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFDBEAFE),
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.18),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                        image: url.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(url),
                                                fit: BoxFit.cover,
                                                onError: (_, __) {},
                                              )
                                            : null,
                                      ),
                                      child: url.isEmpty
                                          ? const Icon(
                                              Icons.person_rounded,
                                              color: Color(0xFF1E3A8A),
                                              size: 36,
                                            )
                                          : null,
                                    ),

                                    // ── Camera badge (bottom-right) ──────────────
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF2563EB),
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF1E3A8A,
                                              ).withValues(alpha: 0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Profile Photo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Form card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8EDF5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionLabel('Personal Info'),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    controller: nameController,
                                    label: 'Full Name',
                                    hint: 'e.g. Sarah Rahman',
                                    icon: Icons.badge_rounded,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    controller: imgController,
                                    label: 'Photo URL',
                                    hint: 'https://...',
                                    icon: Icons.image_rounded,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 22),
                                  _sectionLabel('Work Details'),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    controller: designationController,
                                    label: 'Designation',
                                    hint: 'e.g. Senior Engineer',
                                    icon: Icons.work_rounded,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    controller: departmentController,
                                    label: 'Department',
                                    hint: 'e.g. Engineering',
                                    icon: Icons.business_rounded,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Submit button
                            Obx(
                              () => isLoading.value
                                  ? const SizedBox(
                                      height: 56,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF1E3A8A),
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: addEmployee,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF376BE5),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.person_add_rounded, size: 20),
                                            SizedBox(width: 10),
                                            Text(
                                              'Add Employee',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, size: 17, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
