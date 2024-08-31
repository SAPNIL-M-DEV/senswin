import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/firestore.dart';
import 'dart:developer' as devtools show log;
import '../constants/enums.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  void opneNoteBox(String? docID) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextFormField(
                decoration:
                    const InputDecoration(hintText: "Enter you question"),
                controller: textController,
              ),
              actions: [
                FilledButton(
                    onPressed: () {
                      //add a new note
                      if (docID == null) {
                        firestoreService.addNote(textController.text);
                      }
                      //update a existing note
                      else {
                        firestoreService.updateNote(docID, textController.text);
                      }

                      //clear the text controller
                      textController.clear();
                      //close the box
                      Navigator.pop(context);
                    },
                    child: const Text('Add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogoutDialog(context);
                devtools.log(shouldLogout.toString());
                if (shouldLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (context) => false);
                }
              case MenuAction.settings:
                Navigator.of(context).pushNamed(
                  settingsRoute,
                );
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text("LOGOUT"),
              ),
              PopupMenuItem<MenuAction>(
                value: MenuAction.settings,
                child: Text("SETTINGS"),
              )
            ];
          }),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            //if we have data get all notes
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              //display as a list
              return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    //get individual doc
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;

                    //get note from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    //display as a list tilee
                    return ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => opneNoteBox(docID),
                            icon: const Icon(Icons.settings),
                          ),
                          IconButton(
                            onPressed: () => firestoreService.deleteNote(docID),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                      title: Text(
                        noteText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(8.0),
                      style: ListTileStyle.drawer,
                    );
                  });
            }
            //if there is no data
            else {
              return const Text("no notes....");
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          opneNoteBox(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out??"),
        actions: [
          FilledButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel")),
          FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Sign out"))
        ],
      );
    },
  ).then((value) => value ?? false);
}
