import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../widgets/header.dart';
import '../models/burial_request.dart';
import '../widgets/app_button.dart';
import 'package:image_picker/image_picker.dart';

class CreateMemorialPage extends StatefulWidget {
  final int? burialRequestId;

  const CreateMemorialPage({super.key, this.burialRequestId});

  @override
  State<CreateMemorialPage> createState() => _CreateMemorialPageState();
}

class _CreateMemorialPageState extends State<CreateMemorialPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  BurialRequest? _burialRequest;
  bool _isLoading = true;

  final TextEditingController _epitaphController = TextEditingController();
  final TextEditingController _memoryController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();

  bool _isPublic = false;
  final List<File> _photos = [];
  final List<File> _achievements = [];
  final List<String> _videoLinks = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadBurialRequest();
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
    final bool isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }

  Future<void> _loadBurialRequest() async {
    // Если burialRequestId не передан, пропускаем загрузку
    if (widget.burialRequestId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _apiService.getBurialRequestById(
        widget.burialRequestId!,
      );

      if (response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        setState(() {
          _burialRequest = BurialRequest.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading burial request: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
      }
    }
  }

  void _addVideoLink() {
    final link = _videoLinkController.text.trim();
    if (link.isNotEmpty) {
      setState(() {
        _videoLinks.add(link);
        _videoLinkController.clear();
      });
    }
  }

  void _removeVideoLink(int index) {
    setState(() {
      _videoLinks.removeAt(index);
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Верхняя SafeArea белого цвета
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).padding.top,
            ),
          ),
          // Основной контент
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Хэдер
                AppHeader(isScrolled: _isScrolled),
                // Контент
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _burialRequest == null
                      ? const Center(
                          child: Text(
                            'Заявка не найдена',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1d1c1a),
                              fontFamily: 'Manrope',
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Заголовок с именем и иконкой поделиться
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _burialRequest!.deceased.fullName,
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
                                      // TODO: Реализовать функционал поделиться
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Информация о захоронении
                              _buildBurialInfoCard(),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Загрузка фотографий
                              _buildPhotoUploadSection(),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Эпитафия
                              _buildEpitaphSection(),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Память о человеке
                              _buildMemorySection(),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Публичная личность
                              _buildPublicToggle(),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Достижения
                              _buildAchievementsSection(),
                              const SizedBox(height: AppSizes.paddingLarge),
                              // Видеоматериалы
                              _buildVideoSection(),
                              const SizedBox(height: AppSizes.paddingXLarge),
                              // Кнопка создания мемориала
                              AppButton(
                                text: 'Создать мемориал',
                                onPressed: _createMemorial,
                                backgroundColor: AppColors.buttonBackground,
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
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

  Widget _buildBurialInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Информация о захоронении',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // Имя покойного
          Text(
            _burialRequest!.deceased.fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Даты
          Text(
            'Дата рождения - ${_formatDate(_burialRequest!.deceased.deathDate)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Divider(
            color: AppColors.accordionBorder.withOpacity(0.3),
            thickness: 1,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          // Кладбище и место
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Кладбище:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1d1c1a),
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    const Text(
                      'Сектор',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1d1c1a),
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    const Text(
                      'Место:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1d1c1a),
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _burialRequest!.cemeteryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.accordionBorder,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      _burialRequest!.sectorNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.accordionBorder,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      _burialRequest!.graveNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.accordionBorder,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhotos() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _photos.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      debugPrint('Error picking photos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка выбора фотографий')),
        );
      }
    }
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Загрузите фотографии',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        GestureDetector(
          onTap: _pickPhotos,
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
                Icon(Icons.image, size: 48, color: AppColors.accordionBorder),
                const SizedBox(height: AppSizes.paddingMedium),
                const Text(
                  'Загрузите фотографии',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1d1c1a),
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  'Перетащите файлы или загрузите файлы до 10 мб в формате: .png, .jpeg',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.accordionBorder,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                AppButton(
                  text: 'Загрузить',
                  onPressed: _pickPhotos,
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
        if (_photos.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          Wrap(
            spacing: AppSizes.paddingSmall,
            runSpacing: AppSizes.paddingSmall,
            children: _photos.asMap().entries.map((entry) {
              final index = entry.key;
              final photo = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      photo,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _photos.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEpitaphSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Эпитафия',
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
          decoration: InputDecoration(
            hintText: 'Введите эпитафию...',
            hintStyle: TextStyle(
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.buttonBackground),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  Widget _buildMemorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Память о человеке:',
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
          decoration: InputDecoration(
            hintText: 'Расскажите о человеке...',
            hintStyle: TextStyle(
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.buttonBackground),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  Widget _buildPublicToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
              activeThumbColor: AppColors.buttonBackground,
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            const Expanded(
              child: Text(
                'Публичная личность',
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
            'Цифровой мемориал этого человека приватный и доступен только по ссылке',
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

  Future<void> _pickAchievements() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _achievements.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      debugPrint('Error picking achievements: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка выбора файлов')));
      }
    }
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Достижения',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        GestureDetector(
          onTap: _pickAchievements,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingXLarge),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
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
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.buttonBackground,
                      fontFamily: 'Manrope',
                    ),
                    children: const [
                      TextSpan(text: 'Загрузите файлы'),
                      TextSpan(
                        text: ' или перетащите их',
                        style: TextStyle(color: Color(0xFF1d1c1a)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_achievements.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          Wrap(
            spacing: AppSizes.paddingSmall,
            runSpacing: AppSizes.paddingSmall,
            children: _achievements.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _achievements.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Видеоматериалы',
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
                decoration: InputDecoration(
                  hintText: 'Вставьте ссылку на YouTube',
                  hintStyle: TextStyle(
                    color: AppColors.accordionBorder,
                    fontFamily: 'Manrope',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.accordionBorder.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.buttonBackground),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1d1c1a),
                  fontFamily: 'Manrope',
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            ElevatedButton(
              onPressed: _addVideoLink,
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
              child: const Text(
                'Добавить',
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
              onPressed: () {
                _videoLinkController.clear();
              },
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
              child: const Text(
                'Отменить',
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
        if (_videoLinks.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          ..._videoLinks.asMap().entries.map((entry) {
            final index = entry.key;
            final link = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accordionBorder.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1d1c1a),
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeVideoLink(index),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Future<void> _createMemorial() async {
    if (_burialRequest == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Заявка не найдена')));
      }
      return;
    }

    final authManager = AuthStateManager();
    final user = authManager.currentUser;
    if (user == null || user.phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Войдите в аккаунт')));
      }
      return;
    }

    // Телефон без +7 для API (77472367503)
    final userPhone = user.phone
        .replaceFirst(RegExp(r'^\+?7'), '')
        .replaceAll(RegExp(r'\D'), '');

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final photoUrls = <String>[];
      for (final file in _photos) {
        final url = await _apiService.uploadMemorialFile(
          userPhone: userPhone,
          file: file,
          isAchievement: false,
        );
        photoUrls.add(url);
      }

      final achievementUrls = <String>[];
      for (final file in _achievements) {
        final url = await _apiService.uploadMemorialFile(
          userPhone: userPhone,
          file: file,
          isAchievement: true,
        );
        achievementUrls.add(url);
      }

      await _apiService.createMemorial(
        deceasedId: _burialRequest!.deceasedId,
        epitaph: _epitaphController.text.trim(),
        aboutPerson: _memoryController.text.trim(),
        isPublic: _isPublic,
        photoUrls: photoUrls,
        achievementUrls: achievementUrls,
        videoUrls: List.from(_videoLinks),
      );

      if (mounted) {
        Navigator.of(context).pop(); // закрыть диалог загрузки
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Мемориал создан успешно')),
        );
        Navigator.of(context).pop(); // вернуться со страницы создания
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // закрыть диалог загрузки
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.message}')));
      }
    } catch (e) {
      debugPrint('Error creating memorial: $e');
      if (mounted) {
        Navigator.of(context).pop(); // закрыть диалог загрузки при любой ошибке
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }
}
