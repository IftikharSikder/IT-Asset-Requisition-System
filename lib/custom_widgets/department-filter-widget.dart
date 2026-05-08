import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controllers/employee-controller.dart';
import 'package:untitled/utils/constants.dart';

class DepartmentFilterWidget extends StatelessWidget {
  final EmployeeController controller;

  const DepartmentFilterWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoadingDepartments.value
          ? const SizedBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF23449D), Color(0xFF2563EB)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Departments',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.departments.length,
                    itemBuilder: (context, index) {
                      final department = controller.departments[index];
                      return Obx(() {
                        final isSelected =
                            department == (controller.selectedDepartment.value ?? 'All Employees');

                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (department == 'All Employees') {
                                  AppStrings.totalEmployeesLabel = 'All Employees';
                                  controller.selectedDepartment.value = null;
                                } else {
                                  AppStrings.totalEmployeesLabel =
                                      'Number of Employees in $department';
                                  controller.selectedDepartment.value = department;
                                }
                                controller.refreshEmployeeCount();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [Color(0xFF3255B9), Color(0xFF2563EB)],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  department,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                            if (index < controller.departments.length - 1) const SizedBox(width: 8),
                          ],
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
