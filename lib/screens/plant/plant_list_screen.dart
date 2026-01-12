import 'package:flutter/material.dart';
import 'package:nexoor_field/models/plant_model.dart';
import 'package:nexoor_field/services/plant_service.dart';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  final PlantService _plantService = PlantService();
  List<PlantModel> _allPlants = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elenco Impianti')),
      body: FutureBuilder<List<PlantModel>>(
        future: _plantService.getAllPlants(), //
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allPlants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) _allPlants = snapshot.data!;
          if (_allPlants.isEmpty) return const Center(child: Text('Nessun impianto trovato.'));

          return ListView.separated(
            itemCount: _allPlants.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final plant = _allPlants[index]; //
              
              return Dismissible(
                key: Key(plant.id ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red, 
                  alignment: Alignment.centerRight, 
                  padding: const EdgeInsets.symmetric(horizontal: 20), 
                  child: const Icon(Icons.delete, color: Colors.white)
                ),
                onDismissed: (direction) async {
                  final id = plant.id;
                  setState(() => _allPlants.removeAt(index));
                  if (id != null) await _plantService.deletePlant(id); //
                },
                child: ListTile(
                  leading: const Icon(Icons.settings_suggest, color: Colors.redAccent),
                  title: Text(
                    'Catasto: ${plant.cadastralCode}', //
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(
                    '${plant.interventionType} - Potenza: ${plant.thermalPowerKw} kW' //
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