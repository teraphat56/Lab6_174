import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teraphat174_6/screen/formscreen.dart'; // ตรวจสอบเส้นทางให้ตรงกับโปรเจกต์

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> deleteStudent(String documentId) async {
    await _firestore.collection('student').doc(documentId).delete();
  }

  Future<void> showDeleteConfirmation(String documentId) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการทำงาน'),
          content: const Text('คุณต้องการลบข้อมูลนี้จริงหรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Formscreen(docId: documentId),
                  ),
                );
              },
              child: const Text('แก้ไข'),
            ),
            TextButton(
              onPressed: () async {
                await deleteStudent(documentId);
                Navigator.pop(context);
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายงานคะแนนสอบ"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 138, 224, 174),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("student").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              return Container(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: FittedBox(child: Text(document["score"])),
                  ),
                  title: Text(document["fname"] + " " + document["lname"]),
                  subtitle: Text(document["email"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Formscreen(docId: document.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await showDeleteConfirmation(document.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}