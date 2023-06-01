import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/models/box.dart';
import 'package:lockbox/pages/single_box_view.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:lockbox/authProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  String searchFilter = '';
  TextEditingController searchController = TextEditingController();

  final debouncer =
      Debouncer<String>(const Duration(milliseconds: 500), initialValue: '');

  late User? user;
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // generate some
  List<Box> boxes = [];

  @override
  void initState() {
    super.initState();
    // get boxes for currently logged in user
    user = ref.read(authProvider).currentUser;
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
    final boxRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('boxes')
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
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
            StreamBuilder(
              stream: boxRef,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var documents = snapshot.data!.docs.where((element) {
                  return element['favorite'] == true &&
                      (element['title']
                              .toString()
                              .toLowerCase()
                              .contains(searchFilter.toLowerCase()) ||
                          element['username']
                              .toString()
                              .toLowerCase()
                              .contains(searchFilter.toLowerCase()) ||
                          // check if in tags
                          element['tags']
                              .toString()
                              .toLowerCase()
                              .contains(searchFilter.toLowerCase()));
                });

                return snapshot.data!.docs.isEmpty || documents.isEmpty
                    ? const Text('No favorite boxes')
                    : Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: documents
                              .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SingleBoxViewPage(
                                                    boxId: document.id,
                                                  )));
                                    },
                                    title: Text(data['title']),
                                    subtitle: Text(data['username']),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                  ),
                                );
                              })
                              .toList()
                              .cast(),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
