import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watch_hub_ep/services/checkout_service.dart';
import 'package:watch_hub_ep/utils/string_utils.dart';

class CheckoutFormSection extends StatefulWidget {
  final bool isMobile;
  final GlobalKey<FormState> formKey;

  const CheckoutFormSection({
    super.key,
    required this.isMobile,
    required this.formKey,
  });

  @override
  State<CheckoutFormSection> createState() => _CheckoutFormSectionState();
}

class _CheckoutFormSectionState extends State<CheckoutFormSection> {
  final _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> savedAddresses = [];
  Map<String, dynamic>? selectedAddress;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String paymentMethod = 'COD';

  @override
  void initState() {
    super.initState();
    loadSavedAddresses();
    final user = _auth.currentUser;
    if (user != null) {
      emailCtrl.text = user.email ?? '';
    }
  }

  Future<void> loadSavedAddresses() async {
    final addresses = await CheckoutService.getSavedAddresses();
    setState(() => savedAddresses = addresses);
  }

  void _applyAddress(Map<String, dynamic> address) {
    setState(() {
      selectedAddress = address;
      countryCtrl.text = address['country'] ?? '';
      streetCtrl.text = address['street'] ?? '';
      cityCtrl.text = address['city'] ?? '';
      stateCtrl.text = address['state'] ?? '';
      postalCodeCtrl.text = address['postalCode'] ?? '';
      phoneCtrl.text = address['phone'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (savedAddresses.isNotEmpty)
          DropdownButtonFormField<Map<String, dynamic>?>(
            isExpanded: true,
            value: selectedAddress,
            hint: const Text('Select Saved Address'),
            items: [
              ...savedAddresses.map((addr) {
                return DropdownMenuItem(
                  value: addr,
                  child: Text(
                    '${capitalize(addr['label'])} • ${capitalize(addr['street'])}, ${capitalize(addr['city'])}, ${capitalize(addr['state'])} - ${capitalize(addr['postalCode'])}',
                  ),
                );
              }),
              const DropdownMenuItem<Map<String, dynamic>?>(
                value: null,
                child: Text('Enter Manually'),
              ),
            ],
            onChanged: (addr) {
              if (addr == null) {
                setState(() {
                  selectedAddress = null;
                  countryCtrl.clear();
                  streetCtrl.clear();
                  cityCtrl.clear();
                  stateCtrl.clear();
                  postalCodeCtrl.clear();
                  phoneCtrl.clear();
                });
              } else {
                _applyAddress(addr);
              }
            },
          ),
        const SizedBox(height: 16),
        Form(
          key: widget.formKey,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _field(firstNameCtrl, 'First Name', true),
              _field(lastNameCtrl, 'Last Name', true),
              _field(companyCtrl, 'Company'),
              _field(countryCtrl, 'Country', true),
              _field(streetCtrl, 'Street Address', true),
              _field(cityCtrl, 'City', true),
              _field(stateCtrl, 'State', true),
              _field(postalCodeCtrl, 'Postcode', true),
              _field(phoneCtrl, 'Phone', true),
              _field(emailCtrl, 'Email', true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('Cash on Delivery'),
          value: 'COD',
          groupValue: paymentMethod,
          onChanged: (val) => setState(() => paymentMethod = val!),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, [
    bool required = false,
  ]) {
    final alwaysEnabled = [
      firstNameCtrl,
      lastNameCtrl,
      companyCtrl,
    ].contains(controller);
    final alwaysDisabled = controller == emailCtrl;

    return SizedBox(
      width: widget.isMobile ? double.infinity : 260,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            required
                ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
                : null,
        readOnly: alwaysDisabled,
        enabled:
            alwaysDisabled ? false : (alwaysEnabled || selectedAddress == null),
      ),
    );
  }

  @override
  void dispose() {
    for (var ctrl in [
      firstNameCtrl,
      lastNameCtrl,
      companyCtrl,
      countryCtrl,
      streetCtrl,
      cityCtrl,
      stateCtrl,
      postalCodeCtrl,
      phoneCtrl,
      emailCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }
}
