import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub_ep/models/address_model.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/utils/string_utils.dart';
import 'package:watch_hub_ep/widgets/skeleton_widget/address_skeleton.dart';

class AddressBookScreen extends StatelessWidget {
  AddressBookScreen({super.key});

  final ProfileService _srv = ProfileService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address Book',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _srv.addressesStream(),
                  builder: (ctx, snap) {
                    if (!snap.hasData) {
                      return const AddressSkeleton();
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
                        if (docs.isEmpty)
                          const Center(child: Text('No saved addresses.')),
                        ...docs.map((d) {
                          final a = AddressModel(d.id, d.data()!);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: ListTile(
                              title: Text(capitalize(a.label)),
                              subtitle: Text(
                                '${capitalize(a.street)}, ${capitalize(a.city)}, ${capitalize(a.country)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.redAccent,
                                onPressed: () => _srv.removeAddress(a.id),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
    final theme = Theme.of(ctx);

    return AlertDialog(
      title: Text(
        'Add Address',
        style: TextStyle(color: theme.colorScheme.primary),
      ),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            children:
                model.keys.map((field) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: capitalize(field)),
                      onSaved: (v) => model[field] = v ?? '',
                    ),
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
