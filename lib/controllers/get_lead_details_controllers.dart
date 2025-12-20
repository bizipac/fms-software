import 'package:get/get.dart';
import '../models/get_lead_details_model.dart';
import '../services/get_lead_details.dart';

class GetLeadDetailsController extends GetxController {
  var isLoading = false.obs;
  var leadDetails = Rxn<GetLeadDetails>();

  Future<void> fetchLeads(String mobileOrLeadId) async {
    try {
      isLoading.value = true;
      final result = await LeadService.fetchLeads(mobileOrLeadId);
      leadDetails.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
class GetTransferLeadController extends GetxController {
  var isLoading = false.obs;
  var leadDetails = Rxn<GetLeadDetails>();

  Future<void> fetchTransferLeads(String mobileOrLeadId,String branchId) async {
    try {
      isLoading.value = true;
      final result = await LeadService.fetchTransferLeads(mobileOrLeadId,branchId);
      leadDetails.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
