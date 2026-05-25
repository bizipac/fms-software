# fms_software

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

----------------------------
String? selectedBranchId;
String? selectedBranchName;
String? selectedLat;
String? selectedLong;
/// 🔥 Branch Dropdown
StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
.collection('subcompanies')
.doc(widget.cid)
.collection('branches')
.snapshots(),
builder: (context, snapshot) {
if (!snapshot.hasData) {
return const CircularProgressIndicator();
}

                  return DropdownButtonFormField(
                    hint: const Text("Select Branch"),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['branchName']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final doc = snapshot.data!.docs
                          .firstWhere((e) => e.id == value);

                      selectedBranchId = doc.id;
                      selectedBranchName = doc['branchName'];
                      selectedLat = doc['latitude'];
                      selectedLong = doc['longitude'];
                    },
                  );
                },
              ),
