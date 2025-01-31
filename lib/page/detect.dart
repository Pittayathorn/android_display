import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class HomeWidget extends StatelessWidget {
  final String payload;
  final String? className;
  final String? score;
  final Color shadowColor;
  final dynamic videoPlayerController;
  final dynamic videoPlayerController2;

  HomeWidget({
    required this.payload,
    required this.className,
    required this.score,
    required this.shadowColor,
    this.videoPlayerController,
    this.videoPlayerController2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // คอลัมน์ที่มีตัวเล่นวิดีโอ
            Column(
              children: [
                videoPlayerController != null
                    ? SizedBox(
                        width: 450,
                        height: 250,
                        child: VlcPlayer(
                          controller: videoPlayerController,
                          aspectRatio: 16 / 9,
                          placeholder:
                              Center(child: CircularProgressIndicator()),
                        ),
                      )
                    : CircularProgressIndicator(),
                videoPlayerController2 != null
                    ? SizedBox(
                        width: 450,
                        height: 250,
                        child: VlcPlayer(
                          controller: videoPlayerController2,
                          aspectRatio: 16 / 9,
                          placeholder:
                              Center(child: CircularProgressIndicator()),
                        ),
                      )
                    : CircularProgressIndicator(),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('RESULT# 0'),
                      Text('MED# 0'),
                      Text('LABEL# 0'),
                      Text('CLASS# $className'),
                      Text('SCORE# $score'),
                      Text('FEEDBACK# 0'),
                      Text('USER FEEDBACK# 0'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 0),
                              height: 100,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  payload,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [BoxShadow()],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(width: 20),
                                      Image.asset(
                                        'assets/images/2.png',
                                        width: 50,
                                        height: 100,
                                      ),
                                      SizedBox(width: 30),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ข้อความที่ 1',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'ข้อความที่ 2',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 33, 243, 96),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'ข้อความที่ 3',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 30),
                                      Image.asset(
                                        'assets/images/3.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // ชิดขวา
                        children: [
                          Container(
                            padding:
                                EdgeInsets.all(50), // กำหนดระยะห่างภายในวงกลม
                            decoration: BoxDecoration(
                              color: Colors.blue, // สีพื้นหลังของวงกลม
                              shape:
                                  BoxShape.circle, // ทำให้ container เป็นวงกลม
                            ),
                            child: Text(
                              'ถูกต้อง', // ข้อความที่ต้องการแสดง
                              style: TextStyle(
                                color: Colors.white, // สีของข้อความ
                                fontSize: 24, // ขนาดของข้อความ
                                fontWeight:
                                    FontWeight.bold, // ขนาดตัวหนา (หากต้องการ)
                              ),
                            ),
                          ),
                          SizedBox(height: 20), // ระยะห่างระหว่างวงกลม
                          Container(
                            padding:
                                EdgeInsets.all(50), // กำหนดระยะห่างภายในวงกลม
                            decoration: BoxDecoration(
                              color: Colors.blue, // สีพื้นหลังของวงกลม
                              shape:
                                  BoxShape.circle, // ทำให้ container เป็นวงกลม
                            ),
                            child: Text(
                              'ไม่ถูกต้อง', // ข้อความที่ต้องการแสดง
                              style: TextStyle(
                                color: Colors.white, // สีของข้อความ
                                fontSize: 20, // ขนาดของข้อความ
                                fontWeight:
                                    FontWeight.bold, // ขนาดตัวหนา (หากต้องการ)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
