import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/models/box.dart';
import 'package:lockbox/pages/single_box_view.dart';
import 'add_box.dart';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:lockbox/backend/backend.dart';

import 'package:appwrite/appwrite.dart';

class BoxView extends ConsumerStatefulWidget {
  @override
  _BoxViewState createState() => _BoxViewState();
}

class _BoxViewState extends ConsumerState<BoxView> {
  String searchFilter = '';
  TextEditingController searchController = TextEditingController();
  final debouncer = Debouncer(Duration(milliseconds: 500), initialValue: '');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // generate some
  List<Box> boxes = [];

  void fetchBoxes() async {
    Databases db = Databases(ref.read(appwriteProvider).client);

    Future<DocumentList> result = db.listDocuments(
        databaseId: "64a39d6a559df30e0c7a",
        collectionId: "64a39d7839a6c259cf53",
        queries: [
          Query.equal("userID", ref.read(appwriteProvider).getUser()),
          Query.search("username", searchFilter.toLowerCase()),
        ]);

    DocumentList list = await result;

    List<Box> boxes = [];

    for (Document doc in list.documents) {
      boxes.add(Box.fromJson(jsonDecode(doc.data.toString())));
    }

    setState(() {
      this.boxes = boxes;
    });
  }

  @override
  void initState() {
    super.initState();
    // get boxes for currently logged in user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBoxes();
    });

    searchController.addListener(() {
      debouncer.value = searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    debouncer.values.listen((event) {
      setState(() {
        searchFilter = event;
      });
    });

    Databases db = Databases(ref.read(appwriteProvider).client);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.orange,
        onPressed: () {
          // modal

          showModalBottomSheet(
              isScrollControlled: true,
              useSafeArea: true,
              context: context,
              builder: (context) {
                return AddPage();
              });
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(
          'Vault',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 50,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  floatingLabelStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  labelText: 'Search for passwords, tags...',
                ),
              ),
            ),
            boxes.isEmpty
                ? const Center(child: Text('No boxes'))
                : Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SingleBoxViewPage(
                                            boxId: boxes[index].userId,
                                          )));
                            },
                            title: Text(boxes[index].title),
                            subtitle: Text(boxes[index].username),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: Colors.grey, width: 0.5),
                            ),
                          ),
                        );
                      },
                      itemCount: boxes.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
