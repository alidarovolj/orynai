import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/auth_state_manager.dart';
import '../models/burial_request.dart';

/// Модалка выбора заявки на захоронение. По выбору вызывает [Navigator.pop] с выбранной заявкой.
class BurialRequestSelectModal extends StatefulWidget {
  const BurialRequestSelectModal({super.key});

  @override
  State<BurialRequestSelectModal> createState() =>
      _BurialRequestSelectModalState();
}

class _BurialRequestSelectModalState extends State<BurialRequestSelectModal> {
  final ApiService _apiService = ApiService();
  List<BurialRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final authManager = AuthStateManager();
      final userPhone = authManager.currentUser?.phone ?? '';
      final response = await _apiService.get(
        '/api/v8/burial-requests/my',
        queryParameters: {'user_phone': userPhone},
        requiresAuth: true,
      );
      final requestsData = BurialRequestsResponse.fromJson(
        response as Map<String, dynamic>,
      );
      if (mounted) {
        setState(() {
          _requests = requestsData.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading burial requests: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'profile.errors.loadRequests'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.accordionBorder,
              fontFamily: 'Manrope',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1d1c1a),
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(BurialRequest request) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    String createdAt = '';
    try {
      createdAt = dateFormat.format(DateTime.parse(request.createdAt));
    } catch (e) {
      createdAt = request.createdAt;
    }

    return InkWell(
      onTap: () => Navigator.pop(context, request),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accordionBorder.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.requestNumber,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1d1c1a),
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: request.status == 'pending'
                        ? Colors.orange
                        : request.status == 'completed'
                        ? const Color(0xFF4CAF50)
                        : request.status == 'cancelled'
                        ? Colors.red
                        : AppColors.accordionBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.status == 'pending'
                        ? 'profile.requestStatusPending'.tr()
                        : request.status == 'completed'
                        ? 'profile.requestStatusCompleted'.tr()
                        : request.status == 'cancelled'
                        ? 'profile.requestStatusCancelled'.tr()
                        : request.status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('profile.cemetery'.tr(), request.cemeteryName),
            const SizedBox(height: 4),
            _buildInfoRow('profile.place'.tr(), request.graveNumber),
            const SizedBox(height: 4),
            _buildInfoRow('profile.deceased'.tr(), request.deceased.fullName),
            const SizedBox(height: 4),
            _buildInfoRow('profile.createdAt'.tr(), createdAt),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.accordionBorder.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'profile.selectBurialRequestForMemorial'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1d1c1a),
                fontFamily: 'Manrope',
              ),
            ),
          ),
          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _requests.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'profile.noBurialRequests'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.accordionBorder,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingMedium,
                      0,
                      AppSizes.paddingMedium,
                      AppSizes.paddingLarge,
                    ),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) =>
                        _buildRequestCard(_requests[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
