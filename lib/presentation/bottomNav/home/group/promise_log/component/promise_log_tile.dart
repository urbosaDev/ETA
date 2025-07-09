import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:what_is_your_eta/data/model/promise_model.dart';

class PromiseLogTile extends StatelessWidget {
  final PromiseModel promise;
  const PromiseLogTile({super.key, required this.promise});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          Center(
            child: Text(
              DateFormat('yyyy.MM.dd HH:mm').format(promise.time),
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff1a1a1a),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promise.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  promise.location.placeName,
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  promise.location.address,
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
