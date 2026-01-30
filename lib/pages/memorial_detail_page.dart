import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../models/deceased.dart';
import '../models/memorial.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/app_button.dart';
import '../widgets/header.dart';

class MemorialDetailPage extends StatefulWidget {
  final int memorialId;

  const MemorialDetailPage({super.key, required this.memorialId});

  @override
  State<MemorialDetailPage> createState() => _MemorialDetailPageState();
}

class _MemorialDetailPageState extends State<MemorialDetailPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _epitaphController = TextEditingController();
  final TextEditingController _memoryController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Memorial? _memorial;
  Deceased? _deceased;
  bool _isLoading = true;
  String? _loadError;

  List<String> _photoUrls = [];
  final List<File> _newPhotos = [];
  List<String> _achievementUrls = [];
  final List<File> _newAchievements = [];
  List<String> _videoUrls = [];
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _epitaphController.dispose();
    _memoryController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  void _onScroll() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final memorial = await _apiService.getMemorial(widget.memorialId);
      final deceased = await _apiService.getDeceased(memorial.deceasedId);
      if (!mounted) return;
      setState(() {
        _memorial = memorial;
        _deceased = deceased;
        _photoUrls = List.from(memorial.photoUrls);
        _achievementUrls = List.from(memorial.achievementUrls);
        _videoUrls = List.from(memorial.videoUrls);
        _isPublic = memorial.isPublic;
        _epitaphController.text = memorial.epitaph ?? '';
        _memoryController.text = memorial.aboutPerson ?? '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading memorial detail: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  String _formatDateTime(BuildContext context, String? iso) {
    if (iso == null || iso.isEmpty) return 'profile.emptyValue'.tr();
    try {
      final d = DateTime.parse(iso);
      return DateFormat('dd.MM.yyyy, HH:mm').format(d);
    } catch (_) {
      return iso;
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final picked = await _imagePicker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() => _newPhotos.addAll(picked.map((x) => File(x.path))));
      }
    } catch (e) {
      debugPrint('Error picking photos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('memorialDetail.errors.pickPhotos'.tr())),
        );
      }
    }
  }

  Future<void> _pickAchievements() async {
    try {
      final picked = await _imagePicker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(
          () => _newAchievements.addAll(picked.map((x) => File(x.path))),
        );
      }
    } catch (e) {
      debugPrint('Error picking achievements: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('memorialDetail.errors.pickFiles'.tr())));
      }
    }
  }

  void _deleteAllPhotos() {
    setState(() {
      _photoUrls = [];
      _newPhotos.clear();
    });
  }

  void _addVideoLink() {
    final link = _videoLinkController.text.trim();
    if (link.isEmpty) return;
    setState(() {
      _videoUrls.add(link);
      _videoLinkController.clear();
    });
  }

  void _removeVideoLink(int index) {
    setState(() => _videoUrls.removeAt(index));
  }

  void _removeNewPhoto(int index) {
    setState(() => _newPhotos.removeAt(index));
  }

  void _removeNewAchievement(int index) {
    setState(() => _newAchievements.removeAt(index));
  }

  Future<void> _updateMemorial() async {
    final m = _memorial;
    if (m == null || !m.canEdit) return;

    final user = AuthStateManager().currentUser;
    if (user == null || user.phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('memorialDetail.errors.loginRequired'.tr())));
      }
      return;
    }

    final userPhone = user.phone
        .replaceFirst(RegExp(r'^\+?7'), '')
        .replaceAll(RegExp(r'\D'), '');

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      final photoUrls = List<String>.from(_photoUrls);
      for (final f in _newPhotos) {
        final url = await _apiService.uploadMemorialFile(
          userPhone: userPhone,
          file: f,
          isAchievement: false,
        );
        photoUrls.add(url);
      }

      final achievementUrls = List<String>.from(_achievementUrls);
      for (final f in _newAchievements) {
        final url = await _apiService.uploadMemorialFile(
          userPhone: userPhone,
          file: f,
          isAchievement: true,
        );
        achievementUrls.add(url);
      }

      await _apiService.updateMemorial(
        m.id,
        epitaph: _epitaphController.text.trim(),
        aboutPerson: _memoryController.text.trim(),
        isPublic: _isPublic,
        photoUrls: photoUrls,
        achievementUrls: achievementUrls,
        videoUrls: List.from(_videoUrls),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // закрыть диалог загрузки
      Navigator.of(context).pop(true); // вернуться в профиль, success = true
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('memorialDetail.errors.generic'.tr(namedArgs: {'message': e.message}))));
      }
    } catch (e) {
      debugPrint('Error updating memorial: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('memorialDetail.errors.genericDetail'.tr(namedArgs: {'error': e.toString()}))));
      }
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
                AppHeader(isScrolled: false),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _loadError != null
                      ? _buildError()
                      : _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'memorialDetail.loadError'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              _loadError ?? '',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.accordionBorder,
                fontFamily: 'Manrope',
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            AppButton(
              text: 'memorialDetail.retry'.tr(),
              onPressed: _loadData,
              backgroundColor: AppColors.buttonBackground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final m = _memorial!;
    final canEdit = m.canEdit;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'memorialDetail.memorialId'.tr(namedArgs: {'id': m.id.toString()}),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('memorialDetail.shareInDevelopment'.tr())),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildInfoCard(m),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildPhotosSection(canEdit),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildEpitaphSection(canEdit),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildMemorySection(canEdit),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildPublicToggle(canEdit),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildAchievementsSection(canEdit),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildVideoSection(canEdit),
          if (canEdit) ...[
            const SizedBox(height: AppSizes.paddingXLarge),
            AppButton(
              text: 'memorialDetail.updateMemorial'.tr(),
              onPressed: _updateMemorial,
              backgroundColor: AppColors.buttonBackground,
            ),
          ],
          const SizedBox(height: AppSizes.paddingMedium),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Memorial m) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'memorialDetail.infoTitle'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _infoRow('memorialDetail.creator'.tr(), m.creatorPhone),
          if (_deceased != null) _infoRow('memorialDetail.deceased'.tr(), _deceased!.fullName),
          _infoRow('memorialDetail.visibility'.tr(), m.isPublic ? 'memorialDetail.public'.tr() : 'memorialDetail.private'.tr()),
          _infoRow('memorialDetail.lastUpdated'.tr(), _formatDateTime(context, m.updatedAt)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.accordionBorder,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(bool canEdit) {
    final existingCount = _photoUrls.length;
    final newCount = _newPhotos.length;
    final total = existingCount + newCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'memorialDetail.uploadedPhotos'.tr(namedArgs: {'count': total.toString()}),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
            ),
            if (canEdit && total > 0)
              TextButton(
                onPressed: _deleteAllPhotos,
                child: Text(
                  'memorialDetail.deleteAll'.tr(),
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Wrap(
          spacing: AppSizes.paddingSmall,
          runSpacing: AppSizes.paddingSmall,
          children: [
            ..._photoUrls.asMap().entries.map(
              (e) => _photoPreview(
                url: e.value,
                label: '${e.key + 1}',
                isExisting: true,
              ),
            ),
            ..._newPhotos.asMap().entries.map(
              (e) => _photoPreview(
                file: e.value,
                label: '${_photoUrls.length + e.key + 1}',
                isExisting: false,
                onRemove: canEdit ? () => _removeNewPhoto(e.key) : null,
              ),
            ),
          ],
        ),
        if (canEdit) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          GestureDetector(
            onTap: _pickPhotos,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accordionBorder.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(
                  'memorialDetail.addMorePhotos'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _photoPreview({
    String? url,
    File? file,
    required String label,
    required bool isExisting,
    VoidCallback? onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExisting
                  ? const Color(0xFF0D7377)
                  : AppColors.accordionBorder,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                  errorBuilder: (_, __, ___) => _placeholder(label),
                )
              : file != null
              ? Image.file(file, fit: BoxFit.cover, width: 120, height: 120)
              : _placeholder(label),
        ),
        if (isExisting)
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D7377),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'memorialDetail.existing'.tr(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ),
          ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder(String label) {
    return Center(
      child: Text(
        'memorialDetail.preview'.tr(namedArgs: {'label': label}),
        style: TextStyle(
          fontSize: 12,
          color: AppColors.accordionBorder,
          fontFamily: 'Manrope',
        ),
      ),
    );
  }

  Widget _buildEpitaphSection(bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'memorialDetail.epitaph'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        TextField(
          controller: _epitaphController,
          maxLines: 5,
          readOnly: !canEdit,
          decoration: _inputDecoration('memorialDetail.epitaphHint'.tr()),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  Widget _buildMemorySection(bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'memorialDetail.memoryAbout'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        TextField(
          controller: _memoryController,
          maxLines: 8,
          readOnly: !canEdit,
          decoration: _inputDecoration('memorialDetail.memoryHint'.tr()),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.accordionBorder,
        fontFamily: 'Manrope',
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.accordionBorder.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.buttonBackground),
      ),
    );
  }

  Widget _buildPublicToggle(bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: _isPublic,
              onChanged: canEdit ? (v) => setState(() => _isPublic = v) : null,
              activeThumbColor: AppColors.buttonBackground,
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            Expanded(
              child: Text(
                'memorialDetail.publicPerson'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          ],
        ),
        if (!_isPublic) ...[
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'memorialDetail.privateMemorialNote'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAchievementsSection(bool canEdit) {
    final total = _achievementUrls.length + _newAchievements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'memorialDetail.achievements'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        if (canEdit)
          GestureDetector(
            onTap: _pickAchievements,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingXLarge),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accordionBorder.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 48,
                    color: AppColors.buttonBackground,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    'memorialDetail.uploadFilesOrDrag'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (total > 0) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            'memorialDetail.achievementPhotos'.tr(namedArgs: {'count': total.toString()}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Wrap(
            spacing: AppSizes.paddingSmall,
            runSpacing: AppSizes.paddingSmall,
            children: [
              ..._achievementUrls.asMap().entries.map(
                (e) => _achievementPreview(
                  url: e.value,
                  label: 'memorialDetail.achievementPhotoLabel'.tr(),
                  isExisting: true,
                ),
              ),
              ..._newAchievements.asMap().entries.map(
                (e) => _achievementPreview(
                  file: e.value,
                  label: 'memorialDetail.achievementPhotoLabel'.tr(),
                  isExisting: false,
                  onRemove: canEdit ? () => _removeNewAchievement(e.key) : null,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _achievementPreview({
    String? url,
    File? file,
    required String label,
    required bool isExisting,
    VoidCallback? onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExisting
                  ? const Color(0xFF0D7377)
                  : AppColors.accordionBorder,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) => _placeholder(label),
                )
              : file != null
              ? Image.file(file, fit: BoxFit.cover, width: 100, height: 100)
              : _placeholder(label),
        ),
        if (isExisting)
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D7377),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'memorialDetail.existing'.tr(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ),
          ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoSection(bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'memorialDetail.videos'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _videoLinkController,
                readOnly: !canEdit,
                decoration: _inputDecoration('memorialDetail.youtubeLinkHint'.tr()),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            ElevatedButton(
              onPressed: canEdit ? _addVideoLink : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7377),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'memorialDetail.add'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            ElevatedButton(
              onPressed: canEdit ? () => _videoLinkController.clear() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'memorialDetail.cancel'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          ],
        ),
        if (_videoUrls.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          ..._videoUrls.asMap().entries.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accordionBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1d1c1a),
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeVideoLink(e.key),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
