import 'package:flutter/material.dart';

List<String> allNames = ["cafe", "guitarra", "gym", "user"];

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchResult = List.empty(growable: true);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchResult.clear();
    searchResult =
        allNames.where((element) => element.startsWith(query)).toList();
    return Container(
      margin: const EdgeInsets.all(20),
      child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          scrollDirection: Axis.vertical,
          children: List.generate(searchResult.length, (index) {
            var item = searchResult[index];
            return Card(
              color: Colors.green,
              child: Container(
                  padding: const EdgeInsets.all(16), child: Text(item)),
            );
          })),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {},
        leading: const Icon(Icons.search),
        title: const Text(""),
      ),
      itemCount: 0,
    );
  }
}
