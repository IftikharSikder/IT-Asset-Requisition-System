import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/controllers/employee_details_controller.dart';

class AssetDialogs {
  static InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  static Widget _dialogTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEBF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1E3A8A), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  static Widget _cancelBtn(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: const Text('Cancel', style: TextStyle(fontSize: 13)),
    );
  }

  static Widget _primaryBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  static void showEditAssetDialog(
    BuildContext context,
    EmployeeDetailsController controller,
    Map<String, dynamic> asset,
    int assetIndex,
  ) {
    final nameController = TextEditingController(text: asset['name']);
    final snController = TextEditingController(text: asset['sn']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogTitle('Edit Asset', Icons.edit_outlined),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: _inputDecoration('Asset Name', Icons.label_outline),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: snController,
                decoration: _inputDecoration('Serial Number', Icons.qr_code),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _cancelBtn(context),
                  const SizedBox(width: 8),
                  _primaryBtn('Save Changes', const Color(0xFF1E3A8A), () {
                    controller.updateAsset(assetIndex, {
                      'name': nameController.text,
                      'sn': snController.text,
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      _snackBar('Asset updated successfully', const Color(0xFF10B981)),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showAddAssetDialog(BuildContext context, EmployeeDetailsController controller) {
    final nameController = TextEditingController();
    final snController = TextEditingController();
    final imageUrlController = TextEditingController();
    controller.selectedCategory.value = controller.categories[0];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogTitle('Add New Asset', Icons.add_box_outlined),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration('Asset Name', Icons.label_outline),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: snController,
                  decoration: _inputDecoration('Serial Number', Icons.qr_code),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedCategory.value,
                    decoration: _inputDecoration('', Icons.category_outlined),
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.updateSelectedCategory(val);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: _inputDecoration('Image URL', Icons.image_outlined),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _cancelBtn(context),
                    const SizedBox(width: 8),
                    _primaryBtn('Add Asset', const Color(0xFF1E3A8A), () async {
                      final employeeId = controller.employee.value?['id'];
                      if (employeeId != null) {
                        if (snController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            _snackBar('Serial number cannot be empty', const Color(0xFFEF4444)),
                          );
                          return;
                        }
                        final isUnique = await controller.isSerialNumberUnique(snController.text);
                        if (isUnique) {
                          controller.addAsset({
                            'name': nameController.text,
                            'sn': snController.text,
                            'category': controller.selectedCategory.value,
                            'assinee_id': employeeId,
                            'image_url': imageUrlController.text,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            _snackBar('Asset added successfully', const Color(0xFF10B981)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            _snackBar(
                              'Sorry! This SN exists. Try a new one.',
                              const Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showDeleteConfirmationDialog(
    BuildContext context,
    EmployeeDetailsController controller,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                'Delete Asset',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to delete this asset? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _cancelBtn(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _primaryBtn('Delete', const Color(0xFFEF4444), () {
                      controller.deleteAsset(index);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snackBar('Asset deleted successfully', const Color(0xFF10B981)),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static SnackBar _snackBar(String message, Color color) {
    return SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    );
  }
}
