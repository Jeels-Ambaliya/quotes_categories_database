import 'dart:math';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quotes_categories_database/views/screens/material.dart';

import '../../globals/globals.dart';
import '../../helpers/db_helpers.dart';
import '../../models/quotes.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({Key? key}) : super(key: key);

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  late Future<List<Background>> getBackground;

  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final TextEditingController quotesController = TextEditingController();

  int currentIndex = 0;
  String? quote;
  Uint8List? imageBytes;
  Random random = Random();

  getFromGallery() async {
    ImagePicker picker = ImagePicker();

    XFile? xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    imageBytes = await xFile!.readAsBytes();
  }

  @override
  void initState() {
    super.initState();
    getBackground = DBHelper.dbHelper.fetchAllBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "JEELS QUOTES",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselSlider(
                    items: Globals.mySliderImage
                        .map(
                          (e) => Container(
                            width: double.infinity,
                            height: 300,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: AssetImage(
                                  e,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      onPageChanged: (i, result) {
                        setState(() {
                          currentIndex = i;
                        });
                      },
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(seconds: 1),
                      autoPlayCurve: Curves.easeIn,
                      enlargeCenterPage: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        Globals.mySliderImage.length,
                        (index) => Container(
                          height: 10,
                          width: currentIndex == index ? 30 : 10,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: currentIndex == index
                                ? Colors.blueGrey
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //most popular
                  const Text(
                    "Most Popular",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: FutureBuilder(
                future: getBackground,
                builder: (context, snapShot) {
                  if (snapShot.hasError) {
                    return Center(
                      child: Text("ERROR : ${snapShot.error}"),
                    );
                  } else if (snapShot.hasData) {
                    List<Background>? data = snapShot.data;

                    return (data == null || data.isEmpty)
                        ? const Center(
                            child: Text(
                              "No Data Available....",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 8,
                            children: List.generate(
                              data.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Editing_Page(
                                        listBackground: data,
                                        img: data[index].Image!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade100,
                                    image: DecorationImage(
                                      image: MemoryImage(data[index].Image!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              insertQuotes();
            },
            child: Container(
              height: 60,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.request_quote,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: GestureDetector(
              onTap: () {
                insertImages();
              },
              child: Container(
                height: 60,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.image,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void insertQuotes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("Insert Quote"),
          ),
          content: Form(
            key: insertFormKey,
            child: TextFormField(
              controller: quotesController,
              validator: (val) {
                if (val!.isEmpty) {
                  return "Enter Quotes first.....";
                }
                return null;
              },
              onSaved: (val) {
                quote = val;
              },
              decoration: InputDecoration(
                labelText: "Quote",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                quotesController.clear();
                setState(() {
                  quote = null;
                });
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            OutlinedButton(
              onPressed: () async {
                if (insertFormKey.currentState!.validate()) {
                  insertFormKey.currentState!.save();

                  Quote q1 = Quote(Quote_Text: quote!);

                  int id_Q = await DBHelper.dbHelper.insertText(quote: q1);

                  if (id_Q > 0) {
                    setState(() {
                      getBackground = DBHelper.dbHelper.fetchAllBackground();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(" No : $id_Q Quote Inserted successfully..."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Record Insertion failed..."),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }

                quotesController.clear();

                setState(() {
                  quote = null;
                });

                Navigator.pop(context);
              },
              child: const Text("Insert"),
            ),
          ],
        );
      },
    );
  }

  void insertImages() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("Insert Background"),
          ),
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                getFromGallery();
              },
              child: CircleAvatar(
                radius: 38,
                backgroundColor: Colors.deepPurple.shade100,
                child: const Text(
                  "ADD",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  imageBytes = null;
                });
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            OutlinedButton(
              onPressed: () async {
                Background b1 = Background(Image: imageBytes!);

                int id_B =
                    await DBHelper.dbHelper.insertBackground(background: b1);

                if (id_B > 0) {
                  setState(() {
                    getBackground = DBHelper.dbHelper.fetchAllBackground();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "No : $id_B Background Inserted successfully..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Record Insertion failed..."),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                quotesController.clear();

                setState(() {
                  quote = null;
                  imageBytes = null;
                });

                Navigator.pop(context);
              },
              child: const Text("Insert"),
            ),
          ],
        );
      },
    );
  }

  Widget myQuotes({required String image, required String name}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 150,
          width: MediaQuery.of(context).size.width * 0.43,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
