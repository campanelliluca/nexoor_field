// Rappresenta l'ubicazione dell'impianto, come richiesto dalla Scheda 1.2 del Libretto
class PropertyModel {
  final String? id; // ID generato da Supabase
  final String customerId; // ID del cliente a cui appartiene questa proprietà (Chiave Esterna)
  final String address; // Indirizzo completo
  final String city; // Comune
  final String province; // Provincia (es. MI, RM)
  final String buildingCategory; // Categoria edificio E1-E8

  PropertyModel({
    this.id,
    required this.customerId,
    required this.address,
    required this.city,
    required this.province,
    required this.buildingCategory,
  });

  // Metodo per trasformare i dati in JSON per Supabase
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId, // Fondamentale per il legame con il cliente
      'address': address,
      'city': city,
      'province': province,
      'building_category': buildingCategory,
    };
  }

  // Metodo per creare l'oggetto partendo dal JSON di Supabase
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      customerId: json['customer_id'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      buildingCategory: json['building_category'] ?? 'E1', // Default a E1 (Residenziale)
    );
  }
}