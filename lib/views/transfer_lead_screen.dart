import 'package:flutter/material.dart';
import 'package:fms_software/controllers/assign_to_tele_controller.dart';
import 'package:fms_software/models/DocumentResponse.dart';
import 'package:fms_software/models/get_lead_details_model.dart';
import 'package:fms_software/models/user_tele_response_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../controllers/appointment_fix_controller.dart';
import '../controllers/assign_fe_controller.dart';
import '../controllers/document_controller.dart';
import '../controllers/user_tele_controller.dart';
import '../controllers/userlist_controller.dart';
import '../models/time_slot_model.dart';
import '../models/user_model.dart';
import '../models/userlist_model.dart';
import '../services/timeslot_service.dart';
import '../utils/app_constant.dart';

class TransferLeadScreen extends StatefulWidget {
  final LeadMaster leadMaster;
  final String user_id;
  final String branchid;
   TransferLeadScreen({super.key, required this.leadMaster,required this.user_id,required this.branchid});
  @override
  State<TransferLeadScreen> createState() => _TransferLeadScreenState();
}
class StatusItem {
  final int id;
  final String title;
  final String value;
  final int parentId;

  StatusItem({
    required this.id,
    required this.title,
    required this.value,
    required this.parentId,
  });
}

class _TransferLeadScreenState extends State<TransferLeadScreen> {
  final List<StatusItem> statusList = [
    StatusItem(id: 1, title: "Assign Tele", value: "2", parentId: 1),
    //StatusItem(id: 2, title: "Call Later", value: "3", parentId: 1),
   // StatusItem(id: 3, title: "RTO on Call", value: "4", parentId: 1),
    StatusItem(id: 4, title: "Appointment Fix", value: "5", parentId: 1),
    StatusItem(id: 5, title: "Assign Fe", value: "6", parentId: 1),
   // StatusItem(id: 6, title: "Partial Pickup", value: "7", parentId: 1),
    //StatusItem(id: 7, title: "Full Collection", value: "8", parentId: 1),
    //StatusItem(id: 8, title: "RTO On Field", value: "9", parentId: 1),
    // StatusItem(id: 10, title: "Submission", value: "11", parentId: 1),
    // StatusItem(id: 11, title: "Retele Assign", value: "12", parentId: 1),
    // StatusItem(id: 12, title: "Error Recieved", value: "14", parentId: 1),
    // StatusItem(id: 13, title: "PickedUp", value: "15", parentId: 1),
  ];
  final AssignToFeController controller = AssignToFeController();
  String? selectedStatusValue;
  bool fesms = false;
  bool customersms = false;
  //Appointment Fix
  String? selectedLoc; // Selected value
  DateTime? selectedDate;//selected date
  String? selectedTimeslot;//slected time slot
  //String? selectedDocument;//slected document
  final UserController _controller = UserController();

  List<UserData1> userList = [];
  UserData1? selectedUser;
  String? selectFEName;
  bool loading = true;
  //start time slot dropdown
  List<Timeslot> timeslotList = [];
  //String? selectedDocument;
  List<String> selectedDocuments = [];  // multiple selection store

