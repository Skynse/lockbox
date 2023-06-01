import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/models/box.dart';
import 'package:lockbox/pages/single_box_view.dart';
import 'add_box.dart';
import 'package:lockbox/authProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debounce_throttle/debounce_throttle.dart';

class BoxView extends ConsumerStatefulWidget {
  @override
  _BoxViewState createState() => _BoxViewState();
}

class _BoxViewState extends ConsumerState<BoxView> {
  String searchFilter = '';
  TextEditingController searchController = TextEditingController();
  final debouncer = Debouncer(Duration(milliseconds: 500), initialValue: '');
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

                return snapshot.data!.docs.isEmpty
                    ? const Center(child: Text('No boxes'))
                    : Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: snapshot.data!.docs
                              .where((element) {
                                return element['title']
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
                                        .contains(searchFilter.toLowerCase());
                              })
                              .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                return ListTile(
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
