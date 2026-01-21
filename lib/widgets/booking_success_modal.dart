import 'package:flutter/material.dart';
import 'dart:async';
import '../constants.dart';
import '../pages/profile_page.dart';

class BookingSuccessModal extends StatefulWidget {
  const BookingSuccessModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const BookingSuccessModal(),
    );
  }

  @override
  State<BookingSuccessModal> createState() => _BookingSuccessModalState();
}

class _BookingSuccessModalState extends State<BookingSuccessModal> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });

        if (_countdown <= 0) {
          timer.cancel();
          _navigateToProfile();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToProfile() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка успеха
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            // Заголовок
            const Text(
              'Запрос отправлен',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            // Подзаголовок
            const Text(
              'Ожидайте подтверждения ...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            // Таймер
            Text(
              'Перенаправление в личный кабинет через $_countdown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.accordionBorder,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: AppSizes.paddingXLarge),
            // Кнопка
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'В личный кабинет',
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
    );
  }
}
