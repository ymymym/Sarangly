import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sarangly/authentication/authentication.dart';
import 'package:sarangly/global/color.dart';
import 'package:sarangly/global/global.dart';
import 'package:sarangly/models/DriveImage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ImagesPage extends StatefulWidget {
  ImagesPage({Key key}) : super(key: key);

  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  List<DriveImage> _images = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$APP_NAME'),
          backgroundColor: primaryColor,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.photo),
              onPressed: () {
                _uploadImages();
              },
            ),
          ],
        ),
        body: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 1.5,
            crossAxisSpacing: 1.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _images.map((DriveImage image) {
              return GridTile(
                child: CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  imageUrl: image.url,
                  placeholder: (context, url) => Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primaryColor)),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              );
            }).toList()));
  }

  /// Get images from gallery or camera and upload to Google Drive.
  void _uploadImages() async {
    // Using multi image_picker package to prompt user for a photo.
    final images = await MultiImagePicker.pickImages(
      enableCamera: true,
      maxImages: 10,
    );

    setState(() {
      _loading = true;
    });

    // Upload photos to Google Drive
    await BlocProvider.of<AuthenticationBloc>(context)
        .userRepository
        .uploadImage(images);

    // Reload files after uploading
    _loadFiles();
  }

  /// Load images from Google Drive
  void _loadFiles() async {
    List<DriveImage> files = await BlocProvider.of<AuthenticationBloc>(context)
        .userRepository
        .images();
    setState(() {
      _images = files;
      _loading = false;
    });
  }
}
