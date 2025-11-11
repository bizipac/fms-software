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
