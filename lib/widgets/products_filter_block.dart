import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ProductsFilterBlock extends StatefulWidget {
  final int? selectedCategoryId;
  final String selectedCity;
  final int? minPrice;
  final int? maxPrice;
  final Function(
    int? categoryId,
    String city,
    bool promotions,
    String? supplier,
    int? minPrice,
    int? maxPrice,
  )?
  onFiltersChanged;

  const ProductsFilterBlock({
    super.key,
    this.selectedCategoryId,
    this.selectedCity = 'Алматы',
    this.minPrice,
    this.maxPrice,
    this.onFiltersChanged,
  });

  @override
  State<ProductsFilterBlock> createState() => _ProductsFilterBlockState();
}

class _ProductsFilterBlockState extends State<ProductsFilterBlock> {
  final ApiService _apiService = ApiService();
  late int? _selectedCategoryId;
  late String _selectedCity;
  late int? _minPrice;
  late int? _maxPrice;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedCity = widget.selectedCity;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      setState(() {
        _categories = response
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoadingCategories = false;

        // Проверяем, что выбранная категория существует в списке
        if (_selectedCategoryId != null) {
          final categoryExists = _categories.any(
            (cat) => cat.id == _selectedCategoryId,
          );
          if (!categoryExists) {
            // Если категория не найдена в списке, сбрасываем выбор
            _selectedCategoryId = null;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = widget.selectedCategoryId;
      _selectedCity = widget.selectedCity;
      _minPrice = null;
      _maxPrice = null;
    });
    widget.onFiltersChanged?.call(
      _selectedCategoryId,
      _selectedCity,
      false,
      null,
      _minPrice,
      _maxPrice,
    );
  }

  void _applyFilters() {
    widget.onFiltersChanged?.call(
      _selectedCategoryId,
      _selectedCity,
      false,
      null,
      _minPrice,
      _maxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingMedium,
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
          // Категория
          const Text(
            'Категория',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.iconAndText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                value: _isLoadingCategories ? null : _selectedCategoryId,
                hint: const Text(
                  'Все категории',
                  style: TextStyle(fontSize: 14, color: AppColors.iconAndText),
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
                items: _isLoadingCategories
                    ? []
                    : [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Все категории'),
                        ),
                        ..._categories.map((category) {
                          return DropdownMenuItem<int?>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }),
                      ],
                onChanged: _isLoadingCategories
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                        _applyFilters();
                      },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Город
          const Text(
            'Город',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.iconAndText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accordionBorder.withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCity,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.iconAndText.withOpacity(0.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.iconAndText,
                ),
                items: const [
                  DropdownMenuItem(value: 'Алматы', child: Text('Алматы')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value ?? 'Алматы';
                  });
                  _applyFilters();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Цена
          const Text(
            'Цена',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.iconAndText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'От',
                    hintStyle: TextStyle(
                      color: AppColors.iconAndText.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.accordionBorder.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.accordionBorder.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.buttonBackground),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _minPrice = value.isEmpty ? null : int.tryParse(value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '-',
                style: TextStyle(fontSize: 16, color: AppColors.iconAndText),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: _maxPrice?.toString() ?? '',
                  ),
                  decoration: InputDecoration(
                    hintText: 'До',
                    hintStyle: TextStyle(
                      color: AppColors.iconAndText.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.accordionBorder.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.accordionBorder.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.buttonBackground),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    suffixText: 'KZT',
                    suffixStyle: TextStyle(
                      color: AppColors.iconAndText.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _maxPrice = value.isEmpty ? null : int.tryParse(value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопка сброса фильтров
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetFilters,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppColors.accordionBorder.withOpacity(0.3),
                  ),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Сбросить фильтры',
                style: TextStyle(fontSize: 14, color: AppColors.iconAndText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
