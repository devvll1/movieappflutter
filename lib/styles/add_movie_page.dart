import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:villa_moviecollection_app/home_page.dart';

class AddMoviePage extends StatefulWidget {
  @override
  _AddMoviePageState createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _directorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();
  String? _imageUrl;

  Future<void> _pickImage() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);

      reader.onLoadEnd.listen((event) {
        setState(() {
          _imageUrlController.text = (reader.result as String?) ?? '';
          _imageUrl = reader.result as String?;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Movie'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _directorController,
                decoration: InputDecoration(labelText: 'Director'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a director';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please pick an image';
                  }
                  return null;
                },
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              _imageUrl != null
                  ? Image.network(
                      _imageUrl!,
                      height: 100,
                    )
                  : Container(),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rating';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newMovie = Movie(
                      title: _titleController.text,
                      director: _directorController.text,
                      imageUrl: _imageUrlController.text,
                      rating: double.parse(_ratingController.text),
                    );
                    Navigator.pop(context, newMovie);
                  }
                },
                child: Text('Add Movie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
