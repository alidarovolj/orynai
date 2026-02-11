import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../models/cemetery.dart';
import '../models/memorial_search_result.dart';
import '../services/cemetery_service.dart';
import '../services/api_service.dart';
import '../widgets/header.dart';
import '../widgets/burial_search_request_modal.dart';
import '../services/auth_state_manager.dart';
import '../widgets/login_modal.dart';
import 'profile_page.dart';
import 'memorial_detail_page.dart';

class BurialSearchPage extends StatefulWidget {
  const BurialSearchPage({super.key});

  @override
  State<BurialSearchPage> createState() => _BurialSearchPageState();
}

class _BurialSearchPageState extends State<BurialSearchPage> {
  final CemeteryService _cemeteryService = CemeteryService();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _deathDateController = TextEditingController();

  List<Cemetery> _cemeteryList = [];
  bool _isLoading = true;
  bool _isScrolled = false;
  String _selectedCity = 'Алматы';
  int? _selectedCemeteryId;
  DateTime? _birthDate;
  DateTime? _deathDate;

  List<MemorialSearchResult>? _searchResults;
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _loadCemeteries();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _deathDateController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }

  Future<void> _loadCemeteries() async {
    try {
      final list = await _cemeteryService.getCemeteries();
      if (mounted) {
        setState(() {
          _cemeteryList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('burialSearch.loadError'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  int get _totalGravesCount {
    return _cemeteryList.fold<int>(0, (sum, c) => sum + c.occupiedSpaces);
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

  Future<void> _onSearch() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('burialSearch.fullNameRequired'.tr())),
      );
      return;
    }
    setState(() {
      _isSearching = true;
      _searchError = null;
      _searchResults = null;
    });
    try {
      final result = await _apiService.searchMemorials(
        fullName: fullName,
        birthDateFrom: _birthDate,
        deathDateFrom: _deathDate,
        cemeteryId: _selectedCemeteryId,
        page: 1,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _searchResults = result.items;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = e.toString();
          _searchResults = null;
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('burialSearch.loadError'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                AppHeader(
                  isScrolled: _isScrolled,
                  onProfileTap: () {
                    final authManager = AuthStateManager();
                    if (!authManager.isAuthenticated) {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const LoginModal(),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    }
                  },
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    children: [
                      const SizedBox(height: AppSizes.paddingMedium),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'burialSearch.title'.tr(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.iconAndText,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                            child: Text(
                              'burialSearch.backToHome'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.iconAndText,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'burialSearch.subtitle'.tr(namedArgs: {
                          'city': _selectedCity,
                          'count': _isLoading ? '—' : _totalGravesCount.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]} ',
                              ).trim(),
                        }),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.accordionBorder,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      Container(
                        margin: const EdgeInsets.only(
                          top: AppSizes.paddingMedium,
                          bottom: AppSizes.paddingMedium,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterLabel('burialSearch.city'.tr()),
                            const SizedBox(height: 8),
                            _buildFilterDropdown<String>(
                              value: _selectedCity,
                              items: ['Алматы'],
                              onChanged: (v) => setState(() => _selectedCity = v ?? 'Алматы'),
                            ),
                            const SizedBox(height: 16),
                            _buildFilterLabel('burialSearch.fullName'.tr()),
                            const SizedBox(height: 8),
                            _buildFilterTextField(
                              controller: _fullNameController,
                              hintText: 'burialSearch.fullNameHint'.tr(),
                            ),
                            const SizedBox(height: 16),
                            _buildFilterLabel('burialSearch.birthDate'.tr()),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickBirthDate,
                              child: AbsorbPointer(
                                child: _buildFilterTextField(
                                  controller: _birthDateController,
                                  hintText: 'burialSearch.dateHint'.tr(),
                                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFilterLabel('burialSearch.deathDate'.tr()),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickDeathDate,
                              child: AbsorbPointer(
                                child: _buildFilterTextField(
                                  controller: _deathDateController,
                                  hintText: 'burialSearch.dateHint'.tr(),
                                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFilterLabel('burialSearch.cemetery'.tr()),
                            const SizedBox(height: 8),
                            _buildCemeteryDropdown(),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 160,
                                child: ElevatedButton(
                                  onPressed: _onSearch,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonBackground,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                                    ),
                                  ),
                                  child: Text('burialSearch.find'.tr()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isSearching && _searchResults == null) ...[
                        const SizedBox(height: AppSizes.paddingLarge),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F0E7),
                            borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'burialSearch.attention'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.iconAndText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'burialSearch.instruction1'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.iconAndText,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'burialSearch.instruction2'.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.iconAndText,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_isSearching)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_searchError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            _searchError!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        )
                      else if (_searchResults != null) ...[
                        const SizedBox(height: AppSizes.paddingLarge),
                        Text(
                          _searchResults!.length == 1
                              ? 'burialSearch.resultsFoundOne'.tr()
                              : 'burialSearch.resultsFound'.tr(namedArgs: {'count': _searchResults!.length.toString()}),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.iconAndText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._searchResults!.map((r) => _SearchResultCard(
                          result: r,
                          onGoToMemorial: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemorialDetailPage(memorialId: r.memorialId),
                              ),
                            );
                          },
                        )),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final fullNameParts = _fullNameController.text.trim().split(RegExp(r'\s+'));
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => BurialSearchRequestModal(
                                  initialBirthDate: _birthDate,
                                  initialDeathDate: _deathDate,
                                  initialDeceasedSurname: fullNameParts.isNotEmpty ? fullNameParts[0] : null,
                                  initialDeceasedName: fullNameParts.length > 1 ? fullNameParts[1] : null,
                                  initialDeceasedPatronym: fullNameParts.length > 2 ? fullNameParts.sublist(2).join(' ') : null,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBackground,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                              ),
                            ),
                            child: Text('burialSearch.notFoundCemetery'.tr()),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),
                      ],
                      const SizedBox(height: AppSizes.paddingXLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final _filterInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: AppColors.accordionBorder.withOpacity(0.3),
    ),
  );

  Widget _buildFilterLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.iconAndText,
      ),
    );
  }

  Widget _buildFilterTextField({
    required TextEditingController controller,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.iconAndText.withOpacity(0.5),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: _filterInputBorder,
        enabledBorder: _filterInputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.buttonBackground),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accordionBorder.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.iconAndText.withOpacity(0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.iconAndText,
          ),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCemeteryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accordionBorder.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedCemeteryId,
          isExpanded: true,
          hint: Text(
            'burialSearch.cemeteryAll'.tr(),
            style: const TextStyle(fontSize: 14, color: AppColors.iconAndText),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.iconAndText.withOpacity(0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.iconAndText,
          ),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text('burialSearch.cemeteryAll'.tr()),
            ),
            ..._cemeteryList.map(
              (c) => DropdownMenuItem<int?>(
                value: c.id,
                child: Text(c.name),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _selectedCemeteryId = v),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final MemorialSearchResult result;
  final VoidCallback onGoToMemorial;

  const _SearchResultCard({
    required this.result,
    required this.onGoToMemorial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              result.fullName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.iconAndText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGoToMemorial,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackground,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                ),
              ),
              child: Text('burialSearch.goToDigitalMemorial'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
