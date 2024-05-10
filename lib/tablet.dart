import 'dart:typed_data';

import 'package:clinikx_dashboard/config.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class TabletDashboard extends StatefulWidget {
  @override
  _TabletDashboardState createState() => _TabletDashboardState();
}

class _TabletDashboardState extends State<TabletDashboard> {
  String selectedItem = '';
  String selectedBranchName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Image.asset(
                          AppConfig.imagelogo,
                          height: 60,
                        ),
                      ),
                      _buildMenuItem('Branch Manage'),
                      _buildMenuItem('Staff Manage'),
                      _buildMenuItem('Appointments'),
                      _buildMenuItem('Patients'),
                      _buildMenuItem('Subscription'),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.person),
                        onPressed: () {
                          // Navigate to profile page
                        },
                      ),
                      Text("Admin")
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: selectedItem == 'Branch Manage'
                  ? _buildBranchDataTable()
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedItem = title;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: selectedItem == title ? Colors.purple : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBranchDataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('branches').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: DataTable(
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  dataTextStyle: TextStyle(
                    color: Colors.black,
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Branch Name',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Area',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'City',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'State',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Mobile Number',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),


                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot branch) {
                    String branchName = branch['clinicName'];
                    return DataRow(
                      cells: [
                        DataCell(
                          InkWell(
                            child: Text(
                              branchName,
                              style: TextStyle(color: Colors.black),
                            ),
                            onTap: () {
                              _showBranchDetailsPopup(
                                  context, branchName, branch['city'],
                                  branch['area'], branch['state'],
                                  branch['mobileNumber']);
                            },
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['area'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['city'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['state'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['mobileNumber'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['status'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _showBranchDetailsPopup(BuildContext context, String branchName,
      String city, String area, String state, String mobileNumber) {
    TextEditingController panController = TextEditingController();
    TextEditingController fromTimeController = TextEditingController();
    TextEditingController toTimeController = TextEditingController();

    PickedFile? _image;

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<void> _pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      setState(() {
        _image = pickedFile as PickedFile?;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0)),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            // Adjust padding here
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.tealAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            constraints: BoxConstraints(maxWidth: 400),
            // Set maximum width here
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Branch Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.white),
                      title: Text('Branch Name: $branchName',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_city, color: Colors.white),
                      title: Text('City: $city', style: TextStyle(color: Colors
                          .white)),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.white),
                      title: Text('Area: $area', style: TextStyle(color: Colors
                          .white)),
                    ),
                    ListTile(
                      leading: Icon(
                          Icons.location_searching, color: Colors.white),
                      title: Text(
                          'State: $state', style: TextStyle(color: Colors
                          .white)),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.white),
                      title: Text('Mobile Number: $mobileNumber',
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: panController,
                      decoration: InputDecoration(
                        labelText: 'PAN Number',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter PAN number';
                        }
                        String pattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Invalid PAN number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildImageUploadButton(context, _image, _pickImage),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: fromTimeController,
                      decoration: InputDecoration(
                        labelText: 'Timings From',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter timings';
                        }
                        String pattern = r'^(1[0-2]|0?[1-9]):([0-5][0-9]) ([APap][mM])$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Invalid timings format. Please use hh:mm AM/PM';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: toTimeController,
                      decoration: InputDecoration(
                        labelText: 'Timings To',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter timings';
                        }
                        String pattern = r'^(1[0-2]|0?[1-9]):([0-5][0-9]) ([APap][mM])$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Invalid timings format. Please use hh:mm AM/PM';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildImageUploadButton(BuildContext context, PickedFile? image,
      Function(ImageSource) pickImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        image != null
            ? Image.file(
          File(image.path as String),
          height: 100,
        )
            : ImagePick(
          onImagePicked: (Uint8List? image) {
            // Handle the picked image here
            // You can save it to a variable or perform any other action
          },
        ),
      ],
    );
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
      // Check the file extension to ensure it's either JPEG or PDF
      String extension = _file.path.split('.').last.toLowerCase();
      if (extension == 'jpeg' || extension == 'jpg' || extension == 'pdf') {
        return await _file.readAsBytes();
      } else {
        // Show an error message if the selected file is not JPEG or PDF
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid File Type'),
              content: Text('Please select a JPEG or PDF file.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
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


  