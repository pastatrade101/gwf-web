
import 'package:flutter/material.dart';
import 'package:myapp/data/models/region.dart';
import 'package:myapp/data/region_data.dart';
import 'package:myapp/features/home/widgets/header.dart';
import 'package:myapp/features/home/widgets/region_card.dart';
import 'package:myapp/features/home/widgets/search_bar.dart' as custom_search_bar;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Region> _filteredRegions = tanzaniaRegions;

  void _filterRegions(String query) {
    setState(() {
      _filteredRegions = tanzaniaRegions
          .where((region) =>
              region.name.toLowerCase().contains(query.toLowerCase()) ||
              region.councils.any((council) =>
                  council.name.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Header(),
        toolbarHeight: 100,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          custom_search_bar.SearchBar(onChanged: _filterRegions),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRegions.length,
              itemBuilder: (context, index) {
                return RegionCard(region: _filteredRegions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
