import 'package:flutter/material.dart';
import 'package:untitled/controllers/employee_details_controller.dart';

import '../custom_widgets/asset_dialog.dart';

class DialogUtils {
  static void showEditAssetDialog(
    BuildContext context,
    EmployeeDetailsController controller,
    Map<String, dynamic> asset,
    int assetIndex,
  ) {
    AssetDialogs.showEditAssetDialog(context, controller, asset, assetIndex);
  }

  static void showAddAssetDialog(BuildContext context, EmployeeDetailsController controller) {
    AssetDialogs.showAddAssetDialog(context, controller);
  }

  static void showDeleteConfirmationDialog(
    BuildContext context,
    EmployeeDetailsController controller,
    int index,
  ) {
    AssetDialogs.showDeleteConfirmationDialog(context, controller, index);
  }
}
