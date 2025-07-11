import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub_ep/models/address_model.dart';
import 'package:watch_hub_ep/services/profile_service.dart';

class AddressesTab extends StatelessWidget {
  AddressesTab({super.key});

  final ProfileService _srv = ProfileService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _srv.addressesStream(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        return ListView(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Address'),
              onPressed: () async {
                final res = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (_) => const AddressDialog(),
                );
                if (res != null) {
                  _srv.addAddress(res);
                }
              },
            ),
            const SizedBox(height: 16),
            ...docs.map((d) {
              final a = AddressModel(d.id, d.data()!);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  title: Text(a.label),
                  subtitle: Text('${a.street}, ${a.city}, ${a.country}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _srv.removeAddress(a.id),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class AddressDialog extends StatefulWidget {
  const AddressDialog({super.key});

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _form = GlobalKey<FormState>();
  final Map<String, String> model = {
    'label': '',
    'street': '',
    'city': '',
    'state': '',
    'country': '',
    'postalCode': '',
    'phone': '',
  };

  @override
  Widget build(BuildContext ctx) {
    return AlertDialog(
      title: const Text('Add Address'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            children:
                model.keys.map((field) {
                  return TextFormField(
                    decoration: InputDecoration(labelText: field),
                    onSaved: (v) => model[field] = v ?? '',
                  );
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _form.currentState!.save();
            Navigator.pop(ctx, model);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
