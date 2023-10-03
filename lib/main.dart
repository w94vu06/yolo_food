import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  late MySqlConnection _connection;

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
  }

  Future<void> _connectToDatabase() async {
    final settings = ConnectionSettings(
      host: 'your_database_host',
      port: 3306,
      user: 'your_database_username',
      password: 'your_database_password',
      db: 'your_database_name',
    );

    _connection = await MySqlConnection.connect(settings);
  }

  // 函數：拍照
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // 函數：上傳圖片到文件系統並將路徑存儲到MariaDB
  Future<void> _uploadImageToDatabase() async {
    if (_image != null) {
      final String imagePath = 'images/${DateTime.now()}.png';

      // 上傳圖片到文件系統
      final File newImage = await _image!.copy(imagePath);

      // 將圖片路徑存儲到MariaDB
      final results = await _connection.query(
        'INSERT INTO images (image_path) VALUES (?)',
        [imagePath],
      );

      print('Image uploaded to database');
    }
  }

  @override
  void dispose() {
    _connection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('拍照和上傳示例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('未選擇圖片')
                : Image.file(
              _image!,
              height: 200.0,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('拍照'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _uploadImageToDatabase,
              child: Text('上傳圖片到MariaDB'),
            ),
          ],
        ),
      ),
    );
  }
}
