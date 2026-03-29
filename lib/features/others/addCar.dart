//  Future<void> updateProfile(
//     String firstName,
//     String lastName,
//     String gender,
//   ) async {
//     final user = FirebaseAuth.instance.currentUser;

//     await FirebaseFirestore.instance.collection('users').doc(user?.uid).set(
//       {
//         'first_name': firstName,
//         'last_name': lastName,
//         'gender': gender,
//         'updated_at': DateTime.now(),
//       },
//       SetOptions(merge: true),
//     ); // merge: true คือการอัปเดตเฉพาะฟิลด์ที่ส่งไป ไม่ลบอันเก่า
//   }

//   var snapshot = await FirebaseFirestore.instance.collection('users').doc('uid').get();
// if (snapshot.metadata.isFromCache) {
//   print("อันนี้ฟรี! ดึงจากเครื่อง");
// } else {
//   print("อันนี้เสียตังค์/เสียโควตา! ดึงจาก Server");
// }
