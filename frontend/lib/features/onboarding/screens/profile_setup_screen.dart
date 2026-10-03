import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_expression.dart';
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
    _nameController = TextEditingController(text: user.name);
    _collegeController = TextEditingController(text: user.college);
    _branchController = TextEditingController(text: user.branch);
    _bioController = TextEditingController(text: user.bio);
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
      avatarInitials: initials.isNotEmpty ? initials : 'SB',
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        showAmbientGlow: true,
        showParticles: false,
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
                              color: AppColors.primaryBright,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step 1 of 2: Academic Details',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.softLavender),
                        ),
                        const RikoAvatar(
                          expression: RikoExpression.helpful,
                          size: 26,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Avatar placeholder with initials
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: AppColors.primaryBright, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join()
                                : 'SB',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name Field
                    Text('Your Full Name', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Alex Johnson',
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
                    Text('College / University', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _collegeController,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
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
                    Text('Branch / Department', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _branchController,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
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
                    Text('Academic Year', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedYear,
                      dropdownColor: AppColors.surfaceSecondary,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      items: _yearOptions.map((y) {
                        return DropdownMenuItem(
                          value: y,
                          child: Text(y, style: const TextStyle(color: AppColors.textPrimary)),
                        );
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
                    Text('Student Bio', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Share what you love building, hackathons you enter, or tech topics you are learning...',
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Continue Button
                    AppButton(
                      text: 'Continue to Interests',
                      onPressed: _handleContinue,
                      variant: AppButtonVariant.primary,
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
