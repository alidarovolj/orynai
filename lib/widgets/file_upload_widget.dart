import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';

class FileUploadWidget extends StatefulWidget {
  final String title;
  final String? description;
  final bool allowMultiple;
  final List<File> initialFiles;
  final Function(List<File>)? onFilesChanged;
  final IconData? icon;
  final Color? iconColor;
  final String? buttonText;
  final bool showButton;

  const FileUploadWidget({
    super.key,
    required this.title,
    this.description,
    this.allowMultiple = false,
    this.initialFiles = const [],
    this.onFilesChanged,
    this.icon,
    this.iconColor,
    this.buttonText,
    this.showButton = true,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.initialFiles);
  }

  @override
  void didUpdateWidget(FileUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFiles != oldWidget.initialFiles) {
      _files = List.from(widget.initialFiles);
    }
  }

  Future<void> _pickFiles() async {
    try {
      if (widget.allowMultiple) {
        final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _files.addAll(pickedFiles.map((file) => File(file.path)));
          });
          widget.onFilesChanged?.call(_files);
        }
      } else {
        final XFile? file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (file != null) {
          setState(() {
            _files = [File(file.path)];
          });
          widget.onFilesChanged?.call(_files);
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (mounted) {
        String errorMessage = 'Ошибка выбора файла';
        
        if (e.toString().contains('channel-error') || 
            e.toString().contains('Unable to establish connection')) {
          errorMessage = 'Не удалось открыть галерею. Проверьте разрешения приложения.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Необходимо разрешение на доступ к галерее';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
    widget.onFilesChanged?.call(_files);
  }

  bool _areAllImages() {
    return _files.every((file) {
      final fileName = file.path.split('/').last.toLowerCase();
      return fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg') ||
          fileName.endsWith('.png') ||
          fileName.endsWith('.gif');
    });
  }

  Widget _buildImageThumbnail(File file, int index) {
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
            onTap: () => _removeFile(index),
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
  }

  Widget _buildFilePreview(File file, int index) {
    final fileName = file.path.split('/').last;
    final fileSize = file.lengthSync() / 1024; // KB

    // Проверяем, является ли файл изображением
    final isImage = fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
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
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.insert_drive_file,
                color: AppColors.iconAndText,
                size: 32,
              ),
            ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
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
                  '${fileSize.toStringAsFixed(1)} KB',
                  style: TextStyle(
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
            onPressed: () => _removeFile(index),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1d1c1a),
            fontFamily: 'Manrope',
          ),
        ),
        if (widget.description != null) ...[
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            widget.description!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
        ],
        const SizedBox(height: AppSizes.paddingSmall),
        // Область загрузки
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            height: 120,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon ?? Icons.upload_file,
                  color: widget.iconColor ?? AppColors.accordionBorder,
                  size: 32,
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  'Загрузите файлы или перетащите их',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.iconColor ?? AppColors.buttonBackground,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
        ),
        // Список загруженных файлов
        if (_files.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingMedium),
          // Для множественных файлов показываем сетку (если все изображения)
          if (widget.allowMultiple && _files.length > 1 && _areAllImages())
            Wrap(
              spacing: AppSizes.paddingSmall,
              runSpacing: AppSizes.paddingSmall,
              children: _files.asMap().entries.map((entry) {
                return _buildImageThumbnail(entry.value, entry.key);
              }).toList(),
            )
          else
            // Для одиночных файлов или смешанных типов показываем список
            ..._files.asMap().entries.map((entry) {
              return _buildFilePreview(entry.value, entry.key);
            }),
        ],
      ],
    );
  }
}
