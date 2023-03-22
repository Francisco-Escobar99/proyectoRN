import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Obtener una lista de las cámaras disponibles en el dispositivo.
  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // ignore: prefer_const_constructors
      theme: ThemeData(
          // ignore: prefer_const_constructors
          appBarTheme: AppBarTheme(
        color: const Color(0xFF0E6251),
      )),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

//permite a los usuarios tomar una foto usando una cámara dada.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    //mostrar la salida actual de la cámara,
    //crea un CameraController.
    _controller = CameraController(
      widget.camera,
      // Definir la resolución a usar.
      ResolutionPreset.medium,
    );

    //se inicializa el controlador, esto devuelve un future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(fontSize: 25, fontFamily: 'Cursiva'),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Si future está completo, muestra la vista previa.
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        //Proporciona una devolución de llamada onPressed.
        onPressed: () async {
          // Toma la foto en un bloque try/catch. Si algo sale mal captura el error.
          try {
            await _initializeControllerFuture;
            // se  toma una foto y se obtiene el archivo "imagen" donde se guardó.
            final image = await _controller.takePicture();

            if (!mounted) return;
            //Si se tomó la foto, mostrarla en una nueva pantalla.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  //se Pasa la ruta generada automáticamente al widget DisplayPictureScreen.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // Si ocurre un error, registre el error en la consola.
            print(e);
          }
        },
        // ignore: prefer_const_constructors
        backgroundColor: Color(0xFF0E6251),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// Un widget que muestra la foto tomada por el usuario.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Figura capturada',
              style: TextStyle(fontSize: 25, fontFamily: 'Cursiva'))),
      // La imagen se almacena como un archivo en el dispositivo. Use el constructor `Image.file con la ruta dada para mostrar la imagen.
      body: Image.file(File(imagePath)),
    );
  }
}
