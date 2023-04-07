import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class Quote {
  String? Quote_Text;

  Quote({
    this.Quote_Text,
  });

  //Row data to Custom object (Map => Qoute)
  factory Quote.fromMap({required Map<String, dynamic> data}) {
    return Quote(
      Quote_Text: data['Quote'],
    );
  }
}

class Fav {
  late String Quote_Text;
  late String Family;
  late MemoryImage Image;

  Fav({
    required this.Image,
    required this.Quote_Text,
    required this.Family,
  });

  //Row data to Custom object (Map => Fav)
  factory Fav.fromMap({required Map<String, dynamic> data}) {
    return Fav(
      Image: data['Image'],
      Quote_Text: data['Quote'],
      Family: data['Family'],
    );
  }
}

class Background {
  Uint8List? Image;

  Background({
    this.Image,
  });

  //Row data to Custom object (Map => Background)
  factory Background.fromMap({required Map<String, dynamic> data}) {
    return Background(
      Image: data['Image'],
    );
  }
}
