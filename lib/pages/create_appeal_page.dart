import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';

/// Страница создания обращения в акимат.
class CreateAppealPage extends StatefulWidget {
  const CreateAppealPage({super.key});

  @override
  State<CreateAppealPage> createState() => _CreateAppealPageState();
}

class _CreateAppealPageState extends State<CreateAppealPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _contentController = TextEditingController();
  int? _selectedTypeId;
  bool _isLoading = false;
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();
  static const int _maxContentLength = 3500;

  static const List<Map<String, dynamic>> _appealTypes = [
    {'id': 1, 'key': 'complaint'},
    {'id': 2, 'key': 'suggestion'},
    {'id': 3, 'key': 'infoRequest'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  Future<void> _createAppeal() async {
    if (_selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.selectAppealType'.tr())),
      );
      return;
    }

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.enterAppealText'.tr())),
      );
      return;
    }

    if (content.length > _maxContentLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'profile.appealTextMaxLength'.tr(namedArgs: {'max': _maxContentLength.toString()}),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authManager = AuthStateManager();
      final userPhone = authManager.currentUser?.phone ?? '';

      if (userPhone.isEmpty) {
        throw Exception('profile.errors.userPhoneNotAvailable'.tr());
      }

      await _apiService.createAkimatAppeal(
        userPhone: userPhone,
        typeId: _selectedTypeId!,
        content: content,
        akimatId: 6,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.appealCreatedSuccess'.tr()),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error creating akimat appeal: $e');
      if (!mounted) return;
      String message = 'profile.errors.createAppeal'.tr();
      if (e is ApiException) {
        message = e.body?['message']?.toString() ?? e.message;
      } else {
        message = 'profile.errors.createAppealWithError'.tr(namedArgs: {'error': e.toString()});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppHeader(isScrolled: _isScrolled),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile.createAkimatAppealTitle'.tr(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        Text(
                          'profile.appealType'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accordionBorder.withOpacity(0.3),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<int>(
                            value: _selectedTypeId,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: Text(
                              'profile.selectAppealType'.tr(),
                              style: TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            items: _appealTypes.map((t) {
                              final key = t['key'] as String;
                              return DropdownMenuItem<int>(
                                value: t['id'] as int,
                                child: Text(
                                  'profile.appealTypes.$key'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1d1c1a),
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedTypeId = v),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        Text(
                          'profile.appeal'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accordionBorder.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: _contentController,
                            maxLines: 10,
                            maxLength: _maxContentLength,
                            decoration: InputDecoration(
                              hintText: 'profile.enterAppealText'.tr(),
                              hintStyle: TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              counterStyle: TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createAppeal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBackground,
                              disabledBackgroundColor: AppColors.accordionBorder,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'profile.createAppeal'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
