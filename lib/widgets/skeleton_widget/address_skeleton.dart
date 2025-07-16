import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AddressSkeleton extends StatelessWidget {
  const AddressSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Shimmer.fromColors(
          baseColor: colorScheme.surfaceVariant,
          highlightColor: colorScheme.surface,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Container(
                height: 14,
                width: 100,
                color: Colors.white,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  height: 12,
                  width: 180,
                  color: Colors.white,
                ),
              ),
              trailing: const Icon(Icons.delete_outline, color: Colors.transparent),
            ),
          ),
        ),
      ),
    );
  }
}
