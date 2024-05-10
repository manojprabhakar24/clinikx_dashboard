import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'config.dart';

class MobileDashboard extends StatefulWidget {
  @override
  _MobileDashboardState createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  String selectedItem = ''; // Track the selected item in the drawer
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController govIdController = TextEditingController();
  TextEditingController fromTimeController = TextEditingController();
  TextEditingController toTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Text(
          'Welcome Admin',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            color: Colors.white,
            onPressed: () {
              // Navigate to profile page
            },
          ),
        ],
      ),
      body: _buildBody(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  AppConfig.imagelogo,
                  height: 60,
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
          _buildDrawerItem('Branch Manage'),
          _buildDrawerItem('Staff Manage'),
          _buildDrawerItem('Appointments'),
          _buildDrawerItem('Patients'),
          _buildDrawerItem('Subscription'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title) {
    return ListTile(
      title: Text(title),
      selected: selectedItem == title,
      onTap: () => _selectDrawerItem(title),
    );
  }

  Widget _buildBody() {
    if (selectedItem == 'Branch Manage') {
      return _buildBranchDataTable();
    } else {
      return Center(
        child: Text('Select an item from the drawer to view details.'),
      );
    }
  }


  Widget _buildBranchDataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('branches').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No branches available.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            String branchName = snapshot.data!.docs[index]['clinicName'];
            String mobileNumber = snapshot.data!.docs[index]['mobileNumber'];
            String branchId = snapshot.data!.docs[index]['branchId'];
            Map<String, dynamic>? data = snapshot.data!.docs[index].data() as Map<String, dynamic>?;
            String? govIdNumber = data != null && data.containsKey('govIdNumber') ? data['govIdNumber'] : null;
            String? timingsFrom = data != null && data.containsKey('timingsFrom') ? data['timingsFrom'] : null;
            String? timingsTo = data != null && data.containsKey('timingsTo') ? data['timingsTo'] : null;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ExpansionTile(
                  title: Text(branchName),
                  children: [
                    _buildDetailText('Area: ${snapshot.data!.docs[index]['area']}'),
                    _buildDetailText('City: ${snapshot.data!.docs[index]['city']}'),
                    _buildDetailText('State: ${snapshot.data!.docs[index]['state']}'),
                    _buildDetailText('Mobile Number: $mobileNumber'),
                    if (govIdNumber != null) _buildDetailText('Government ID: $govIdNumber'),
                    if (timingsFrom != null) _buildDetailText('Timings From: $timingsFrom'),
                    if (timingsTo != null) _buildDetailText('Timings To: $timingsTo'),
                    if (govIdNumber == null || timingsFrom == null || timingsTo == null)
                      TextButton(
                        onPressed: () => _openEditProfilePopup(
                          context,
                          branchId,
                          branchName,
                          snapshot.data!.docs[index]['area'],
                          snapshot.data!.docs[index]['city'],
                          snapshot.data!.docs[index]['state'],
                          mobileNumber,
                          govIdNumber,
                          timingsFrom,
                          timingsTo,
                        ),
                        child: Text('Click here to complete profile'),
                      ),
                    if (govIdNumber != null && timingsFrom != null && timingsTo != null)
                      ElevatedButton(
                        onPressed: () => _openEditProfilePopup(
                          context,
                          branchId,
                          branchName,
                          snapshot.data!.docs[index]['area'],
                          snapshot.data!.docs[index]['city'],
                          snapshot.data!.docs[index]['state'],
                          mobileNumber,
                          govIdNumber,
                          timingsFrom,
                          timingsTo,
                        ),
                        child: Text('Edit'),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEditProfilePopup(
      BuildContext context,
      String branchId,
      String branchName,
      String area,
      String city,
      String state,
      String mobileNumber,
      String? govIdNumber,
      String? timingsFrom,
      String? timingsTo,
      ) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController branchNameController = TextEditingController(text: branchName);
    TextEditingController areaController = TextEditingController(text: area);
    TextEditingController cityController = TextEditingController(text: city);
    TextEditingController stateController = TextEditingController(text: state);
    TextEditingController mobileNumberController = TextEditingController(text: mobileNumber);

    govIdController.text = govIdNumber ?? '';
    fromTimeController.text = timingsFrom ?? '';
    toTimeController.text = timingsTo ?? '';

    showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: Text('Edit Branch Details'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: branchNameController,
                  decoration: InputDecoration(
                    labelText: 'Branch Name',
                  ),
                ),
                TextFormField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: 'Area',
                  ),
                ),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                  ),
                ),
                TextFormField(
                  controller: stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                  ),
                ),
                TextFormField(
                  controller: mobileNumberController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                  ),
                ),
                TextFormField(
                  controller: govIdController,
                  decoration: InputDecoration(
                    labelText: 'Government ID Number',
                  ),
                ),
                TextFormField(
                  controller: fromTimeController,
                  decoration: InputDecoration(
                    labelText: 'Timings From',
                  ),
                ),
                TextFormField(
                  controller: toTimeController,
                  decoration: InputDecoration(
                    labelText: 'Timings To',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String updatedBranchName = branchNameController.text;
                  String updatedArea = areaController.text;
                  String updatedCity = cityController.text;
                  String updatedState = stateController.text;
                  String updatedMobileNumber = mobileNumberController.text;
                  String updatedGovIdNumber = govIdController.text;
                  String updatedTimingsFrom = fromTimeController.text;
                  String updatedTimingsTo = toTimeController.text;

                  // Update the branch details in Firestore
                  await FirebaseFirestore.instance.collection('branches').doc(branchId).update({
                    'clinicName': updatedBranchName,
                    'area': updatedArea,
                    'city': updatedCity,
                    'state': updatedState,
                    'mobileNumber': updatedMobileNumber,
                    'govIdNumber': updatedGovIdNumber,
                    'timingsFrom': updatedTimingsFrom,
                    'timingsTo': updatedTimingsTo,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Branch details updated successfully')));
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }



  void _openCompleteProfilePopup(BuildContext context, String branchId, String branchName, String area, String city, String state, String mobileNumber, String? govIdNumber, String? timingsFrom, String? timingsTo) {
    final _formKey = GlobalKey<FormState>();

    govIdController.text = govIdNumber ?? '';
    fromTimeController.text = timingsFrom ?? '';
    toTimeController.text = timingsTo ?? '';

    showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: Text('Complete Profile'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (govIdNumber == null || timingsFrom == null || timingsTo == null)
                  TextFormField(
                    controller: govIdController,
                    decoration: InputDecoration(
                      labelText: 'Government ID Number',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      // Validation logic for government ID number
                    },
                  ),
                if (govIdNumber == null || timingsFrom == null || timingsTo == null)
                  SizedBox(height: 16),
                if (govIdNumber == null || timingsFrom == null || timingsTo == null)
                  TextFormField(
                    controller: fromTimeController,
                    decoration: InputDecoration(
                      labelText: 'Timings From',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      // Validation logic for timings
                    },
                  ),
                if (govIdNumber == null || timingsFrom == null || timingsTo == null)
                  SizedBox(height: 16),
                if (govIdNumber == null || timingsFrom == null || timingsTo == null)
                  TextFormField(
                    controller: toTimeController,
                    decoration: InputDecoration(
                      labelText: 'Timings To',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      // Validation logic for timings
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String govtIdNumber = govIdController.text;
                  String timingsFrom = fromTimeController.text;
                  String timingsTo = toTimeController.text;

                  // Get existing branch data
                  final branchDoc = await FirebaseFirestore.instance.collection('branches').doc(branchId).get();
                  if (branchDoc.exists) {
                    // Merge new data with existing data
                    final newData = {
                      'govIdNumber': govtIdNumber,
                      'timingsFrom': timingsFrom,
                      'timingsTo': timingsTo,
                      // Add more fields as needed
                    };
                    // Update the document in Firestore with merged data
                    await branchDoc.reference.update(newData);
                    // Show a snackbar to indicate successful update
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
                    govIdController.clear();
                    fromTimeController.clear();
                    toTimeController.clear();
                    // Update the dropdown list with the saved data
                    setState(() {
                      selectedItem = 'Branch Manage'; // Select Branch Manage item to reload the StreamBuilder
                    });
                  } else {
                    // Show an error message if the document doesn't exist
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Branch document not found')));
                  }
                  Navigator
                      .pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _selectDrawerItem(String item) {
    setState(() {
      selectedItem = item;
    });
    Navigator.pop(context); // Close the drawer after selecting an item
  }
}

class ImagePick extends StatefulWidget {
  final Function(Uint8List?) onImagePicked;

  ImagePick({required this.onImagePicked});

  @override
  _ImagePickState createState() => _ImagePickState();
}

class _ImagePickState extends State<ImagePick> {
  Uint8List? _image;

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
      widget.onImagePicked(_image);
    }
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source, imageQuality: 50);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No Images Selected');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        _image != null
            ? Image.memory(
          _image!,
          height: 100,
        )
            : Column(
          children: [
            ElevatedButton(
              onPressed: selectImage,
              child: Text('Upload Document'),
            ),
            Text(
              'Please select a document',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
