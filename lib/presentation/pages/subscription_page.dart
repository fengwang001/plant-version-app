import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';

class SubscriptionController extends GetxController {
  final RxBool isPremium = true.obs;
  final RxString selectedPlan = 'premium'.obs;
  final RxBool isRestoring = false.obs;
  
  final subscriptionEndDate = 'Premium until 08/20/2024';
  final subscriptionSource = 'Subscribed via App Store';
  
  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }
  
  Future<void> restorePurchase() async {
    if (isRestoring.value) return;
    
    try {
      isRestoring.value = true;
      
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟成功/失败（70%成功率）
      final success = DateTime.now().millisecond % 10 > 3;
      
      if (success) {
        Get.snackbar(
          'Purchase Restored',
          'Purchase restored successfully!',
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
        isPremium.value = true;
        selectedPlan.value = 'premium';
      } else {
        Get.snackbar(
          'Restore Failed',
          'Failed to restore purchase, please try again.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isRestoring.value = false;
    }
  }
  
  void manageSubscription() {
    Get.snackbar(
      'Coming Soon',
      'Subscription management will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
  
  void viewHistory() {
    Get.snackbar(
      'Coming Soon',
      'Purchase history will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildCurrentSubscription(controller),
                    const SizedBox(height: 24),
                    _buildSubscriptionPlansTitle(),
                    const SizedBox(height: 16),
                    _buildSubscriptionPlans(controller),
                    const SizedBox(height: 24),
                    _buildActionButtons(controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7).withOpacity(0.8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
            ),
          ),
          const Expanded(
            child: Text(
              'Manage Subscription',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscription(SubscriptionController controller) {
    return Obx(() => controller.isPremium.value
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'You are Premium',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.subscriptionEndDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Core Benefits',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildBenefit('Unlimited AI Videos', Icons.video_library_rounded),
                        const SizedBox(width: 16),
                        _buildBenefit('HD Identification', Icons.hd_rounded),
                        const SizedBox(width: 16),
                        _buildBenefit('Exclusive Badge', Icons.workspace_premium_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFF22C55E),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.subscriptionSource,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.viewHistory,
                          child: const Text(
                            'View History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildBenefit(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlansTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Subscription Plans',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans(SubscriptionController controller) {
    return SizedBox(
      height: 340,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildPlanCard(
            controller: controller,
            planId: 'free',
            title: 'Free',
            price: '\$0',
            period: '/month',
            features: [
              PlanFeature(text: 'Basic plant identification', isIncluded: true),
              PlanFeature(text: 'Community access', isIncluded: true),
              PlanFeature(text: 'AI video generation', isIncluded: false),
            ],
            buttonText: 'Select Plan',
          ),
          const SizedBox(width: 16),
          _buildPlanCard(
            controller: controller,
            planId: 'premium',
            title: 'Premium',
            price: '\$9.99',
            period: '/month',
            features: [
              PlanFeature(text: 'Unlimited AI videos', isIncluded: true),
              PlanFeature(text: 'HD identification', isIncluded: true),
              PlanFeature(text: 'Exclusive badge', isIncluded: true),
            ],
            buttonText: 'Current Plan',
          ),
          const SizedBox(width: 16),
          _buildPlanCard(
            controller: controller,
            planId: 'pro',
            title: 'Pro',
            price: '\$19.99',
            period: '/month',
            features: [
              PlanFeature(text: 'All Premium features', isIncluded: true),
              PlanFeature(text: 'Pro member support', isIncluded: true),
              PlanFeature(text: '4K video generation', isIncluded: true),
            ],
            buttonText: 'Upgrade',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required SubscriptionController controller,
    required String planId,
    required String title,
    required String price,
    required String period,
    required List<PlanFeature> features,
    required String buttonText,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value == planId;
      final isCurrentPlan = planId == 'premium' && controller.isPremium.value;
      
      return GestureDetector(
        onTap: () => controller.selectPlan(planId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF22C55E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
                blurRadius: isSelected ? 20 : 10,
                offset: Offset(0, isSelected ? 8 : 4),
              ),
            ],
          ),
          transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8) 
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      feature.isIncluded ? Icons.check_rounded : Icons.close_rounded,
                      size: 16,
                      color: isSelected 
                          ? Colors.white 
                          : (feature.isIncluded 
                              ? const Color(0xFF22C55E) 
                              : const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected 
                              ? Colors.white 
                              : (feature.isIncluded 
                                  ? const Color(0xFF475569) 
                                  : const Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white 
                      : (planId == 'pro' 
                          ? const Color(0xFF22C55E) 
                          : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: isCurrentPlan 
                        ? null 
                        : () {
                            controller.selectPlan(planId);
                            if (planId == 'pro') {
                              _showUpgradeDialog();
                            }
                          },
                    child: Center(
                      child: Text(
                        isCurrentPlan ? buttonText : (isSelected ? 'Selected' : buttonText),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? const Color(0xFF22C55E) 
                              : (planId == 'pro' 
                                  ? Colors.white 
                                  : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons(SubscriptionController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.manageSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2E8F0),
                foregroundColor: const Color(0xFF64748B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Manage My Subscription',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isRestoring.value 
                  ? null 
                  : controller.restorePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2E8F0),
                foregroundColor: const Color(0xFF64748B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isRestoring.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64748B)),
                      ),
                    )
                  : const Text(
                      'Restore Purchase',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          )),
        ],
      ),
    );
  }

  void _showUpgradeDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upgrade to Pro?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You are about to upgrade your subscription plan to Pro. Do you want to continue?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Upgrade Started',
                          'Your upgrade is being processed',
                          backgroundColor: const Color(0xFF22C55E),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanFeature {
  final String text;
  final bool isIncluded;

  PlanFeature({
    required this.text,
    required this.isIncluded,
  });
}