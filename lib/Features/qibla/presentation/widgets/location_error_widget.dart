import 'package:flutter/material.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';

class LocationErrorWidget extends StatelessWidget {
  final String? error;
  final VoidCallback? callback;

  const LocationErrorWidget({super.key, this.error, this.callback});

  @override
  Widget build(BuildContext context) {
    const box = SizedBox(height: 32);
    const errorColor = Color(0xffb00020);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.location_off, size: 150, color: errorColor),
          box,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error ?? 'Unknown Error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: errorColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          box,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Retry"),
            onPressed: () {
              if (callback != null) callback!();
            },
          ),
        ],
      ),
    );
  }
}
