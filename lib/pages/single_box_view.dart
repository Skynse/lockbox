import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/authProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debounce_throttle/debounce_throttle.dart';

class SingleBoxViewPage extends ConsumerStatefulWidget {
  final String boxId;

  const SingleBoxViewPage({Key? key, required this.boxId}) : super(key: key);

  @override
  _SingleBoxViewPageState createState() => _SingleBoxViewPageState();
}

class _SingleBoxViewPageState extends ConsumerState<SingleBoxViewPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  bool obscurePassword = true;

  final debouncer = Debouncer(Duration(milliseconds: 500), initialValue: '');

  List<String> tags = [];
  bool isFavorite = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usernameController.addListener(() {
      debouncer.value = usernameController.text;
    });

    passwordController.addListener(() {
      debouncer.value = passwordController.text;
    });

    urlController.addListener(() {
      debouncer.value = urlController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    saveState() {
      FirebaseFirestore.instance
          .collection('users')
          .doc(ref.read(authProvider).currentUser!.uid)
          .collection('boxes')
          .doc(widget.boxId)
          .update({
        'username': usernameController.text,
        'password': passwordController.text,
        'url': urlController.text,
        'tags': tags,
        'favorite': isFavorite,
      });
    }

    debouncer.values.listen((event) {
      //snackbar to remember to save
      saveState();
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          // save
          ElevatedButton.icon(
            label: const Text('Save'),
            onPressed: () {
              // save
              saveState();
            },
            icon: const Icon(Icons.save),
          ),
        ],
        title: const Text('Vault'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(ref.read(authProvider).currentUser!.uid)
              .collection('boxes')
              .doc(widget.boxId)
              .get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              usernameController.text = data['username'];
              passwordController.text = data['password'];
              urlController.text = data['url'];
              tags = List<String>.from(data['tags']);
              isFavorite = data['favorite'];

              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              width: 100,
                              height: 100,
                              child: const Icon(Icons.person)),
                          const SizedBox(width: 16),
                          Text(data['title'],
                              style: const TextStyle(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        obscureText: obscurePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon:
                                    const Icon(Icons.remove_red_eye_outlined))),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: urlController,
                        decoration: const InputDecoration(
                            labelText: 'URL',
                            labelStyle: TextStyle(color: Colors.orange),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            floatingLabelStyle: TextStyle(color: Colors.orange),
                            floatingLabelAlignment:
                                FloatingLabelAlignment.start),
                      ),
                      const SizedBox(height: 16),
                      const Text("Tags", style: const TextStyle(fontSize: 24)),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (var tag in tags)
                            Chip(
                              label: Text(tag),
                              onDeleted: () {
                                setState(() {
                                  tags.remove(tag);
                                  saveState();
                                });
                              },
                            ),
                          // add new tag
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: tagsController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Add Tag',
                              ),
                              onFieldSubmitted: (value) {
                                setState(() {
                                  tags.add(value);
                                  tagsController.clear();
                                  saveState();
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      isFavorite == false
                          ? ListTile(
                              title: const Text("Add to favorites"),
                              leading: Icon(Icons.star_border),
                              onTap: () {
                                setState(
                                  () {
                                    isFavorite = true;
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(ref
                                            .read(authProvider)
                                            .currentUser!
                                            .uid)
                                        .collection('boxes')
                                        .doc(widget.boxId)
                                        .update({
                                      'favorite': true,
                                    });
                                  },
                                );
                              })
                          : ListTile(
                              title: const Text("Remove from favorites"),
                              leading: const Icon(Icons.star),
                              onTap: () {
                                setState(
                                  () {
                                    isFavorite = false;
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(ref
                                            .read(authProvider)
                                            .currentUser!
                                            .uid)
                                        .collection('boxes')
                                        .doc(widget.boxId)
                                        .update({
                                      'favorite': false,
                                    });
                                  },
                                );
                              }),

                      // delete
                      ListTile(
                        title: const Text("Delete"),
                        leading: Icon(Icons.delete),
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(ref.read(authProvider).currentUser!.uid)
                              .collection('boxes')
                              .doc(widget.boxId)
                              .delete();

                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              });
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
