import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerWidget(), // 將 ImagePickerWidget 放在 MaterialApp 中
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImagePickerState();
  }
}

class _ImagePickerState extends State<ImagePickerWidget> {
  var _imgPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ImagePicker"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _ImageView(_imgPath),
            Container(
              margin: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _takePhoto,
                child: Text("拍照"),
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _openGallery,
                child: Text("選擇相片"),
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _ImageView(imgPath) {
    if (imgPath == null) {
      return Center(
        child: Text("選擇相片或拍照"),
      );
    } else {
      return Image.file(
        imgPath,
      );
    }
  }

  /*拍照*/
  _takePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if(image == null) return;
    final imageTemp = File(image.path);
    setState(() {
      _imgPath = imageTemp;
    });
  }

  _openGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image == null) return;
    final imageTemp = File(image.path);
    setState(() {
      _imgPath = imageTemp;
    });
  }


}
