import 'dart:convert';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_juste_coin/models/analyze.dart';
import 'package:le_juste_coin/models/verification.dart';
import 'package:le_juste_coin/pages/full_image.dart';
import 'package:le_juste_coin/utils/color_utils.dart';
import 'package:le_juste_coin/utils/font_utils.dart';
import 'package:http/http.dart' as http;

class VerificationSheet extends StatefulWidget {
  final Analyze analyze;

  const VerificationSheet({Key? key, required this.analyze}) : super(key: key);

  @override
  _VerificationSheetState createState() => _VerificationSheetState();
}

class _VerificationSheetState extends State<VerificationSheet> {
  int _verifyPageIndex = 0;
  List<Verification> _verifiedCoins = [];
  String _errorMessage = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _verifiedCoins = widget.analyze.items
          .map((AnalyzedItem item) =>
              Verification(item.id, CoinSide.REVERSE, item.cents))
          .toList();
    });
  }

  void sendForCorrection(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    final FirebaseAuth auth = FirebaseAuth.instance;
    String endpoint = dotenv.env['API_URL']! + '/feedback';

    String data =
        jsonEncode(_verifiedCoins.map((verif) => verif.toJson()).toList());

    final response = await http.post(Uri.parse(endpoint),
        headers: {'Authorization': auth.currentUser!.uid}, body: data);

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Merci pour votre retour !'),
          backgroundColor: ColorUtils.success));
    } else {
      setState(() {
        _errorMessage = response.body;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(
              child: PageView(
                  onPageChanged: (int newPageIndex) {
                    setState(() {
                      _verifyPageIndex = newPageIndex;
                    });
                  },
                  children: [
                ..._verifiedCoins.map((Verification verif) {
                  return Column(
                    children: [
                      Text(verif.id, style: FontUtils.title),
                      SizedBox(height: 8),
                      Row(children: [
                        FutureBuilder(
                          future: verif.getImageUrl(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> image) {
                            if (image.hasData) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FullImage(
                                          title: verif.id,
                                          imagePath: image.data!);
                                    }));
                                  },
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(image.data!,
                                          fit: BoxFit.fill,
                                          width: 64,
                                          height: 64))); // image is ready
                            } else {
                              return const CircularProgressIndicator(); // placeholder
                            }
                          },
                        ),
                        SizedBox(width: 16),
                        Text(
                            "Modifier les valeur pour qu'elles\ncorrespondent à celle de la pièce.",
                            style: FontUtils.content),
                      ]),
                      Divider(height: 16),
                      Text('Quelle est le côté ?', style: FontUtils.header),
                      RadioListTile<CoinSide>(
                        title: const Text('Pile'),
                        value: CoinSide.REVERSE,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.side,
                        onChanged: (CoinSide? value) {
                          verif.side = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                      RadioListTile<CoinSide>(
                        title: const Text('Face'),
                        value: CoinSide.OBVERSE,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.side,
                        onChanged: (CoinSide? value) {
                          verif.side = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                      Text('Quelle est la pièce sur la photo ?',
                          style: FontUtils.header),
                      RadioListTile<int>(
                        title: const Text('2€'),
                        value: 200,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.value,
                        onChanged: (int? value) {
                          verif.value = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('1€'),
                        value: 100,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.value,
                        onChanged: (int? value) {
                          verif.value = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('0,50€'),
                        value: 50,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.value,
                        onChanged: (int? value) {
                          verif.value = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('0,20€'),
                        value: 20,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.value,
                        onChanged: (int? value) {
                          verif.value = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('0,10€'),
                        value: 10,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.value,
                        onChanged: (int? value) {
                          verif.value = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('0,05€'),
                        value: 5,
                        activeColor: ColorUtils.gold,
                        groupValue: verif.value,
                        onChanged: (int? value) {
                          verif.value = value!;

                          setState(() {
                            _verifiedCoins = _verifiedCoins;
                          });
                        },
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  );
                }),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finalisation', style: FontUtils.title),
                    SizedBox(height: 64),
                    _errorMessage != ""
                        ? Text(_errorMessage, style: FontUtils.contentDanger)
                        : Text(
                            'Je certifie que les données envoyées sont correctes.', style: FontUtils.content),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: ColorUtils.success.withOpacity(_loading ? 0.5 : 1),
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          )),
                      onPressed: _loading ? null : () {
                        sendForCorrection(context);
                      },
                      child: Text(_loading ? "Traitement..." : "Envoyer la vérification"),
                    )
                  ],
                )
              ])),
          DotsIndicator(
              dotsCount: _verifiedCoins.length + 1,
              position: _verifyPageIndex.toDouble(),
              decorator: DotsDecorator(
                size: const Size.square(9.0),
                activeSize: const Size(18.0, 9.0),
                activeColor: ColorUtils.blue,
                activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ))
        ]));
  }
}
