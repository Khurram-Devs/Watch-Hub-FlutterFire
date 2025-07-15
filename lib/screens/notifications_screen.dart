import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Icon _getIcon(String type) {
    switch (type) {
      case 'price_drop':
        return const Icon(Icons.price_check_outlined, color: Colors.green);
      case 'back_in_stock':
        return const Icon(Icons.inventory_2_outlined, color: Colors.blue);
      case 'out_of_stock':
        return const Icon(Icons.warning_amber_rounded, color: Colors.orange);
      default:
        return const Icon(Icons.notifications_outlined);
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dt);
  }

  Future<void> _markAsRead(String uid, String docId) async {
    await FirebaseFirestore.instance
        .collection('usersProfile')
        .doc(uid)
        .collection('notifications')
        .doc(docId)
        .update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view notifications.')),
      );
    }

    final notificationsRef = FirebaseFirestore.instance
        .collection('usersProfile')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'general';
              final title = data['title'] ?? 'Alert';
              final message = data['message'] ?? '';
              final ts = data['createdAt'] as Timestamp?;
              final isRead = data['isRead'] == true;

              return InkWell(
                onTap: () => !isRead ? _markAsRead(uid, doc.id) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isRead
                            ? Theme.of(context).scaffoldBackgroundColor
                            : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _getIcon(type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight:
                                          isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (ts != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _formatTimestamp(ts),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
