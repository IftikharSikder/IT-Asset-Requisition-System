import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controllers/employee-controller.dart';
import 'package:untitled/custom_widgets/custom_app_bar.dart';
import 'package:untitled/custom_widgets/department-filter-widget.dart';
import 'package:untitled/custom_widgets/employee-count-widget.dart';
import 'package:untitled/custom_widgets/employee-list-widget.dart';
import 'package:untitled/screens/add_employee.dart';
import 'package:untitled/utils/constants.dart';

class HomePageScreen extends StatelessWidget {
  final EmployeeController controller = Get.put(EmployeeController());

  HomePageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDepartments();
      controller.setupEmployeeListener();
    });

    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => EmployeeCountWidget(
              employeeCount: controller.employeeCount.value,
              isLoading: controller.isCountLoading.value,
            ),
          ),

          DepartmentFilterWidget(controller: controller),

          SizedBox(height: 16),

          // Employee list
          Expanded(
            child: Obx(
              () => EmployeeListWidget(
                query: controller.getFilteredQuery(),
                refreshDepartments: controller.fetchDepartments,
                onEmployeeDeleted: () => controller.refreshEmployeeCount(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2852C4), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3255B9).withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF3255B9).withValues(alpha: 0.2),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Get.to(() => const AddEmployeeScreen()),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Employee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
