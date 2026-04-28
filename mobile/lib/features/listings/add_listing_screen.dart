import 'dart:io';

import 'package:binabroker/app/theme.dart';
import 'package:binabroker/shared/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final rentController = TextEditingController();
  final sqftController = TextEditingController();
  final bedroomController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  final picker = ImagePicker();
  final images = <XFile>[];

  int step = 0;
  bool loading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    rentController.dispose();
    sqftController.dispose();
    bedroomController.dispose();
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 80);
    setState(() => images.addAll(picked));
  }

  Future<List<String>> uploadImages(String userId) async {
    final urls = <String>[];

    for (final image in images) {
      final bytes = await image.readAsBytes();
      final safeName = image.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await supabase.storage.from('listing-images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: false),
          );

      urls.add(supabase.storage.from('listing-images').getPublicUrl(path));
    }

    return urls;
  }

  bool validateCurrentStep() {
    if (step == 0) {
      return titleController.text.trim().isNotEmpty &&
          descriptionController.text.trim().isNotEmpty &&
          int.tryParse(rentController.text.trim()) != null;
    }

    if (step == 1) {
      return int.tryParse(sqftController.text.trim()) != null &&
          int.tryParse(bedroomController.text.trim()) != null;
    }

    if (step == 2) {
      return images.isNotEmpty;
    }

    return true;
  }

  void nextStep() {
    if (!validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete the required fields.')),
      );
      return;
    }

    setState(() => step += 1);
  }

  Future<void> submit() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'phone': user.phone,
        'role': 'landlord',
      });

      final uploadedUrls = await uploadImages(user.id);

      await supabase.from('listings').insert({
        'landlord_id': user.id,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'rent_amount': int.parse(rentController.text.trim()),
        'area_sqft': int.tryParse(sqftController.text.trim()),
        'bedrooms': int.tryParse(bedroomController.text.trim()),
        'location_lat': double.tryParse(latController.text.trim()),
        'location_lng': double.tryParse(lngController.text.trim()),
        'images': uploadedUrls,
        'contact_phone': user.phone,
        'status': 'pending',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing submitted for review.')),
      );
      context.go('/');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DetailsStep(
        titleController: titleController,
        descriptionController: descriptionController,
        rentController: rentController,
      ),
      _SpecsStep(
        sqftController: sqftController,
        bedroomController: bedroomController,
        latController: latController,
        lngController: lngController,
      ),
      _ImagesStep(images: images, onPick: pickImages),
      _ReviewStep(
        title: titleController.text.trim(),
        rent: rentController.text.trim(),
        imagesCount: images.length,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Step ${step + 1} of ${pages.length}',
              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (step + 1) / pages.length,
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
            ),
            const SizedBox(height: 28),
            pages[step],
            const SizedBox(height: 28),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loading ? null : () => setState(() => step -= 1),
                      child: const Text('Back'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : (step == pages.length - 1 ? submit : nextStep),
                    child: Text(
                      loading ? 'Submitting...' : (step == pages.length - 1 ? 'Submit for Review' : 'Continue'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsStep extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController rentController;

  const _DetailsStep({
    required this.titleController,
    required this.descriptionController,
    required this.rentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Property details', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
        const SizedBox(height: 14),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: rentController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monthly rent'),
        ),
      ],
    );
  }
}

class _SpecsStep extends StatelessWidget {
  final TextEditingController sqftController;
  final TextEditingController bedroomController;
  final TextEditingController latController;
  final TextEditingController lngController;

  const _SpecsStep({
    required this.sqftController,
    required this.bedroomController,
    required this.latController,
    required this.lngController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Specs and location', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        TextField(
          controller: sqftController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Area sqft'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: bedroomController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Bedrooms'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: lngController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagesStep extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPick;

  const _ImagesStep({required this.images, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Photos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.image_outlined),
          label: Text('Pick images (${images.length})'),
        ),
        const SizedBox(height: 16),
        if (images.isNotEmpty)
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(images[index].path),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String title;
  final String rent;
  final int imagesCount;

  const _ReviewStep({required this.title, required this.rent, required this.imagesCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review submission', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('৳$rent/month', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('$imagesCount image(s) selected', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 14),
          const Text(
            'Your listing will remain pending until moderation approval.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
