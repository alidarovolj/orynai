import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';

class ContactsBlock extends StatelessWidget {
  final VoidCallback onLocationTap;
  final VoidCallback onPhoneTap;
  final VoidCallback onEmailTap;
  final VoidCallback onInstagramTap;
  final VoidCallback onFacebookTap;

  const ContactsBlock({
    super.key,
    required this.onLocationTap,
    required this.onPhoneTap,
    required this.onEmailTap,
    required this.onInstagramTap,
    required this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 48,
      ),
      child: Column(
        children: [
          // Заголовок
          Text(
            'contacts.title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF041B32),
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 24),
          // Подзаголовок
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            child: Text(
              'contacts.subtitle'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: AppColors.iconAndText,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Адрес
          GestureDetector(
            onTap: onLocationTap,
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/contacts/location.svg',
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    AppColors.iconAndText,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (BuildContext context) => Container(
                    width: 32,
                    height: 32,
                    color: Colors.transparent,
                  ),
                ),
                const SizedBox(
                  height: AppSizes.paddingMedium,
                ),
                Text(
                  'contacts.city'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF041B32),
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(
                  height: AppSizes.paddingSmall,
                ),
                Text(
                  'contacts.address'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF041B32),
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: AppSizes.paddingLarge,
          ),
          // Разделительная линия
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            child: Divider(
              color: const Color.fromRGBO(
                4,
                27,
                50,
                0.15,
              ),
              thickness: 1,
              height: 1,
            ),
          ),
          const SizedBox(
            height: AppSizes.paddingLarge,
          ),
          // Телефон
          GestureDetector(
            onTap: onPhoneTap,
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/contacts/phone.svg',
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    AppColors.iconAndText,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (BuildContext context) => Container(
                    width: 32,
                    height: 32,
                    color: Colors.transparent,
                  ),
                ),
                const SizedBox(
                  height: AppSizes.paddingMedium,
                ),
                Text(
                  'contacts.phone'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF041B32),
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: AppSizes.paddingMedium,
          ),
          // Социальные сети
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/contacts/instagram.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.iconAndText,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (BuildContext context) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.transparent,
                  ),
                ),
                onPressed: onInstagramTap,
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/contacts/facebook.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.iconAndText,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (BuildContext context) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.transparent,
                  ),
                ),
                onPressed: onFacebookTap,
              ),
            ],
          ),
          const SizedBox(
            height: AppSizes.paddingLarge,
          ),
          // Разделительная линия
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            child: Divider(
              color: const Color.fromRGBO(
                4,
                27,
                50,
                0.15,
              ),
              thickness: 1,
              height: 1,
            ),
          ),
          const SizedBox(
            height: AppSizes.paddingLarge,
          ),
          // Email
          SvgPicture.asset(
            'assets/icons/contacts/mail.svg',
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              AppColors.iconAndText,
              BlendMode.srcIn,
            ),
            placeholderBuilder: (BuildContext context) => Container(
              width: 32,
              height: 32,
              color: Colors.transparent,
            ),
          ),
          const SizedBox(
            height: AppSizes.paddingMedium,
          ),
          GestureDetector(
            onTap: onEmailTap,
            child: Text(
              'contacts.email'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF041B32),
                fontFamily: 'Manrope',
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
