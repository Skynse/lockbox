import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lockbox/models/box.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController tagsController = TextEditingController();

  List<String> tags = [];

  @override
  void dispose() {
    titleController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Box'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              TextFormField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              TextFormField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'url',
                ),
              ),

              // tags
              Container(
                margin: const EdgeInsets.only(top: 16),
                // render tags as chips but also allow user to add new tags
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (var tag in tags)
                      Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            tags.remove(tag);
                          });
                        },
                      ),
                    // add new tag
                    Container(
                      width: 100,
                      child: TextFormField(
                        controller: tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Add Tag',
                        ),
                        onFieldSubmitted: (value) {
                          setState(() {
                            tags.add(value);
                            tagsController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // add to firestore
                    final auth = FirebaseAuth.instance;
                    final user = auth.currentUser;

                    final db = FirebaseFirestore.instance;
                    await db
                        .collection('users')
                        .doc(user!.uid)
                        .collection('boxes')
                        .add(
                          Box.fromMap({
                            'title': titleController.text,
                            'username': usernameController.text,
                            'password': passwordController.text,
                            'url': urlController.text,
                            'tags': tags,
                            'favorite': false,
                          }).toMap(),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
