import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../data/models/user_profile.dart';

/// Step 1 of onboarding: Setup student academic profile.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _collegeController;
  late final TextEditingController _branchController;
  late final TextEditingController _bioController;
  String _selectedYear = 'Year 3';

  final List<String> _yearOptions = ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Postgraduate', 'Alumnus'];

  @override
  void initState() {
    super.initState();
    final user = AppServices.auth.currentUser ?? UserProfile.defaultDemo();
    _nameController = TextEditingController(text: user.name.isNotEmpty ? user.name : 'Sandeep B');
    _collegeController = TextEditingController(text: user.college.isNotEmpty ? user.college : 'KPR Institute of Engineering and Technology');
    _branchController = TextEditingController(text: user.branch.isNotEmpty ? user.branch : 'Computer Science & Engineering');
    _bioController = TextEditingController(text: user.bio.isNotEmpty ? user.bio : 'Passionate student developer focused on cybersecurity and scalable full-stack applications.');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AppServices.auth.currentUser ?? UserProfile.defaultDemo();
    final initials = _nameController.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();

    final updated = user.copyWith(
      name: _nameController.text.trim(),
      college: _collegeController.text.trim(),
      branch: _branchController.text.trim(),
      year: _selectedYear,
      bio: _bioController.text.trim(),
      avatarInitials: initials.isNotEmpty ? initials : 'SU',
    );

    await AppServices.auth.updateProfile(updated);
    if (!mounted) return;

    Navigator.of(context).pushNamed(AppRoutes.interestSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Setup Student Profile'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Step 1 of 2: Academic Details',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryDark),
                    ),

                    const SizedBox(height: 20),

                    // Avatar placeholder with initials
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join()
                                    : 'SU',
                                style: const TextStyle(
                                  color: AppColors.textInverse,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name Field
                    Text('Your Full Name', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Sandeep B',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // College Name Field
                    Text('College / University', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _collegeController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. KPR Institute of Engineering and Technology',
                        prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your college name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Branch & Department Field
                    Text('Branch / Department', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _branchController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Computer Science & Engineering',
                        prefixIcon: Icon(Icons.school_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your department';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Year Dropdown
                    Text('Academic Year', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedYear,
                      items: _yearOptions.map((y) {
                        return DropdownMenuItem(value: y, child: Text(y));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedYear = val);
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bio Field
                    Text('Student Bio', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Share what you love building, hackathons you enter, or tech topics you are learning...',
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Continue Button
                    ElevatedButton(
                      onPressed: _handleContinue,
                      child: const Text('Continue to Interests', style: AppTextStyles.labelLarge),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
