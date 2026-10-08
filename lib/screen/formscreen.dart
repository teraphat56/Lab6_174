import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:teraphat174_6/model/student.dart';

class Formscreen extends StatefulWidget {
  final String? docId; // ✅ เพิ่มรับค่าเอกสารที่จะแก้ไข

  const Formscreen({super.key, this.docId});

  @override
  State<Formscreen> createState() => _FormscreenState();
}

class _FormscreenState extends State<Formscreen> {
  final formkey = GlobalKey<FormState>();
  Student myStudent = Student(fname: "", lname: "", email: "", score: "");
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  // ✅ ตัวควบคุมช่องกรอก เพื่อโชว์ข้อมูลเดิม
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ถ้ามี docId แปลว่ามาแก้ไข → โหลดข้อมูลเดิม
    if (widget.docId != null) {
      loadStudentData();
    }
  }

  // ✅ โหลดข้อมูลเดิมมาแสดง
  Future<void> loadStudentData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('student')
        .doc(widget.docId)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      fnameController.text = data['fname'] ?? '';
      lnameController.text = data['lname'] ?? '';
      emailController.text = data['email'] ?? '';
      scoreController.text = data['score'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          CollectionReference studentCollection =
              FirebaseFirestore.instance.collection('student');

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.docId == null ? "บันทึกคะแนน" : "แก้ไขข้อมูล"),
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 138, 224, 174),
            ),
            body: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formkey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ชื่อ", style: TextStyle(fontSize: 20)),
                      TextFormField(
                        controller: fnameController, // ✅ เชื่อมตัวควบคุม
                        validator: RequiredValidator(errorText: "กรุณาป้อนชื่อด้วยครับ"),
                        onSaved: (fname) {
                          myStudent.fname = fname!;
                        },
                      ),
                      const SizedBox(height: 15),

                      const Text("นามสกุล", style: TextStyle(fontSize: 20)),
                      TextFormField(
                        controller: lnameController, // ✅ เชื่อมตัวควบคุม
                        validator: RequiredValidator(errorText: "กรุณาป้อนนามสกุลด้วยครับ"),
                        onSaved: (lname) {
                          myStudent.lname = lname!;
                        },
                      ),
                      const SizedBox(height: 15),

                      const Text("อีเมล์", style: TextStyle(fontSize: 20)),
                      TextFormField(
                        controller: emailController, // ✅ เชื่อมตัวควบคุม
                        keyboardType: TextInputType.emailAddress,
                        validator: MultiValidator([
                          RequiredValidator(errorText: "กรุณาป้อนอีเมล์ด้วยนะครับ"),
                          EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                        ]),
                        onSaved: (email) {
                          myStudent.email = email!;
                        },
                      ),
                      const SizedBox(height: 15),

                      const Text("คะแนน", style: TextStyle(fontSize: 20)),
                      TextFormField(
                        controller: scoreController, // ✅ เชื่อมตัวควบคุม
                        keyboardType: TextInputType.number,
                        validator: RequiredValidator(errorText: "กรุณาป้อนคะแนนด้วยครับ"),
                        onSaved: (score) {
                          myStudent.score = score!;
                        },
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              formkey.currentState!.save();

                              if (widget.docId == null) {
                                // ✅ โหมด เพิ่มใหม่
                                await studentCollection.add({
                                  "fname": myStudent.fname,
                                  "lname": myStudent.lname,
                                  "email": myStudent.email,
                                  "score": myStudent.score,
                                });
                                formkey.currentState!.reset();
                              } else {
                                // ✅ โหมด แก้ไข
                                await studentCollection.doc(widget.docId).update({
                                  "fname": myStudent.fname,
                                  "lname": myStudent.lname,
                                  "email": myStudent.email,
                                  "score": myStudent.score,
                                });
                                // กลับไปหน้ารายการหลังแก้เสร็จ
                                if (mounted) Navigator.pop(context);
                              }
                            }
                          },
                          child: Text(widget.docId == null ? "บันทึก" : "อัปเดต"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}