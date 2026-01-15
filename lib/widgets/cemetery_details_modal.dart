import 'package:flutter/material.dart' hide Icon, TextStyle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../constants.dart';
import '../models/cemetery.dart';
import '../models/grave.dart';
import '../services/cemetery_service.dart';
import '../pages/booking_page.dart';

// Alias для Flutter виджетов
import 'package:flutter/material.dart' as flutter;

class CemeteryDetailsModal extends StatefulWidget {
  final Cemetery cemetery;

  const CemeteryDetailsModal({super.key, required this.cemetery});

  @override
  State<CemeteryDetailsModal> createState() => _CemeteryDetailsModalState();
}

class _CemeteryDetailsModalState extends State<CemeteryDetailsModal> {
  final CemeteryService _cemeteryService = CemeteryService();
  YandexMapController? _mapController;
  List<Grave> _graves = [];
  bool _isLoadingGraves = true;
  bool _isMapKitInitialized = false;
  Grave? _selectedGrave; // Выбранное место
  final Map<int, PolygonMapObject> _gravePolygons = {}; // ID могилы -> Polygon

  @override
  void initState() {
    super.initState();
    _initializeMapKit();
    _loadGraves();
  }

  // Инициализация Yandex MapKit только при открытии модального окна
  Future<void> _initializeMapKit() async {
    if (_isMapKitInitialized) return;

    try {
      // Новый API не требует явной инициализации через initMapkit
      // API ключ задается в нативном коде (AppDelegate для iOS, Application для Android)
      debugPrint('Yandex MapKit готов к использованию');
      setState(() {
        _isMapKitInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing Yandex MapKit: $e');
      setState(() {
        _isMapKitInitialized = true;
      });
    }
  }

  Future<void> _loadGraves() async {
    try {
      debugPrint('Cemetery ID: ${widget.cemetery.id}');
      debugPrint('Cemetery location: ${widget.cemetery.locationCoords}');

      // locationCoords[0] = latitude, locationCoords[1] = longitude
      final lat = widget.cemetery.locationCoords[0];
      final lon = widget.cemetery.locationCoords[1];

      // API ожидает: min_x/max_x = longitude, min_y/max_y = latitude
      // Расширяем границы на ~200 метров (~0.002 градуса)
      final minX = lon - 0.002; // longitude min
      final maxX = lon + 0.002; // longitude max
      final minY = lat - 0.002; // latitude min
      final maxY = lat + 0.002; // latitude max

      debugPrint(
        'Loading graves with bounds: minX=$minX, maxX=$maxX, minY=$minY, maxY=$maxY',
      );

      final graves = await _cemeteryService.getGravesByCoordinates(
        cemeteryId: widget.cemetery.id,
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
      );

      debugPrint('Loaded ${graves.length} graves');

      setState(() {
        _graves = graves;
        _isLoadingGraves = false;
      });

      // Обновляем объекты на карте после загрузки
      _updateMapObjects();
    } catch (e) {
      debugPrint('Error loading graves: $e');
      setState(() => _isLoadingGraves = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: flutter.Text('Ошибка загрузки могил: $e')),
        );
      }
    }
  }

  // Метод для добавления объектов на карту (новый API yandex_mapkit)
  Future<void> _updateMapObjects() async {
    if (_mapController == null) return;

    _gravePolygons.clear(); // Очищаем старые полигоны

    debugPrint('Adding ${_graves.length} graves to map');

    final polygons = <PolygonMapObject>[];

    for (var grave in _graves) {
      if (grave.polygonData.coordinates.isNotEmpty) {
        // Определяем цвет
        flutter.Color fillColor;
        if (grave.isFree) {
          fillColor = flutter.Colors.green.withAlpha(180);
        } else if (grave.isReserved) {
          fillColor = flutter.Colors.orange.withAlpha(180);
        } else {
          fillColor = flutter.Colors.grey.withAlpha(180);
        }

        // Создаем полигон с новым API
        final polygon = PolygonMapObject(
          mapId: MapObjectId('grave_${grave.id}'),
          polygon: Polygon(
            outerRing: LinearRing(
              points: grave.polygonData.coordinates
                  .map(
                    (coord) => Point(latitude: coord[1], longitude: coord[0]),
                  )
                  .toList(),
            ),
            innerRings: [],
          ),
          strokeColor: flutter.Colors.black,
          strokeWidth: 2.0,
          fillColor: fillColor,
          onTap: (PolygonMapObject self, Point point) {
            debugPrint(
              'Grave tapped: ${grave.id}, sector: ${grave.sectorNumber}, row: ${grave.rowNumber}',
            );
            _onGraveTap(grave);
          },
        );

        polygons.add(polygon);
        _gravePolygons[grave.id] = polygon;
      }
    }

    // Обновляем карту с новыми полигонами
    if (mounted) {
      setState(() {});
    }
  }

