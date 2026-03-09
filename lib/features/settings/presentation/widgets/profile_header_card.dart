import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.00, 0.00),
          end: Alignment(1.00, 1.00),
          colors: [Color(0x232ECC71), Color(0x990B2E22)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.52, color: Color(0x382ECC71)),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: ShapeDecoration(
              color: const Color(0x262ECC71),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.52, color: Color(0x4C2ECC71)),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Center(
              child: Text(
                '☪',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Salah Silent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF2ECC71),
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Mecca, Saudi Arabia',
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Auto-detected via GPS',
                  style: TextStyle(
                    color: Color(0x72A3F7BF),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