  void loadTimeslots() async {
    try {
      final data = await TimeslotService.fetchTimeSlots();
      setState(() {
        timeslotList = data;
      });
    } catch (e) {
      print("Error fetching timeslots: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load timeslots")));
    }
  }
  DocumentResponse? documentResponse;
  List<Doc> documentList = [];

  Future<void> loadDocuments() async {
    try {
      final data = await DocumentController.fetchDocument();
      if (data != null) {
        setState(() {
          documentResponse = data;
          documentList = data.doclist;   // ✔ correct list
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<void> loadUserData() async {
    try {
      userList = await _controller.fetchUsers(widget.branchid);
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error: $e");
    }
  }
  final _formKey = GlobalKey<FormState>();
  //end timeslot dropdown
  final List<String> items = ["Residence", "Office"];

  //user tele data
  final UserListController _controllerTele = UserListController();

  List<UserTeleModel> _userList = [];
  UserTeleModel? _selectedUser;

  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTimeslots();
    loadDocuments();
    loadUserData();
    loadUsers();
  }
  Future<void> loadUsers() async {
    try {
      final result = await _controllerTele.fetchUsers("1", "4");

      // 🔥 Filter users whose branch_multi contains widget.branchid
      final filteredUsers = result.where((user) {
        List<String> branches = user.branchMulti.split(",");
        return branches.contains(widget.branchid);
      }).toList();

      setState(() {
        _userList = filteredUsers;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appBarColor,
        title: Text("LeadId : ${widget.leadMaster.leadId}", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
            DropdownButtonFormField<String>(
            value: selectedStatusValue,
            decoration: InputDecoration(
              labelText: "Select..",
              border: OutlineInputBorder(),
            ),
            items: statusList.map((item) {
              return DropdownMenuItem(
                value: item.value,
                child: Text(item.title),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedStatusValue = newValue!;
              });
            },
          ),
              //Appointment Fix
              selectedStatusValue.toString()=="5"?Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 5,
                  borderOnForeground: true,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: double.infinity,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ----------------- Appointment Location -----------------
                            Text("Appointment Loc : "),
                            SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Select Location..",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedLoc,
                              items: items.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              validator: (value) =>
                              value == null ? "Please select location" : null,
                              onChanged: (val) {
                                setState(() {
                                  selectedLoc = val;
                                });
                              },
                            ),

                            SizedBox(height: 10),

                            // ----------------- Appointment Date -----------------
                            Text("Appointment Date : "),
                            SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2050),
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                  ); // Only date, no time
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: selectedDate == null
                                      ? "Select Appointment Date"
                                      : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                selectedDate == null ? "Please pick appointment date" : null,
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                            // ----------------- Appointment Time -----------------
                            Text("Appointment Time : "),
                            SizedBox(height: 10),
                            timeslotList.isEmpty
                                ? const Center(child: CircularProgressIndicator())
                                : DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Select Time Slot..",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedTimeslot,
                              items: timeslotList.map((slot) {
                                return DropdownMenuItem<String>(
                                  value: slot.timeslot,
                                  child: Text(slot.timeslot, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              validator: (value) =>
                              value == null ? "Please select time slot" : null,
                              onChanged: (value) {
                                setState(() {
                                  selectedTimeslot = value;
                                });
                              },
                            ),

                            SizedBox(height: 10),

                            // ----------------- Documents -----------------
                            Text("Aval Document : "),
                            SizedBox(height: 10),
                            documentList.isEmpty
                                ? const Center(child: CircularProgressIndicator())
                                : MultiSelectDialogField(
                              items: documentList
                                  .map((doc) => MultiSelectItem(doc.docName, doc.docName))
                                  .toList(),
                              title: Text("Select Document"),
                              selectedColor: Colors.blue,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              buttonText: Text("Select Document", style: TextStyle(fontSize: 16)),
                              onConfirm: (values) {
                                setState(() {
                                  selectedDocuments = values.cast<String>();
                                });
                              },
                              // validator: (value) => selectedDocuments.isEmpty
                              //     ? "Please select at least one document"
                              //     : null,
                            ),

                            SizedBox(height: 10),

                            // ----------------- FE Name -----------------
                            Text("Allot FE True : "),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.all(1),
                              child: loading
                                  ? Center(child: CircularProgressIndicator())
                                  : DropdownButtonFormField<UserData1>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Select FE Name",
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedUser,
                                items: userList.map((UserData1 user) {
                                  return DropdownMenuItem<UserData1>(
                                    value: user,
                                    child: Text(
                                      user.userFname,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedUser = value;
                                    selectFEName=selectedUser?.userId.toString();

                                  });
                                },
                                validator: (value) =>
                                value == null ? "Please select FE Name" : null,
                              ),
                            ),
                            SizedBox(height: 20),

                            // ----------------- Save Button -----------------
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // All validations passed
                                  String formattedDate =
                                      "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}";
                                  sendFixAppointment(
                                      widget.user_id,
                                      formattedDate,                           // String
                                      selectedTimeslot!,                           // String
                                      selectedLoc!,                       // String
                                      selectedDocuments,                      // List<String>
                                      selectFEName as String,                                   // String
                                      {
                                        "lead_id": widget.leadMaster.leadId,
                                        "mobile": widget.leadMaster.mobile,
                                        "branch_id": widget.leadMaster.branchId,
                                        "status_id": widget.leadMaster.statusId,
                                        "lead_date":widget.leadMaster.leadDate,
                                        "lead_status": widget.leadMaster.leadStatus,
                                        "client_id": widget.leadMaster.clientId,
                                        "customer_name": widget.leadMaster.customerName,
                                        "product": widget.leadMaster.product,
                                        "product_code": widget.leadMaster.productCode,
                                        "form_no": widget.leadMaster.formNo,
                                        "source": widget.leadMaster.source,
                                        "source2": widget.leadMaster.source2,
                                        "source3": widget.leadMaster.source3,
                                        "res_data": widget.leadMaster.resData,
                                        "res_pin": widget.leadMaster.resPin,
                                        "off_name": widget.leadMaster.offName,
                                        "off_address": widget.leadMaster.offAddress,
                                        "off_no": widget.leadMaster.offNo,
                                        "off_pincode": widget.leadMaster.offPincode,
                                        "doc": widget.leadMaster.doc,
                                        "remarks": widget.leadMaster.remarks,
                                        "pq_leads": widget.leadMaster.pqLeads,
                                        "campaign_name": widget.leadMaster.campaignName,
                                        "case_id": widget.leadMaster.caseId,
                                        "surrogate": widget.leadMaster.surrogate,
                                        "se_code": widget.leadMaster.secode,
                                        "add_on": widget.leadMaster.addOn,
                                        "pq_kyc": widget.leadMaster.pqKyc,
                                        "crm_lead": widget.leadMaster.crmLead,
                                        "annual_salary": widget.leadMaster.annualSalary,
                                        "YBLCustomer": widget.leadMaster.yblCustomer,
                                        "source_code": widget.leadMaster.sourceCode,
                                        "ASM_code": widget.leadMaster.asmCode,
                                        "LC_code": widget.leadMaster.lcCode,
                                        "DV_name": widget.leadMaster.dvName,
                                        "apptime": widget.leadMaster.apptime,
                                        "apploc": widget.leadMaster.apploc,
                                        "accno": widget.leadMaster.accno,
                                        "lgcode": widget.leadMaster.lgcode,
                                        "channelcode": widget.leadMaster.channelcode,
                                        "logo": widget.leadMaster.logo,
                                        "secode": widget.leadMaster.seCode,
                                        "compname": widget.leadMaster.compname,
                                        "valid": widget.leadMaster.valid,
                                        "visitingcard": widget.leadMaster.visitingcard,
                                        "utilitybill": widget.leadMaster.utilitybill,
                                        "aadharcard": widget.leadMaster.aadharcard,
                                        "Athena_lead_id": widget.leadMaster.athenaLeadId,
                                        "service_id": widget.leadMaster.serviceId,
                                        "url": widget.leadMaster.url,
                                        "city": widget.leadMaster.city,
                                        "response_id": widget.leadMaster.responseId,
                                        "branch_name": widget.leadMaster.branchName,
                                        "client_code": widget.leadMaster.clientCode,
                                        "datepicker": formattedDate,
                                        "subType": "Fresh"
                                      }
                                  );

                                  print("Form Validated Successfully");
                                  Get.snackbar(
                                    "Success : ",
                                    "Appointment Fix successfully",
                                    backgroundColor: Colors.white,
                                    colorText: Colors.black,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: EdgeInsets.all(5),
                                    borderRadius: 10,
                                  );
                                  setState(() {
                                  });
                                  Navigator.pop(context);

                                  // CALL API HERE
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              ),
                              child: Text("Save",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                ,
              )
                  :selectedStatusValue.toString()=="6"?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              const Text("Select FE:", style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),

                              loading
                                  ? const Center(child: CircularProgressIndicator())
                                  : DropdownButtonFormField<UserData1>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: "Select FE Name",
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedUser,
                                items: userList.map((user) {
                                  return DropdownMenuItem<UserData1>(
                                    value: user,
                                    child: Text(user.userFname,
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedUser = value;
                                    selectFEName = value?.userId.toString();
                                  });
                                },
                                validator: (value) =>
                                value == null ? "Please select FE Name" : null,
                              ),

                              const SizedBox(height: 20),

                              // FE SMS Switch
                              Row(
                                children: [
                                  Switch(
                                    value: fesms,
                                    activeColor: Colors.green,
                                    onChanged: (value) => setState(() => fesms = value),
                                  ),
                                  const SizedBox(width: 20),
                                  const Text("FE SMS", style: TextStyle(fontSize: 18)),
                                ],
                              ),

                              // Customer SMS Switch
                              Row(
                                children: [
                                  Switch(
                                    value: customersms,
                                    activeColor: Colors.green,
                                    onChanged: (value) => setState(() => customersms = value),
                                  ),
                                  const SizedBox(width: 20),
                                  const Text("Customer SMS", style: TextStyle(fontSize: 18)),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // SAVE BUTTON
                              ElevatedButton(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) return;

                                  if (selectFEName == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Please select FE Name")),
                                    );
                                    return;
                                  }

                                  if (widget.user_id == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("User ID missing")),
                                    );
                                    return;
                                  }

                                  Map<String, dynamic> response = await controller.assignLead(
                                    leads: [
                                      {
                                        "lead_id": widget.leadMaster.leadId,
                                        "mobile": widget.leadMaster.mobile,
                                        "branch_id": widget.leadMaster.branchId,
                                        "status_id": widget.leadMaster.statusId,
                                        "lead_date":widget.leadMaster.leadDate,
                                        "lead_status": widget.leadMaster.leadStatus,
                                        "client_id": widget.leadMaster.clientId,
                                        "customer_name": widget.leadMaster.customerName,
                                        "product": widget.leadMaster.product,
                                        "product_code": widget.leadMaster.productCode,
                                        "form_no": widget.leadMaster.formNo,
                                        "source": widget.leadMaster.source,
                                        "source2": widget.leadMaster.source2,
                                        "source3": widget.leadMaster.source3,
                                        "res_data": widget.leadMaster.resData,
                                        "res_pin": widget.leadMaster.resPin,
                                        "off_name": widget.leadMaster.offName,
                                        "off_address": widget.leadMaster.offAddress,
                                        "off_no": widget.leadMaster.offNo,
                                        "off_pincode": widget.leadMaster.offPincode,
                                        "doc": widget.leadMaster.doc,
                                        "remarks": widget.leadMaster.remarks,
                                        "pq_leads": widget.leadMaster.pqLeads,
                                        "campaign_name": widget.leadMaster.campaignName,
                                        "case_id": widget.leadMaster.caseId,
                                        "surrogate": widget.leadMaster.surrogate,
                                        "se_code": widget.leadMaster.secode,
                                        "add_on": widget.leadMaster.addOn,
                                        "pq_kyc": widget.leadMaster.pqKyc,
                                        "crm_lead": widget.leadMaster.crmLead,
                                        "annual_salary": widget.leadMaster.annualSalary,
                                        "YBLCustomer": widget.leadMaster.yblCustomer,
                                        "source_code": widget.leadMaster.sourceCode,
                                        "ASM_code": widget.leadMaster.asmCode,
                                        "LC_code": widget.leadMaster.lcCode,
                                        "DV_name": widget.leadMaster.dvName,
                                        "apptime": widget.leadMaster.apptime,
                                        "apploc": widget.leadMaster.apploc,
                                        "accno": widget.leadMaster.accno,
                                        "lgcode": widget.leadMaster.lgcode,
                                        "channelcode": widget.leadMaster.channelcode,
                                        "logo": widget.leadMaster.logo,
                                        "secode": widget.leadMaster.seCode,
                                        "compname": widget.leadMaster.compname,
                                        "valid": widget.leadMaster.valid,
                                        "visitingcard": widget.leadMaster.visitingcard,
                                        "utilitybill": widget.leadMaster.utilitybill,
                                        "aadharcard": widget.leadMaster.aadharcard,
                                        "Athena_lead_id": widget.leadMaster.athenaLeadId,
                                        "service_id": widget.leadMaster.serviceId,
                                        "url": widget.leadMaster.url,
                                        "city": widget.leadMaster.city,
                                        "response_id": widget.leadMaster.responseId,
                                        "branch_name": widget.leadMaster.branchName,
                                        "client_code": widget.leadMaster.clientCode,
                                        "datepicker": DateTime.now().toString(),
                                        "subType": "Fresh",
                                      }
                                    ],
                                    config: {
                                      "teleid": selectFEName,
                                      "fesms": fesms,
                                      "cussms": customersms,
                                    },
                                    userid: widget.user_id!,
                                  );

                                  // SUCCESS
                                  setState(() {
                                  });
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    "Success",
                                    "Assign FE successfully",
                                    backgroundColor: Colors.white,
                                    colorText: Colors.black,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: EdgeInsets.all(5),
                                    borderRadius: 10,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                ),
                                child: const Text("Save",
                                    style:
                                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  :selectedStatusValue.toString()=="2"?Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  children: [
                    DropdownButtonFormField<UserTeleModel>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Select Telecaller",
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedUser,
                      items: _userList.map((user) {
                        return DropdownMenuItem(
                          value: user,
                          child: Text("${user.userFname} (${user.userMobile})"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUser = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

            ElevatedButton(
            onPressed: () async {
      List<Map<String, dynamic>> leadList = [
        {
          "lead_id": widget.leadMaster.leadId,
          "mobile": widget.leadMaster.mobile,
          "branch_id": widget.leadMaster.branchId,
          "status_id": widget.leadMaster.statusId,
          "lead_date":widget.leadMaster.leadDate,
          "lead_status": widget.leadMaster.leadStatus,
          "client_id": widget.leadMaster.clientId,
          "customer_name": widget.leadMaster.customerName,
          "product": widget.leadMaster.product,
          "product_code": widget.leadMaster.productCode,
          "form_no": widget.leadMaster.formNo,
          "source": widget.leadMaster.source,
          "source2": widget.leadMaster.source2,
          "source3": widget.leadMaster.source3,
          "res_data": widget.leadMaster.resData,
          "res_pin": widget.leadMaster.resPin,
          "off_name": widget.leadMaster.offName,
          "off_address": widget.leadMaster.offAddress,
          "off_no": widget.leadMaster.offNo,
          "off_pincode": widget.leadMaster.offPincode,
          "doc": widget.leadMaster.doc,
          "remarks": widget.leadMaster.remarks,
          "pq_leads": widget.leadMaster.pqLeads,
          "campaign_name": widget.leadMaster.campaignName,
          "case_id": widget.leadMaster.caseId,
          "surrogate": widget.leadMaster.surrogate,
          "se_code": widget.leadMaster.secode,
          "add_on": widget.leadMaster.addOn,
          "pq_kyc": widget.leadMaster.pqKyc,
          "crm_lead": widget.leadMaster.crmLead,
          "annual_salary": widget.leadMaster.annualSalary,
          "YBLCustomer": widget.leadMaster.yblCustomer,
          "source_code": widget.leadMaster.sourceCode,
          "ASM_code": widget.leadMaster.asmCode,
          "LC_code": widget.leadMaster.lcCode,
          "DV_name": widget.leadMaster.dvName,
          "apptime": widget.leadMaster.apptime,
          "apploc": widget.leadMaster.apploc,
          "accno": widget.leadMaster.accno,
          "lgcode": widget.leadMaster.lgcode,
          "channelcode": widget.leadMaster.channelcode,
          "logo": widget.leadMaster.logo,
          "secode": widget.leadMaster.seCode,
          "compname": widget.leadMaster.compname,
          "valid": widget.leadMaster.valid,
          "visitingcard": widget.leadMaster.visitingcard,
          "utilitybill": widget.leadMaster.utilitybill,
          "aadharcard": widget.leadMaster.aadharcard,
          "Athena_lead_id": widget.leadMaster.athenaLeadId,
          "service_id": widget.leadMaster.serviceId,
          "url": widget.leadMaster.url,
          "city": widget.leadMaster.city,
          "response_id": widget.leadMaster.responseId,
          "branch_name": widget.leadMaster.branchName,
          "client_code": widget.leadMaster.clientCode,
          "datepicker": DateTime.now().toString(),
          "subType": "Fresh"
        }
      ];
      final AssignToTeleController assignToTeleController=AssignToTeleController();

      await assignToTeleController.assignToTele(
      context: context,
      leads: leadList,
      teleId: "${_selectedUser!.userId}",
      userId: "${widget.user_id}",
      onStartLoading: () {
      setState(() => _isLoading = true);
      },
      onStopLoading: () {
      setState(() => _isLoading = false);
      },
      );
      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(),
                minimumSize: Size(double.infinity, 50),
              ),
        child: Text("Assign To Tele"),
      ),
      ],
                ),
              ):SizedBox(),
              //----------------------------------
              // Text("-------------------------------"),
              // Text(selectedStatusValue.toString()),
              // Text(selectedDate.toString()),
              // Text(selectedLoc.toString()),
              // Text(selectedTimeslot.toString()),
              // Text(selectedDocuments.toString()),
              // Text(selectFEName.toString()),
              // Text("--------------------------------"),
              // Center(
              //   child: Text(widget.leadMaster.mobile),
              // ),
              // Center(
              //   child: Text(widget.leadMaster.customerName),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
