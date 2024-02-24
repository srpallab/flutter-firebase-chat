import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePicker extends StatefulWidget {
  const AppImagePicker({super.key, required this.onImagePicked});
  final void Function(File imageFile) onImagePicked;

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  File? imageFile;
  Future<void> pickImage() async {
    final XFile? imageXFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (imageXFile == null) return;

    setState(() {
      imageFile = File(imageXFile.path);
    });

    widget.onImagePicked(imageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: imageFile != null ? FileImage(imageFile!) : null,
        ),
        TextButton.icon(
          onPressed: pickImage,
          icon: const Icon(Icons.upload),
          label: Text(
            "Upload a Avater",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        )
      ],
    );
  }
}
