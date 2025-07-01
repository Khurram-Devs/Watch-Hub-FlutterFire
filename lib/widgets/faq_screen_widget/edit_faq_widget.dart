import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFAQButton extends StatelessWidget {
  final String documentId;
  final String currentQuestion;
  final String currentAnswer;

  const EditFAQButton({
    super.key,
    required this.documentId,
    required this.currentQuestion,
    required this.currentAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      tooltip: 'Edit FAQ',
      onPressed: () {
        _showEditDialog(context);
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final _questionController = TextEditingController(text: currentQuestion);
    final _answerController = TextEditingController(text: currentAnswer);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit FAQ'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('FAQ')
                    .doc(documentId)
                    .update({
                  'question': _questionController.text.trim(),
                  'answer': _answerController.text.trim(),
                });

                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ updated')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
