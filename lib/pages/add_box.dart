import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockbox/backend/backend.dart';

import 'package:lockbox/models/box.dart';

class AddPage extends ConsumerStatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddPage> {
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

                    final user = await ref.read(appwriteProvider).getUser();
                    String id = user.$id;
                    final db = Databases(ref.read(appwriteProvider).client);
                    await db.createDocument(
                        databaseId: "64a39d6a559df30e0c7a",
                        collectionId: "64a39d7839a6c259cf53",
                        documentId: ID.unique(),
                        data: {
                          "title": titleController.text,
                          "username": usernameController.text,
                          "password": passwordController.text,
                          "url": urlController.text,
                          "tags": tags,
                          "userID": id,
                        });
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