  // Обработка нажатия на могилу
  void _onGraveTap(Grave grave) {
    setState(() {
      // Сбрасываем выделение предыдущего места
      if (_selectedGrave != null &&
          _gravePolygons.containsKey(_selectedGrave!.id)) {
        final prevPolygon = _gravePolygons[_selectedGrave!.id]!;
        _gravePolygons[_selectedGrave!.id] = prevPolygon.copyWith(
          strokeColor: flutter.Colors.black,
          strokeWidth: 2.0,
        );
      }

      // Выделяем новое место красной рамкой
      _selectedGrave = grave;
      if (_gravePolygons.containsKey(grave.id)) {
        final currentPolygon = _gravePolygons[grave.id]!;
        _gravePolygons[grave.id] = currentPolygon.copyWith(
          strokeColor: flutter.Colors.red,
          strokeWidth: 4.0,
        );
      }
    });
  }

  flutter.Widget _buildSelectedGraveInfo() {
    if (_selectedGrave == null) return const flutter.SizedBox.shrink();

    final grave = _selectedGrave!;

    return flutter.Container(
      margin: const flutter.EdgeInsets.only(bottom: 16),
      padding: const flutter.EdgeInsets.all(16),
      decoration: flutter.BoxDecoration(
        color: const flutter.Color.fromRGBO(244, 240, 231, 1),
        borderRadius: flutter.BorderRadius.circular(12),
        border: flutter.Border.all(color: AppColors.buttonBackground, width: 2),
      ),
      child: flutter.Column(
        crossAxisAlignment: flutter.CrossAxisAlignment.start,
        children: [
          flutter.Row(
            mainAxisAlignment: flutter.MainAxisAlignment.spaceBetween,
            children: [
              const flutter.Text(
                'Выбранное место',
                style: flutter.TextStyle(
                  fontSize: 16,
                  fontWeight: flutter.FontWeight.w600,
                  color: AppColors.iconAndText,
                ),
              ),
              flutter.IconButton(
                icon: const flutter.Icon(flutter.Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    // Сбрасываем выделение на карте
                    if (_selectedGrave != null &&
                        _gravePolygons.containsKey(_selectedGrave!.id)) {
                      final polygon = _gravePolygons[_selectedGrave!.id]!;
                      _gravePolygons[_selectedGrave!.id] = polygon.copyWith(
                        strokeColor: flutter.Colors.black,
                        strokeWidth: 2.0,
                      );
                    }
                    _selectedGrave = null;
                  });
                },
                padding: flutter.EdgeInsets.zero,
                constraints: const flutter.BoxConstraints(),
              ),
            ],
          ),
          const flutter.SizedBox(height: 12),
          flutter.Row(
            children: [
              flutter.Expanded(
                child: flutter.Text(
                  'Сектор: ${grave.sectorNumber}',
                  style: const flutter.TextStyle(
                    fontSize: 14,
                    color: AppColors.iconAndText,
                  ),
                ),
              ),
              flutter.Expanded(
                child: flutter.Text(
                  'Место: ${grave.graveNumber}',
                  style: const flutter.TextStyle(
                    fontSize: 14,
                    color: AppColors.iconAndText,
                  ),
                ),
              ),
            ],
          ),
          const flutter.SizedBox(height: 8),
          flutter.Row(
            children: [
              flutter.Container(
                width: 12,
                height: 12,
                decoration: flutter.BoxDecoration(
                  color: grave.isFree
                      ? flutter.Colors.green
                      : grave.isReserved
                      ? flutter.Colors.orange
                      : flutter.Colors.grey,
                  shape: flutter.BoxShape.circle,
                ),
              ),
              const flutter.SizedBox(width: 8),
              flutter.Text(
                'Статус: ${_getStatusText(grave.status)}',
                style: const flutter.TextStyle(
                  fontSize: 14,
                  color: AppColors.iconAndText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'free':
        return 'Свободно';
      case 'reserved':
        return 'Зарезервировано';
      case 'occupied':
        return 'Занято';
      default:
        return status;
    }
  }

  String _getReligionIconPath() {
    return widget.cemetery.religion == 'Ислам'
        ? 'assets/icons/religions/003-islam.svg'
        : 'assets/icons/religions/christianity.svg';
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      backgroundColor: flutter.Colors.white,
      body: flutter.SafeArea(
        top: false,
        bottom: false,
        child: flutter.Stack(
          children: [
            // Карта на весь экран (показываем только после инициализации MapKit)
            if (_isMapKitInitialized)
              YandexMap(
                onMapCreated: (YandexMapController controller) async {
                  _mapController = controller;

                  // locationCoords[0] = latitude, locationCoords[1] = longitude
                  final lat = widget.cemetery.locationCoords[0];
                  final lon = widget.cemetery.locationCoords[1];

                  debugPrint(
                    'Map created (New SDK). Moving to: lat=$lat, lon=$lon',
                  );
                  debugPrint('Graves loaded: ${_graves.length}');

                  // Перемещаем камеру
                  await _mapController!.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: Point(latitude: lat, longitude: lon),
                        zoom: 19.0,
                      ),
                    ),
                  );

                  // Если могилы уже загрузились к этому моменту
                  if (!_isLoadingGraves) {
                    _updateMapObjects();
                  }
                },
                mapObjects: _gravePolygons.values.toList(),
              ),

            // Индикатор загрузки MapKit или могил
            if (!_isMapKitInitialized || _isLoadingGraves)
              flutter.Center(
                child: flutter.Column(
                  mainAxisSize: flutter.MainAxisSize.min,
                  children: [
                    const flutter.CircularProgressIndicator(
                      valueColor: flutter.AlwaysStoppedAnimation<flutter.Color>(
                        AppColors.buttonBackground,
                      ),
                    ),
                    const flutter.SizedBox(height: 16),
                    flutter.Text(
                      !_isMapKitInitialized
                          ? 'Инициализация карты...'
                          : 'Загрузка мест...',
                      style: const flutter.TextStyle(
                        fontSize: 14,
                        color: AppColors.iconAndText,
                      ),
                    ),
                  ],
                ),
              ),

            // Кнопка закрытия
            flutter.Positioned(
              top: 56,
              right: 16,
              child: flutter.Container(
                decoration: flutter.BoxDecoration(
                  color: flutter.Colors.white,
                  shape: flutter.BoxShape.circle,
                  boxShadow: [
                    flutter.BoxShadow(
                      color: flutter.Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: flutter.IconButton(
                  icon: const flutter.Icon(flutter.Icons.close),
                  onPressed: () => flutter.Navigator.pop(context),
                ),
              ),
            ),

            // Информация о кладбище (поверх карты внизу)
            flutter.Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: flutter.Container(
                decoration: flutter.BoxDecoration(
                  color: flutter.Colors.white,
                  borderRadius: const flutter.BorderRadius.only(
                    topLeft: flutter.Radius.circular(20),
                    topRight: flutter.Radius.circular(20),
                  ),
                  boxShadow: [
                    flutter.BoxShadow(
                      color: flutter.Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const flutter.Offset(0, -4),
                    ),
                  ],
                ),
                child: flutter.SafeArea(
                  top: false,
                  child: flutter.SingleChildScrollView(
                    padding: const flutter.EdgeInsets.all(20),
                    child: flutter.Column(
                      crossAxisAlignment: flutter.CrossAxisAlignment.start,
                      children: [
                        // Название и иконка религии
                        flutter.Row(
                          children: [
                            SvgPicture.asset(
                              _getReligionIconPath(),
                              width: 32,
                              height: 32,
                              colorFilter: const flutter.ColorFilter.mode(
                                AppColors.iconAndText,
                                flutter.BlendMode.srcIn,
                              ),
                              placeholderBuilder:
                                  (flutter.BuildContext context) =>
                                      flutter.Container(
                                        width: 32,
                                        height: 32,
                                        color: flutter.Colors.transparent,
                                      ),
                            ),
                            const flutter.SizedBox(width: 12),
                            flutter.Expanded(
                              child: flutter.Text(
                                widget.cemetery.name,
                                style: const flutter.TextStyle(
                                  fontSize: 20,
                                  fontWeight: flutter.FontWeight.w700,
                                  color: AppColors.iconAndText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const flutter.SizedBox(height: 16),
                        // Легенда
                        flutter.Row(
                          children: [
                            _buildLegendItem(
                              color: flutter.Colors.green,
                              label:
                                  'Свободные места: ${widget.cemetery.freeSpaces}',
                            ),
                            const flutter.SizedBox(width: 16),
                            _buildLegendItem(
                              color: flutter.Colors.orange,
                              label:
                                  'Зарезервировано: ${widget.cemetery.reservedSpaces}',
                            ),
                          ],
                        ),
                        const flutter.SizedBox(height: 8),
                        _buildLegendItem(
                          color: flutter.Colors.grey,
                          label: 'Занято: ${widget.cemetery.occupiedSpaces}',
                        ),
                        const flutter.SizedBox(height: 20),
                        // Адрес
                        flutter.Row(
                          children: [
                            const flutter.Icon(
                              flutter.Icons.location_on,
                              size: 20,
                              color: AppColors.iconAndText,
                            ),
                            const flutter.SizedBox(width: 8),
                            flutter.Expanded(
                              child: flutter.Text(
                                '${widget.cemetery.streetName}, ${widget.cemetery.city}',
                                style: const flutter.TextStyle(
                                  fontSize: 14,
                                  color: AppColors.iconAndText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const flutter.SizedBox(height: 12),
                        // Телефон
                        flutter.Row(
                          children: [
                            const flutter.Icon(
                              flutter.Icons.phone,
                              size: 20,
                              color: AppColors.iconAndText,
                            ),
                            const flutter.SizedBox(width: 8),
                            flutter.Text(
                              '+${widget.cemetery.phone}',
                              style: const flutter.TextStyle(
                                fontSize: 14,
                                color: AppColors.iconAndText,
                              ),
                            ),
                          ],
                        ),
                        const flutter.SizedBox(height: 20),
                        // Описание
                        flutter.Text(
                          widget.cemetery.description,
                          style: const flutter.TextStyle(
                            fontSize: 14,
                            color: AppColors.iconAndText,
                            height: 1.5,
                          ),
                        ),
                        const flutter.SizedBox(height: 24),
                        // Информация о выбранном месте
                        _buildSelectedGraveInfo(),
                        // Кнопка бронирования
                        flutter.SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: flutter.ElevatedButton(
                            onPressed:
                                _selectedGrave != null && _selectedGrave!.isFree
                                ? () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      flutter.MaterialPageRoute(
                                        builder: (context) => BookingPage(
                                          cemetery: widget.cemetery,
                                          grave: _selectedGrave!,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: flutter.ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBackground,
                              disabledBackgroundColor: flutter.Colors.grey,
                              shape: flutter.RoundedRectangleBorder(
                                borderRadius: flutter.BorderRadius.circular(8),
                              ),
                            ),
                            child: flutter.Row(
                              mainAxisAlignment:
                                  flutter.MainAxisAlignment.center,
                              children: [
                                const flutter.Icon(
                                  flutter.Icons.edit,
                                  size: 20,
                                ),
                                const flutter.SizedBox(width: 8),
                                flutter.Text(
                                  _selectedGrave != null &&
                                          _selectedGrave!.isFree
                                      ? 'Забронировать место'
                                      : 'Выберите свободное место',
                                  style: const flutter.TextStyle(
                                    fontSize: 16,
                                    fontWeight: flutter.FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  flutter.Widget _buildLegendItem({
    required flutter.Color color,
    required String label,
  }) {
    return flutter.Row(
      mainAxisSize: flutter.MainAxisSize.min,
      children: [
        flutter.Container(
          width: 16,
          height: 16,
          decoration: flutter.BoxDecoration(
            color: color.withValues(alpha: 0.6),
            border: flutter.Border.all(color: flutter.Colors.black, width: 1),
            borderRadius: flutter.BorderRadius.circular(4),
          ),
        ),
        const flutter.SizedBox(width: 6),
        flutter.Text(
          label,
          style: const flutter.TextStyle(
            fontSize: 12,
            color: AppColors.iconAndText,
          ),
        ),
      ],
    );
  }
}
