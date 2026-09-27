import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';

class RecyclingPage extends StatelessWidget {
  const RecyclingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        title: const Text('Recycling Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subtitle section
            Container(
              width: double.infinity,
              color: MunicipalColors.primaryBg,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: const Text(
                'Monitor recycling activity, material recovery, and recycling center performance.',
                style: TextStyle(
                  fontSize: 14,
                  color: MunicipalColors.secondaryText,
                  height: 1.4,
                ),
              ),
            ),
            
            // Main empty state content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: MunicipalColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.recycling_outlined,
                        size: 64,
                        color: MunicipalColors.secondaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: MunicipalColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MunicipalColors.info.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 14, color: MunicipalColors.info),
                          SizedBox(width: 6),
                          Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MunicipalColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Heading
                    const Text(
                      'No Recycling Report Data Yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MunicipalColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    const Text(
                      'Recycling performance data will appear here once recycling center delivery and processing records are available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: MunicipalColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Supporting Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MunicipalColors.primaryBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MunicipalColors.border),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: MunicipalColors.warning,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Reports will provide insights into recycled quantities, material-wise performance, recycling center performance, and processing trends.',
                              style: TextStyle(
                                fontSize: 13,
                                color: MunicipalColors.secondaryText,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

