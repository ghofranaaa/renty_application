import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:renty/services/post_services.dart';
import 'package:renty/models/post.dart';

class PostCreationScreen extends StatefulWidget {
  final Function(bool) onPostCreated;

  const PostCreationScreen({super.key, required this.onPostCreated});

  @override
  _PostCreationScreenState createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  String? selectedCategory;
  String? selectedStatus;

  // List of available categories and status options
  final List<String> categories = ['Guitar', 'Violin', 'Piano', 'Drums'];
  final List<String> statusOptions = ['for sale', 'for rental'];

  // Form fields controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Handle image selection from gallery
  Future<void> _pickImage() async {
    final pickedImages = await _picker.pickMultiImage();
    setState(() {
      _images.addAll(pickedImages);
        });
  }

  // Modern Input Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isNumber = false,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Color(0xFFFF9100)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isOptional ? null : 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Category Dropdown Widget
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: const Icon(Icons.category, color: Color(0xFFFF9100)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        items: categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedCategory = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }

  // Status Dropdown Widget
  Widget _buildStatusDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedStatus,
        decoration: InputDecoration(
          labelText: 'Status',
          prefixIcon: const Icon(Icons.info, color: Color(0xFFFF9100)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        items: statusOptions.map((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedStatus = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a status';
          }
          return null;
        },
      ),
    );
  }

  // Form Submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator while the post is being created
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {

        // Call the API to create a post with the uploaded images
        final Post response = await CreatePostService.createPost(
          instrumentType: selectedCategory!,
          title: _titleController.text,
          brand: _brandController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : '',
          phoneNumber: _phoneNumberController.text,
          image: _images.isNotEmpty ? _images[0].path : '', // Make image optional here          status: selectedStatus!,
          location: _locationController.text, status: '',
        );
        debugPrint(response.toString());

        // Close the loading indicator
        Navigator.of(context).pop();

        // Handle API response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        widget.onPostCreated(true);

        // Navigate back to the previous screen (e.g., Home) and refresh the post list
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } catch (e) {
        Navigator.of(context).pop();  // Ensure loading indicator is closed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Color(0xFFf8f2ea),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _submitForm,
              child: const Text(
                'Publish',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Section
                Container(
                  width: double.infinity, // Make it stretch to full width
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _images.isEmpty
                      ? Center(
                        child: InkWell(
                          onTap: _pickImage,
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add_a_photo_outlined, color: Color(0xFFFF9100), size: 60),
                            SizedBox(height: 8),
                        ],
                      ),
                    )
                  )
                : CarouselSlider(
                    items: _images.map((image) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _images.remove(image);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 150,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCategoryDropdown(),
                const SizedBox(height: 15),
                _buildTextField(controller: _titleController, label: 'Title', hintText: 'Enter title', icon: Icons.title),
                const SizedBox(height: 15),
                _buildTextField(controller: _brandController, label: 'Brand', hintText: 'Enter brand', icon: Icons.branding_watermark),
                const SizedBox(height: 15),
                _buildTextField(controller: _priceController, label: 'Price', hintText: 'Enter price', icon: Icons.price_check, isNumber: true),
                const SizedBox(height: 15),
                _buildTextField(controller: _descriptionController, label: 'Description', hintText: 'Enter description', icon: Icons.description, isOptional: true),
                const SizedBox(height: 15),
                _buildTextField(controller: _phoneNumberController, label: 'Phone Number', hintText: 'Enter phone number', icon: Icons.phone, isNumber: true),
                const SizedBox(height: 15),
                _buildStatusDropdown(),
                const SizedBox(height: 15),
                _buildTextField(controller: _locationController, label: 'Location', hintText: 'Enter location', icon: Icons.location_on),
                const SizedBox(height: 20),
          ]
          ),
          ),
        ),
      ),
    );
  }
}
