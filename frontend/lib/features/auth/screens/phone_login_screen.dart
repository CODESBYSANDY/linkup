import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/services/app_services.dart';
import '../widgets/auth_top_bar.dart';
import '../widgets/riko_auth_background.dart';

/// Country code data item
class CountryCodeItem {
  final String name;
  final String code;
  final String flag;

  const CountryCodeItem({
    required this.name,
    required this.code,
    required this.flag,
  });
}

/// Phone Number Input Screen for Firebase Phone Authentication.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  static const List<CountryCodeItem> _popularCountries = [
    CountryCodeItem(name: 'India', code: '+91', flag: '🇮🇳'),
    CountryCodeItem(name: 'United States', code: '+1', flag: '🇺🇸'),
    CountryCodeItem(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
    CountryCodeItem(name: 'Singapore', code: '+65', flag: '🇸🇬'),
    CountryCodeItem(name: 'Australia', code: '+61', flag: '🇦🇺'),
    CountryCodeItem(name: 'Germany', code: '+49', flag: '🇩🇪'),
    CountryCodeItem(name: 'Canada', code: '+1', flag: '🇨🇦'),
    CountryCodeItem(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪'),
  ];

  CountryCodeItem _selectedCountry = const CountryCodeItem(
    name: 'India',
    code: '+91',
    flag: '🇮🇳',
  );

  static const Color navy = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color teal = Color(0xFF0D9488);
  static const Color border = Color(0xFFE2E8F0);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Country Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: border),
              Expanded(
                child: ListView.separated(
                  itemCount: _popularCountries.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: border),
                  itemBuilder: (context, index) {
                    final item = _popularCountries[index];
                    final isSelected = item.code == _selectedCountry.code && item.name == _selectedCountry.name;

                    return ListTile(
                      leading: Text(
                        item.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? teal : navy,
                        ),
                      ),
                      trailing: Text(
                        item.code,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? teal : muted,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = item;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSendOtp() async {
    FocusScope.of(context).unfocus();

    final rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    if (rawPhone.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your phone number.';
      });
      return;
    }

    if (rawPhone.length < 7 || rawPhone.length > 15) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhoneNumber = '${_selectedCountry.code}$rawPhone';

    try {
      await AppServices.auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });

          Navigator.of(context).pushNamed(
            AppRoutes.otpVerification,
            arguments: {
              'phoneNumber': fullPhoneNumber,
              'verificationId': verificationId,
              'resendToken': resendToken,
            },
          );
        },
        onError: (errorMessage) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = errorMessage;
          });
        },
        onAutoVerified: (verificationId) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.main,
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to send code. Please verify your phone number.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      resizeToAvoidBottomInset: true,
      body: RikoAuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                AuthTopBar(
                  onBack: () => Navigator.of(context).maybePop(),
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // Phone Icon Badge
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: teal.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: teal.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.phone_iphone_rounded,
                                size: 26,
                                color: teal,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Heading
                          const Text(
                            "What's your phone number?",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: navy,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            'Enter your mobile number to receive a secure 6-digit verification code.',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: muted,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Phone Input Card / Row
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _errorMessage != null ? const Color(0xFFEF4444) : border,
                                width: _errorMessage != null ? 1.5 : 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x060F172A),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Country Code Selector
                                InkWell(
                                  onTap: _isLoading ? null : _showCountryPicker,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    child: Row(
                                      children: [
                                        Text(
                                          _selectedCountry.flag,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _selectedCountry.code,
                                          style: const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            color: navy,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                          color: muted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Divider between country code & phone number
                                Container(
                                  height: 28,
                                  width: 1,
                                  color: border,
                                ),

                                // Phone number text field
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    enabled: !_isLoading,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: navy,
                                      letterSpacing: 0.5,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '98765 43210',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    ),
                                    onSubmitted: (_) => _handleSendOtp(),
                                    onChanged: (_) {
                                      if (_errorMessage != null) {
                                        setState(() {
                                          _errorMessage = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Error Message if any
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Send Verification Code CTA Button
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teal,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: teal.withValues(alpha: 0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Sending code...',
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Send Verification Code',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Standard Rates Disclaimer
                          const Center(
                            child: Text(
                              'Standard SMS carrier rates may apply.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
