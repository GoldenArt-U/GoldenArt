import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/services/firestore_service.dart';
import 'package:artisan_market/services/storage_service.dart';
import 'package:artisan_market/utils/constants.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  String _selectedCategory = 'Poterie';
  final List<String> _categories = [
    'Poterie', 'Tissage', 'Bijoux', 'Cuir', 'Broderie', 'Bois'
  ];

  Uint8List? _imageBytes;
  String? _imageMimeType;
  bool _isLoading = false;
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageMimeType = pickedFile.mimeType ?? 'image/jpeg';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ajouter une photo de l\'œuvre.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      
      // We need to generate an ID before uploading the image so we can name the file, 
      // OR we can just use a timestamp.
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 1. Upload Image
      final imageUrl = await _storageService.uploadProductImage(
        productId: tempId,
        imageBytes: _imageBytes!,
        mimeType: _imageMimeType!,
      );

      // 2. Save Product
      await _firestoreService.addProduct(
        userId: auth.userId,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        price: double.parse(_priceCtrl.text),
        category: _selectedCategory,
        imageUri: imageUrl,
        isOneOfAKind: true, // Always true for this marketplace
      );

      if (mounted) {
        Navigator.pop(context); // Go back to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Œuvre publiée avec succès !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text('New 1-of-1 Listing', style: AppTextStyles.heading3),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    Text('Artwork Photo', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                          image: _imageBytes != null 
                              ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageBytes == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textMedium),
                                  const SizedBox(height: 8),
                                  Text('Click to upload high-res photo', style: AppTextStyles.bodyMedium),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text('Title', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Vase en Céramique Ancien',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Price
                    Text('Price (TND)', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '0.00',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Category
                    Text('Category', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description & Provenance
                    Text('Provenance & Details', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Describe the materials, history, and authenticity details of this unique piece...',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        ),
                        child: Text('Publish 1-of-1 Artwork', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
