import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveFAQButton extends StatelessWidget {
  final String documentId;

  const RemoveFAQButton({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.remove_circle, color: Colors.red),
      tooltip: 'Delete FAQ',
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete FAQ'),
            content: const Text('Are you sure you want to delete this FAQ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            await FirebaseFirestore.instance
                .collection('FAQ')
                .doc(documentId)
                .delete();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('FAQ deleted')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      },
    );
  }
}
