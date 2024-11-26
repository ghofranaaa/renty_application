import 'package:flutter/material.dart';
import 'package:renty/models/post.dart';

import '../../services/user_posts_service.dart';


class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _locationController;

  late InstrumentType _instrumentType;
  late Availability _availability;
  late PostStatus _status;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize text controllers with post values
    _brandController = TextEditingController(text: widget.post.brand);
    _titleController = TextEditingController(text: widget.post.title);
    _priceController = TextEditingController(text: widget.post.price.toString());
    _descriptionController = TextEditingController(text: widget.post.description ?? '');
    _phoneNumberController = TextEditingController(text: widget.post.phoneNumber);
    _locationController = TextEditingController(text: widget.post.location);

    // Initialize dropdown values with post values
    _instrumentType = widget.post.instrumentType;
    _availability = widget.post.availability;
    _status = widget.post.status;
  }

  @override
  void dispose() {
    // Dispose controllers
    _brandController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // Create an updated Post object
        final updatedPost = Post(
          id: widget.post.id,
          instrumentType: _instrumentType,
          brand: _brandController.text,
          title: _titleController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          phoneNumber: _phoneNumberController.text,
          image: widget.post.image, // Assuming the image remains unchanged
          availability: _availability,
          status: _status,
          location: _locationController.text, userId: '',
        );

        // Call the API to update the post
        final success = await UserPostsService.updatePost(
          updatedPost,
          postId: widget.post.id,
          instrumentType: _instrumentType.name,
          title: _titleController.text,
          brand: _brandController.text,
          price: double.tryParse(_priceController.text),
          phoneNumber: _phoneNumberController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          image: widget.post.image,
          status: _status == PostStatus.forSale ? 'for sale' : 'for rental', // Explicitly convert status
          location: _locationController.text,
          availability: _availability.name,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post updated successfully!')),
          );
          Navigator.of(context).pop(updatedPost); // Return updated data
        } else {
          throw Exception('Failed to update post');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: $error')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f2ea),
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _saveChanges,
            icon: const Icon(
                Icons.save,
                color: Color(0xFF00712d),
            ),
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Instrument Type Dropdown
              DropdownButtonFormField<InstrumentType>(
                value: _instrumentType,
                decoration: const InputDecoration(labelText: 'Instrument Type'),
                items: InstrumentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _instrumentType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Brand
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Brand cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price cannot be empty';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.isEmpty ? 'Phone number cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              // Availability Dropdown
              DropdownButtonFormField<Availability>(
                value: _availability,
                decoration: const InputDecoration(labelText: 'Availability'),
                items: Availability.values.map((availability) {
                  return DropdownMenuItem(
                    value: availability,
                    child: Text(availability.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _availability = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<PostStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: PostStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Location cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              // Save Changes Button
              ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  // Add this to change the text color
                  foregroundColor: Colors.white, // Text color
                  backgroundColor: Color(0xFF00712d), // Optional: background color to match your theme
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
