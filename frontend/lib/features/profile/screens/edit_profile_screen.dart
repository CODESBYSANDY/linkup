import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/user_profile.dart';

/// Screen allowing the student to edit their local profile information.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _collegeController;
  late final TextEditingController _branchController;
  late final TextEditingController _bioController;
  late final TextEditingController _skillsController;
  late String _selectedYear;

  final List<String> _yearOptions = ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Postgraduate', 'Alumnus'];

  @override
  void initState() {
    super.initState();
    final user = AppServices.auth.currentUser ?? UserProfile.defaultDemo();
    _nameController = TextEditingController(text: user.name);
    _collegeController = TextEditingController(text: user.college);
    _branchController = TextEditingController(text: user.branch);
    _bioController = TextEditingController(text: user.bio);
    _skillsController = TextEditingController(text: user.skills.join(', '));
    _selectedYear = _yearOptions.contains(user.year) ? user.year : 'Year 3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AppServices.auth.currentUser ?? UserProfile.defaultDemo();
    final initials = _nameController.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final updated = user.copyWith(
      name: _nameController.text.trim(),
      college: _collegeController.text.trim(),
      branch: _branchController.text.trim(),
      year: _selectedYear,
      bio: _bioController.text.trim(),
      skills: skillsList,
      avatarInitials: initials.isNotEmpty ? initials : 'SU',
    );

    await AppServices.auth.updateProfile(updated);
    if (!mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully! ✨'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('Save', style: AppTextStyles.labelLarge),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar preview
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join()
                            : 'SU',
                        style: const TextStyle(
                          color: AppColors.textInverse,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name
                Text('Full Name', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
                ),

                const SizedBox(height: 16),

                // College
                Text('College / University', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(controller: _collegeController),

                const SizedBox(height: 16),

                // Branch
                Text('Branch / Major', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(controller: _branchController),

                const SizedBox(height: 16),

                // Year
                Text('Year of Study', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedYear,
                  items: _yearOptions.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedYear = val);
                  },
                ),

                const SizedBox(height: 16),

                // Skills
                Text('Skills (comma separated)', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(controller: _skillsController),

                const SizedBox(height: 16),

                // Bio
                Text('Bio', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _handleSave,
                  child: const Center(child: Text('Save Profile Changes', style: AppTextStyles.labelLarge)),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
