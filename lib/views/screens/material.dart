import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../globals/globals.dart';
import '../../helpers/db_helpers.dart';
import '../../models/quotes.dart';

class Editing_Page extends StatefulWidget {
  final List<Background> listBackground;
  final Uint8List img;
  const Editing_Page(
      {Key? key, required this.listBackground, required this.img})
      : super(key: key);

  @override
  State<Editing_Page> createState() => _Editing_PageState();
}

class _Editing_PageState extends State<Editing_Page> {
  Future<void> _copyToClicpboard({required String Story}) async {
    await Clipboard.setData(
      ClipboardData(
        text: Story,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied To Clipboard'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  late Future<List<Quote>> getQuote;
  late Future<List<Fav>> getFav;

  Random random = Random();
  late int i;
  late int font;
  late MemoryImage mi;

  void imageLoad() {
    mi = MemoryImage(widget.img);
  }

  void changeBackground() {
    i = random.nextInt(widget.listBackground.length);
  }

  void changeFont() {
    font = random.nextInt(Globals.myFont.length);
  }

  @override
  void initState() {
    super.initState();
    imageLoad();
    changeBackground();
    changeFont();
    getQuote = DBHelper.dbHelper.fetchAllQuote();
    getFav = DBHelper.dbHelper.fetchAllFav();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: mi,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 400,
              left: 20,
              right: 20,
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 8,
                  child: FutureBuilder(
                    future: getQuote,
                    builder: (context, snapShot) {
                      if (snapShot.hasError) {
                        return Center(
                          child: Text("ERROR : ${snapShot.error}"),
                        );
                      } else if (snapShot.hasData) {
                        List<Quote>? data = snapShot.data;

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
                            : Text(
                                data[random.nextInt(data.length)].Quote_Text!,
                                style: TextStyle(
                                  fontFamily: Globals.myFont[font],
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
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
        ],
      ),
      floatingActionButton: Container(
        height: 70,
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.deepPurple.shade100,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  Fav f1 = Fav(
                    Image: mi,
                    Quote_Text:
                        "I have chosen to be happy because it's good for my health.",
                    Family: Globals.myFont[font],
                  );

                  int id_F = await DBHelper.dbHelper.insertFav(fav: f1);

                  if (id_F > 0) {
                    setState(() {
                      getFav = DBHelper.dbHelper.fetchAllFav();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            " No : $id_F Favourite Inserted successfully..."),
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
                },
                icon: const Icon(
                  Icons.favorite,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  _copyToClicpboard(
                    Story:
                        "I have chosen to be happy because it's good for my health.",
                  );
                },
                icon: const Icon(
                  Icons.copy,
                  size: 35,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    Share.share("Hello I am Jeels Ambaliya");
                  });
                },
                icon: const Icon(
                  Icons.share_rounded,
                  size: 35,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    changeBackground();
                    mi = MemoryImage(widget.listBackground[i].Image!);
                  });
                },
                icon: const Icon(
                  Icons.camera,
                  size: 35,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(
                  Icons.text_fields,
                  size: 35,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    changeFont();
                  });
                },
                icon: const Icon(
                  Icons.text_format_sharp,
                  size: 35,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
