
class AddressModel {
  final String id, label, street, city, state, country, postalCode, phone;
  AddressModel(this.id, Map<String, dynamic> d)
    : label = d['label'],
      street = d['street'],
      city = d['city'],
      state = d['state'],
      country = d['country'],
      postalCode = d['postalCode'],
      phone = d['phone'];
}
