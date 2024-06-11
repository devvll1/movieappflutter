import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:villa_moviecollection_app/styles/add_movie_page.dart';
import 'styles/app_color.dart';

class Movie {
  final String title;
  final String director;
  final String imageUrl;
  final double rating;

  Movie({
    required this.title,
    required this.director,
    required this.imageUrl,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'director': director,
        'imageUrl': imageUrl,
        'rating': rating,
      };

  static Movie fromJson(Map<String, dynamic> json) => Movie(
        title: json['title'],
        director: json['director'],
        imageUrl: json['imageUrl'],
        rating: json['rating'],
      );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final moviesString = prefs.getString('movies');
    if (moviesString != null) {
      final moviesJson = json.decode(moviesString) as List;
      setState(() {
        _movies = moviesJson.map((json) => Movie.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final moviesJson = _movies.map((movie) => movie.toJson()).toList();
    final moviesString = json.encode(moviesJson);
    await prefs.setString('movies', moviesString);
  }

  void _addMovie(Movie movie) {
    setState(() {
      _movies.add(movie);
      _saveMovies();
    });
  }

  void _removeMovie(int index) {
    setState(() {
      _movies.removeAt(index);
      _saveMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: Text('My Movie List'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          return _buildMovieItem(context, _movies[index], index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMoviePage(),
            ),
          );
          if (result != null && result is Movie) {
            _addMovie(result);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildMovieItem(BuildContext context, Movie movie, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      movie.director,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow),
                        SizedBox(width: 5),
                        Text(
                          movie.rating.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _removeMovie(index),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.close,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
