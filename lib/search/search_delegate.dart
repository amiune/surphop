import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surphop/search/timeline_searchresult_page.dart';
import 'package:surphop/search/usertimelines_searchresult_page.dart';

class CustomSearchDelegate extends SearchDelegate {
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

  Future<String> getUserByEmail(String email) async {
    String searchedUserId = "";
    await FirebaseFirestore.instance
        .collection('emailtouid')
        .where('email', isEqualTo: email)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              searchedUserId = element["userId"];
            }))));
    return searchedUserId;
  }

  Future<Map<String, String>> getTimelinesByName(
      String timelineSearchTerm) async {
    Map<String, String> searchResults = {};
    await FirebaseFirestore.instance
        .collection('timelines')
        .where('tags', arrayContains: timelineSearchTerm.toLowerCase())
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              searchResults[element.reference.id] = element["timelineName"];
            }))));

    return searchResults;
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.contains("@")) {
      return FutureBuilder<String>(
          future: getUserByEmail(query),
          builder: ((context, snapshot) {
            return Container(
              margin: const EdgeInsets.all(20),
              child: snapshot.data != null && snapshot.data! != ""
                  ? Card(
                      color: Colors.blue[200],
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return UserTimelines(
                              userId: snapshot.data!,
                              userEmail: query,
                            );
                          }));
                        },
                        child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(query)),
                      ),
                    )
                  : const Center(
                      child: Text(
                      "User email not found",
                      style: TextStyle(fontSize: 30),
                    )),
            );
          }));
    } else {
      return FutureBuilder<Map<String, String>>(
          future: getTimelinesByName(query),
          builder: ((context, snapshot) {
            return Container(
              margin: const EdgeInsets.all(20),
              child: snapshot.data != null && snapshot.data!.isNotEmpty
                  ? ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      scrollDirection: Axis.vertical,
                      children: List.generate(snapshot.data!.length, (index) {
                        var item = snapshot.data!.values.elementAt(index);
                        return Card(
                          color: Colors.blue[200],
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PublicTimelineVideos(
                                  timelineId:
                                      snapshot.data!.keys.elementAt(index),
                                  timelineName:
                                      snapshot.data!.values.elementAt(index),
                                );
                              }));
                            },
                            child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                    color: Colors.blue[200],
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(item)),
                          ),
                        );
                      }))
                  : const Center(
                      child: Text(
                      "No results",
                      style: TextStyle(fontSize: 30),
                    )),
            );
          }));
    }
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
