import 'package:flutter/material.dart';
import '../../models/recycling_centre.dart';

class CentreDetailScreen extends StatelessWidget {
  final RecyclingCentre centre;

  const CentreDetailScreen({
    super.key,
    required this.centre,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F5520), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          centre.name,
          style: const TextStyle(
            color: Color(0xFF1F5520),
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Centre Overview Header Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD9E3DA)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Color(0xFF2E7D32),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  centre.name,
                                  style: const TextStyle(
                                    color: Color(0xFF1F5520),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: centre.isOpen
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        centre.isOpen ? 'OPEN FOR DROP-OFFS' : 'CLOSED',
                                        style: TextStyle(
                                          color: centre.isOpen
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFFC62828),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.directions_walk_rounded,
                                          size: 14,
                                          color: Color(0xFF1976D2),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${centre.distanceKm} km away',
                                          style: const TextStyle(
                                            color: Color(0xFF1976D2),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFECEFF1)),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        Icons.location_on_outlined,
                        '${centre.address}, ${centre.city}',
                      ),
                      const SizedBox(height: 8),
                      _buildContactRow(
                        Icons.access_time_outlined,
                        centre.operatingHours,
                      ),
                      const SizedBox(height: 8),
                      _buildContactRow(
                        Icons.phone_outlined,
                        centre.contactNumber,
                      ),
                      const SizedBox(height: 8),
                      _buildContactRow(
                        Icons.email_outlined,
                        centre.email,
                      ),
                      if (centre.notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAF7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD9E3DA)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF2E7D32),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  centre.notes,
                                  style: const TextStyle(
                                    color: Color(0xFF69756D),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Accepted Materials Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD9E3DA)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF2E7D32),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Accepted Recyclable Materials',
                            style: TextStyle(
                              color: Color(0xFF1F5520),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFECEFF1)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: centre.acceptedMaterials.map((mat) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFC8E6C9)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mat,
                                  style: const TextStyle(
                                    color: Color(0xFF1B5E20),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Unsupported / Rejected Materials Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Color(0xFFC62828),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Strictly NOT Accepted',
                            style: TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFFFCDD2)),
                      ...centre.unsupportedMaterials.map((mat) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.remove_circle_outline,
                                size: 16,
                                color: Color(0xFFD32F2F),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mat,
                                  style: const TextStyle(
                                    color: Color(0xFFB71C1C),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF69756D),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}