import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../constants.dart';
import '../models/cemetery.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../services/cemetery_service.dart';
import '../widgets/header.dart';
import '../widgets/app_button.dart';

enum _FileType { deathCertificate, kinshipConfirmation, graveDocument }

/// Страница создания заявки на перезахоронение.
class CreateReburialRequestPage extends StatefulWidget {
  const CreateReburialRequestPage({super.key});

  @override
  State<CreateReburialRequestPage> createState() =>
      _CreateReburialRequestPageState();
}

class _CreateReburialRequestPageState extends State<CreateReburialRequestPage> {
  final ApiService _apiService = ApiService();
  final CemeteryService _cemeteryService = CemeteryService();
  final TextEditingController _reasonController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  List<Cemetery> _cemeteries = [];
  Cemetery? _oldCemetery;
  Cemetery? _newCemetery;
  File? _deathCertificateFile;
  File? _kinshipConfirmationFile;
  File? _graveDocumentFile;
  bool _isLoadingCemeteries = true;
  bool _isSubmitting = false;
  bool _isScrolled = false;
  static const int _maxReasonLength = 500;

  @override
  void initState() {
    super.initState();
    _loadCemeteries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  Future<void> _loadCemeteries() async {
    try {
      final cemeteries = await _cemeteryService.getCemeteries();
      if (mounted) {
        setState(() {
          _cemeteries = cemeteries;
          _isLoadingCemeteries = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading cemeteries: $e');
      if (mounted) {
        setState(() => _isLoadingCemeteries = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'profile.errors.loadCemeteries'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickFile(_FileType type) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (file != null && mounted) {
        setState(() {
          switch (type) {
            case _FileType.deathCertificate:
              _deathCertificateFile = File(file.path);
              break;
            case _FileType.kinshipConfirmation:
              _kinshipConfirmationFile = File(file.path);
              break;
            case _FileType.graveDocument:
              _graveDocumentFile = File(file.path);
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        String errorMessage = 'profile.errors.filePick'.tr();
        if (e.toString().contains('channel-error') ||
            e.toString().contains('Unable to establish connection')) {
          errorMessage = 'profile.errors.galleryOpen'.tr();
        } else if (e.toString().contains('permission')) {
          errorMessage = 'profile.errors.galleryPermission'.tr();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  void _removeFile(_FileType type) {
    setState(() {
      switch (type) {
        case _FileType.deathCertificate:
          _deathCertificateFile = null;
          break;
        case _FileType.kinshipConfirmation:
          _kinshipConfirmationFile = null;
          break;
        case _FileType.graveDocument:
          _graveDocumentFile = null;
          break;
      }
    });
  }

  Widget _buildFileUploadSection({
    required String title,
    required File? file,
    required VoidCallback onPickFile,
    required VoidCallback onRemoveFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        if (file != null)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file, color: AppColors.iconAndText, size: 24),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.path.split(RegExp(r'[/\\]')).last,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1d1c1a),
                          fontFamily: 'Manrope',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accordionBorder,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.iconAndText,
                  onPressed: onRemoveFile,
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: onPickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingXLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accordionBorder.withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, size: 48, color: AppColors.accordionBorder),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'profile.uploadFiles'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'profile.uploadFilesHint'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.accordionBorder,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  AppButton(text: 'profile.upload'.tr(), onPressed: onPickFile, isOutlined: true),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _submitRequest() async {
    if (_oldCemetery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.selectOldBurialPlace'.tr())),
      );
      return;
    }
    if (_newCemetery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.selectNewBurialPlace'.tr())),
      );
      return;
    }
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.enterReburialReason'.tr())),
      );
      return;
    }
    if (_deathCertificateFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.uploadDeathCertificate'.tr())),
      );
      return;
    }
    if (_kinshipConfirmationFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.uploadKinshipConfirmation'.tr())),
      );
      return;
    }
    if (_graveDocumentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.errors.uploadGraveDocument'.tr())),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authManager = AuthStateManager();
      final user = authManager.currentUser;
      final userPhone = (user?.phone ?? '').replaceAll(RegExp(r'\D'), '');
      if (userPhone.isEmpty) {
        throw Exception('profile.errors.userPhoneNotAvailable'.tr());
      }

      final deathCertificateUrl =
          await _apiService.uploadAkimatFile(_deathCertificateFile!);
      final proofOfRelationUrl =
          await _apiService.uploadAkimatFile(_kinshipConfirmationFile!);
      final graveDocUrl = await _apiService.uploadAkimatFile(_graveDocumentFile!);

      await _apiService.createReburialRequest(
        userPhone: userPhone,
        fromBurialId: _oldCemetery!.id,
        toBurialId: _newCemetery!.id,
        reason: reason,
        foreignCemetry: '',
        akimatId: 6,
        deathCertificate: deathCertificateUrl,
        proofOfRelation: proofOfRelationUrl,
        graveDoc: graveDocUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.reburialRequestCreatedSuccess'.tr()),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error creating reburial request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'profile.errors.createRequest'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                          'profile.createReburialTitle'.tr(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1d1c1a),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        Text(
                          'profile.oldBurialPlace'.tr(),
                          style: const TextStyle(
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
                          child: DropdownButton<Cemetery>(
                            value: _oldCemetery,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: Text(
                              'profile.selectCemetery'.tr(),
                              style: const TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            items: _cemeteries
                                .map((c) => DropdownMenuItem<Cemetery>(
                                      value: c,
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: _isLoadingCemeteries
                                ? null
                                : (v) => setState(() => _oldCemetery = v),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        Text(
                          'profile.newBurialPlace'.tr(),
                          style: const TextStyle(
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
                          child: DropdownButton<Cemetery>(
                            value: _newCemetery,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: Text(
                              'profile.selectCemetery'.tr(),
                              style: const TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            items: _cemeteries
                                .map((c) => DropdownMenuItem<Cemetery>(
                                      value: c,
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1d1c1a),
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: _isLoadingCemeteries
                                ? null
                                : (v) => setState(() => _newCemetery = v),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        Text(
                          'profile.reason'.tr(),
                          style: const TextStyle(
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
                            controller: _reasonController,
                            maxLines: 5,
                            maxLength: _maxReasonLength,
                            decoration: InputDecoration(
                              hintText: 'profile.reasonHint'.tr(),
                              hintStyle: const TextStyle(
                                color: AppColors.accordionBorder,
                                fontFamily: 'Manrope',
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              counterStyle: const TextStyle(
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
                        _buildFileUploadSection(
                          title: 'profile.deathCertificate'.tr(),
                          file: _deathCertificateFile,
                          onPickFile: () => _pickFile(_FileType.deathCertificate),
                          onRemoveFile: () => _removeFile(_FileType.deathCertificate),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        _buildFileUploadSection(
                          title: 'profile.kinshipConfirmation'.tr(),
                          file: _kinshipConfirmationFile,
                          onPickFile: () => _pickFile(_FileType.kinshipConfirmation),
                          onRemoveFile: () => _removeFile(_FileType.kinshipConfirmation),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        _buildFileUploadSection(
                          title: 'profile.graveDocument'.tr(),
                          file: _graveDocumentFile,
                          onPickFile: () => _pickFile(_FileType.graveDocument),
                          onRemoveFile: () => _removeFile(_FileType.graveDocument),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSubmitting
                                  ? AppColors.accordionBorder
                                  : AppColors.buttonBackground,
                              disabledBackgroundColor: AppColors.accordionBorder,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'profile.createReburialRequest'.tr(),
                                    style: const TextStyle(
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
