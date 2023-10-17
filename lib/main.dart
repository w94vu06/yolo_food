import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerWidget(),
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
  TextEditingController fileNameController = TextEditingController();
  GoogleTranslator translator = new GoogleTranslator();

  Future<void> _uploadFile(String fileName) async {
    if (_imgPath == null) {
      print("沒有文件");
      return;
    }

    var url = Uri.parse('https://d819-59-126-42-176.ngrok-free.app/upload');
    var request = http.MultipartRequest('POST', url);

    final translation = await translator.translate(fileName, from: 'zh-cn', to: 'en');
    fileName = translation.text; // 使用翻譯後的檔名

    request.fields['description'] = fileName;
    request.files.add(
      await http.MultipartFile.fromPath('file', _imgPath.path, contentType: MediaType('image', 'jpeg')),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      print('圖片上傳成功');
    } else {
      print('圖片上傳失敗');
    }
  }

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

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
              width: 300,
              child: Visibility(
                visible: _imgPath != null,
                child: TextField(
                  controller: fileNameController,
                  decoration: InputDecoration(
                    hintText: "圖裡有什麼菜，例如：高麗菜+雞排",
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _takePhoto,
                child: Text("拍照"),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _openGallery,
                child: Text("選擇相片"),
              ),
            ),
            Visibility(
              visible: _imgPath != null,
              child: Container(
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    if (_imgPath != null) {
                      _uploadFile(fileNameController.text);
                    }
                  },
                  child: Text("上傳"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ImageView(File? imgPath) {
    if (imgPath == null) {
      return Center(
        child: Text("選擇相片或拍照"),
      );
    } else {
      return Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Image.file(imgPath),
        ),
      );
    }
  }

  _takePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _imgPath = File(image.path);
    });
  }

  _openGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _imgPath = File(image.path);
    });
  }
}
