import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

Future<bool> uploadImage(File image) async {

  final String nameFile = image.path.split('/').last;

  Reference ref = storage.ref().child('clasificador').child(nameFile);

  final UploadTask uploadTask = ref.putFile(image);

  final TaskSnapshot snap = await uploadTask.whenComplete(() => true);

  final String urls = await snap.ref.getDownloadURL();
  print(urls);

  if (snap.state == TaskState.success) {
    return true;
  } else {
      return false;
  }

}
