// Rappresenta l'anagrafica del cliente (Proprietario o Terzo Responsabile)
class CustomerModel {
  final String? id; // ID generato dal database
  final String fullName; // Nome e Cognome o Ragione Sociale
  final String fiscalCode; // Codice Fiscale o Partita IVA
  final String? email; // Email per invio PDF dei rapporti
  final String? phone; // Contatto telefonico per reperibilità

  CustomerModel({
    this.id,
    required this.fullName,
    required this.fiscalCode,
    this.email,
    this.phone,
  });

  // Converte l'oggetto Dart in JSON per l'invio a Supabase
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'fiscal_code': fiscalCode,
      'email': email,
      'phone': phone,
    };
  }

  // Converte il JSON ricevuto dal database in un oggetto Dart
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      fiscalCode: json['fiscal_code'] ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }
}