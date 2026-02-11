import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../services/api_service.dart';

class BurialSearchRequestModal extends StatefulWidget {
  final DateTime? initialBirthDate;
  final DateTime? initialDeathDate;
  final String? initialDeceasedSurname;
  final String? initialDeceasedName;
  final String? initialDeceasedPatronym;

  const BurialSearchRequestModal({
    super.key,
    this.initialBirthDate,
    this.initialDeathDate,
    this.initialDeceasedSurname,
    this.initialDeceasedName,
    this.initialDeceasedPatronym,
  });

  @override
  State<BurialSearchRequestModal> createState() => _BurialSearchRequestModalState();
}

class _BurialSearchRequestModalState extends State<BurialSearchRequestModal> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _applicantNameController = TextEditingController();
  final TextEditingController _applicantPhoneController = TextEditingController();
  final TextEditingController _applicantEmailController = TextEditingController();
  final TextEditingController _deceasedSurnameController = TextEditingController();
  final TextEditingController _deceasedNameController = TextEditingController();
  final TextEditingController _deceasedPatronymController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _deathDateController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  DateTime? _birthDate;
  DateTime? _deathDate;
  bool _isSubmitting = false;

  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: AppColors.accordionBorder.withOpacity(0.3)),
  );
  static final _inputFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColors.buttonBackground),
  );

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialBirthDate != null) {
      _birthDate = widget.initialBirthDate;
      _birthDateController.text = _formatDate(widget.initialBirthDate!);
    }
    if (widget.initialDeathDate != null) {
      _deathDate = widget.initialDeathDate;
      _deathDateController.text = _formatDate(widget.initialDeathDate!);
    }
    if (widget.initialDeceasedSurname != null) {
      _deceasedSurnameController.text = widget.initialDeceasedSurname!;
    }
    if (widget.initialDeceasedName != null) {
      _deceasedNameController.text = widget.initialDeceasedName!;
    }
    if (widget.initialDeceasedPatronym != null) {
      _deceasedPatronymController.text = widget.initialDeceasedPatronym!;
    }
  }

  @override
  void dispose() {
    _applicantNameController.dispose();
    _applicantPhoneController.dispose();
    _applicantEmailController.dispose();
    _deceasedSurnameController.dispose();
    _deceasedNameController.dispose();
    _deceasedPatronymController.dispose();
    _birthDateController.dispose();
    _deathDateController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await _apiService.submitSearchRequest(
        applicantName: _applicantNameController.text.trim(),
        applicantPhone: _applicantPhoneController.text.trim(),
        applicantEmail: _applicantEmailController.text.trim(),
        deceasedSurname: _deceasedSurnameController.text.trim(),
        deceasedName: _deceasedNameController.text.trim(),
        deceasedPatronym: _deceasedPatronymController.text.trim(),
        birthDate: _birthDate,
        deathDate: _deathDate,
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('burialSearch.searchRequestModal.submitSuccess'.tr())),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('burialSearch.searchRequestModal.submitError'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _pickBirthDate() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900),
      maxTime: DateTime.now(),
      currentTime: _birthDate ?? DateTime(1950),
      locale: context.locale.languageCode == 'kk' ? LocaleType.ko : LocaleType.ru,
      onConfirm: (date) {
        setState(() {
          _birthDate = date;
          _birthDateController.text = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        });
      },
    );
  }

  void _pickDeathDate() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900),
      maxTime: DateTime.now(),
      currentTime: _deathDate ?? DateTime(2000),
      locale: context.locale.languageCode == 'kk' ? LocaleType.ko : LocaleType.ru,
      onConfirm: (date) {
        setState(() {
          _deathDate = date;
          _deathDateController.text = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + keyboardHeight,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'burialSearch.searchRequestModal.title'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.iconAndText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'burialSearch.searchRequestModal.sectionApplicant'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.iconAndText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('burialSearch.searchRequestModal.applicantName'.tr()),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _applicantNameController,
                          decoration: _decoration(hint: 'burialSearch.searchRequestModal.applicantNameHint'.tr()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'burialSearch.searchRequestModal.required'.tr() : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('burialSearch.searchRequestModal.applicantPhone'.tr()),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _applicantPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _decoration(hint: 'burialSearch.searchRequestModal.applicantPhoneHint'.tr()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'burialSearch.searchRequestModal.required'.tr() : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('burialSearch.searchRequestModal.applicantEmail'.tr()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _applicantEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(hint: 'burialSearch.searchRequestModal.applicantEmailHint'.tr()),
              ),
              const SizedBox(height: 16),
              Text(
                'burialSearch.searchRequestModal.sectionDeceased'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.iconAndText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('burialSearch.searchRequestModal.deceasedSurname'.tr()),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _deceasedSurnameController,
                          decoration: _decoration(hint: 'burialSearch.searchRequestModal.deceasedSurnameHint'.tr()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('burialSearch.searchRequestModal.deceasedName'.tr()),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _deceasedNameController,
                          decoration: _decoration(hint: 'burialSearch.searchRequestModal.deceasedNameHint'.tr()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('burialSearch.searchRequestModal.deceasedPatronym'.tr()),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _deceasedPatronymController,
                          decoration: _decoration(hint: 'burialSearch.searchRequestModal.deceasedPatronymHint'.tr()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('burialSearch.searchRequestModal.birthDate'.tr()),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickBirthDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _birthDateController,
                              decoration: _decoration(
                                hint: 'burialSearch.dateHint'.tr(),
                                suffixIcon: const Icon(Icons.calendar_today, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('burialSearch.searchRequestModal.deathDate'.tr()),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDeathDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _deathDateController,
                              decoration: _decoration(
                                hint: 'burialSearch.dateHint'.tr(),
                                suffixIcon: const Icon(Icons.calendar_today, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('burialSearch.searchRequestModal.additionalInfo'.tr()),
              const SizedBox(height: 8),
              TextFormField(
                controller: _additionalInfoController,
                maxLines: 3,
                decoration: _decoration(hint: 'burialSearch.searchRequestModal.additionalInfoHint'.tr()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                    ),
                  ),
                  child: Text('burialSearch.searchRequestModal.submit'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.iconAndText,
      ),
    );
  }

  InputDecoration _decoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.iconAndText.withOpacity(0.5)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputFocusedBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
