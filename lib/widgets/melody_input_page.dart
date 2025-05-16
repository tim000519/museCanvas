// lib/widgets/melody_input_page.dart
import 'dart:async';
// import 'dart:convert';
import 'dart:io' show File, Directory;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

import '../models/note_event.dart';
import '../painters/sheet_music_painter.dart';
import '../services/api_service.dart';
import 'piano_key.dart';
import '../utils/file_saver.dart'; // 조건부 import: 웹일 경우 file_saver_web.dart, 모바일은 stub
import 'package:audioplayers/audioplayers.dart';

class MelodyInputPage extends StatefulWidget {
  const MelodyInputPage({super.key});

  @override
  _MelodyInputPageState createState() => _MelodyInputPageState();
}

class _MelodyInputPageState extends State<MelodyInputPage> {
  bool isRecording = false;
  Timer? metronomeTimer;
  int currentBeat = 0;
  DateTime? recordingStartTime;
  List<NoteEvent> recordedNotes = [];
  Map<String, DateTime> activeNotes = {};

  final int totalBeats = 32;
  final double bpm = 120.0;
  double get quarterNoteDuration => 60.0 / bpm;
  double get sixteenthNoteDuration => quarterNoteDuration / 4;

  final AudioPlayer _metronomePlayer = AudioPlayer();

  // 카운트다운 변수 (초)
  int countdown = -1;

  String selectedGenre = "JAZZ";

  Map<String, bool> selectedInstruments = {
    "Guitar": false,
    "Piano": false,
    "Drums": false,
  };

  // 3초 카운트다운 후 녹음 시작
 void startRecording() {
  countdown = 3;
  const int metronomeIntervalMs = 500;

  int tick = 0;
  int totalCountdownTicks = countdown * 2; // 0.5초 단위
  // int maxTicks = totalCountdownTicks + totalBeats; // 전체 녹음까지 포함

  setState(() {
    countdown = countdown;
    isRecording = false;
    currentBeat = 0;
    recordedNotes.clear();
    activeNotes.clear();
    recordingStartTime = null;
  });

  metronomeTimer = Timer.periodic(
    const Duration(milliseconds: metronomeIntervalMs),
    (timer) {
      // 항상 메트로놈 소리 재생
      _metronomePlayer
          .play(AssetSource('sounds/met.mp3'))
          .catchError((error) => print("Metronome error: $error"));

      // 카운트다운 중
      if (tick < totalCountdownTicks) {
        if (tick % 2 == 1) {
          setState(() {
            countdown--;
          });
        }
      }

      // 카운트다운 종료 직후 → 녹음 시작
      else if (tick == totalCountdownTicks) {
        setState(() {
          isRecording = true;
          recordingStartTime = DateTime.now();
          countdown = -1;
        });
      }

      // 녹음 중
      else {
        setState(() {
          currentBeat++;
        });

        if (currentBeat >= totalBeats) {
          timer.cancel();
          setState(() {
            isRecording = false;
          });
        }
      }

      tick++;
    },
  );
}
  void stopRecording() {
    metronomeTimer?.cancel();
    setState(() {
      isRecording = false;
    });
  }

  double quantizeTime(double inputTime) {
    return (inputTime / sixteenthNoteDuration).round() * sixteenthNoteDuration;
  }

  void onKeyPress(String note) {
    if (!isRecording) return;
    activeNotes[note] = DateTime.now();
  }

  void onKeyRelease(String note) {
    if (!isRecording) return;
    DateTime now = DateTime.now();
    if (activeNotes.containsKey(note)) {
      DateTime start = activeNotes[note]!;
      double startTimeSec = start.difference(recordingStartTime!).inMilliseconds / 1000.0;
      double endTimeSec = now.difference(recordingStartTime!).inMilliseconds / 1000.0;
      double durationSec = endTimeSec - startTimeSec;
      double quantizedStart = quantizeTime(startTimeSec);
      double quantizedDuration = quantizeTime(durationSec);
      NoteEvent event = NoteEvent(
        note: note,
        startTime: quantizedStart,
        duration: quantizedDuration,
      );
      setState(() {
        recordedNotes.add(event);
      });
      activeNotes.remove(note);
    }
  }

  Future<void> downloadMidiFile(
      BuildContext context, List<NoteEvent> recordedNotes, List<dynamic> genre) async {
    print("장르 설정: $genre");
    const serverUrl = "http://localhost:8000";
    final response = await processMelody(recordedNotes, serverUrl, genre);
    
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      if (kIsWeb) {
        await saveFile(bytes, "output.mid");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("MIDI 파일이 다운로드 됩니다.")),
        );
      } else {
        Directory dir = await getApplicationDocumentsDirectory();
        String filePath = "${dir.path}/output.mid";
        File midiFile = File(filePath);
        await midiFile.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("MIDI 파일이 저장되었습니다: $filePath")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버 처리 실패: ${response.statusCode}")),
      );
    }
  }

  @override
  void dispose() {
    metronomeTimer?.cancel();
    _metronomePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B', 'C_oct', 'D_oct', 'E_oct', 'F_oct', 'G_oct', 'A_oct', 'B_oct',];
    List<String?> blackKeys = ['C_sharp', 'D_sharp', null, 'F_sharp', 'G_sharp', 'A_sharp', null, 'C_sharp_oct', 'D_sharp_oct', null, 'F_sharp_oct', 'G_sharp_oct', 'A_sharp_oct', null];

    return Container(
      decoration: BoxDecoration(
        // color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/images/pp2.png'),
          // repeat: ImageRepeat.repeat,
          fit: BoxFit.cover,
          // opacity를 조절해 질감이 너무 두드러지지 않도록 조정
          opacity: 0.5,
        ),
      ),

      child: Scaffold(
        // backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(91, 70, 54, 1), /// 맨 위, 갈색
          elevation: 2,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.music_note, color: Color.fromARGB(255, 255, 251, 231), size: 30),
          ),
          title: const Text(
            'Music Canvas',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 251, 231),
              fontWeight: FontWeight.bold,
              fontSize: 25
            ),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 2000),
                child: Column(
                  children: [
                    // 카운트다운 / 녹음 상태 표시 영역
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          countdown > -1
                              ? 'Get ready! Starting in ${countdown} seconds...'
                              : isRecording
                                  ? 'Recording... Beat ${(currentBeat) ~/ 2}/16'
                                  : 'To start recording, press START.',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(153, 0, 0, 0),),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 피아노 건반 영역
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double whiteKeyWidth = 50;
                          double blackKeyWidth = whiteKeyWidth * 0.85;
                          return Stack(
                            children: [
                              // 흰 건반s
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: whiteKeys.map((note) {
                                  return SizedBox(
                                    width: whiteKeyWidth,
                                    child: PianoKey(
                                      note: note,
                                      onPress: () => onKeyPress(note),
                                      onRelease: () => onKeyRelease(note),
                                      isBlack: false,
                                    ),
                                  );
                                }).toList(),
                              ),
                              // 검은 건반 (흰 건반 위에 오버레이)
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.only(left: whiteKeyWidth),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: blackKeys.map((note) {
                                      return note != null
                                          ? SizedBox(
                                              width: whiteKeyWidth,
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: SizedBox(
                                                  width: blackKeyWidth,
                                                  height: 100,
                                                  child: PianoKey(
                                                    note: note,
                                                    onPress: () => onKeyPress(note),
                                                    onRelease: () => onKeyRelease(note),
                                                    isBlack: true,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(width: whiteKeyWidth);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 컨트롤 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isRecording) {
                              stopRecording();
                            } else {
                              startRecording();
                            }
                          },
                          icon: isRecording
                              ? const Icon(Icons.stop)
                              : const Icon(Icons.fiber_manual_record),
                          label: Text(isRecording ? 'STOP' : 'START'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 녹음된 노트 리스트
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey.shade50,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: recordedNotes
                    //         .map((e) => Text(
                    //             'Note ${e.note}: start ${e.startTime.toStringAsFixed(2)} s, duration ${e.duration.toStringAsFixed(2)} s'))
                    //         .toList(),
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    // 악보 미리보기 영역
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      child: CustomPaint(
                        painter: SheetMusicPainter(notes: recordedNotes),
                        child: Container(),
                      ),
                    ),
                    // 장르 & 악기 선택 영역
                    Card(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 0),
                            Row(
                              children: const [
                                Expanded(child: Divider(thickness: 1.5)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '▼ Select Genre ▼',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),
                                ),
                                Expanded(child: Divider(thickness: 1.5)),
                              ],
                            ),

                            const SizedBox(height: 20),
                            // 장르 선택 이미지 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGenre = "JAZZ";
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedGenre == "JAZZ" ? Color.fromRGBO(159, 79, 70, 1) : Colors.transparent,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/jazz.png',
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGenre = "ROCK";
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedGenre == "ROCK" ? Color.fromRGBO(159, 79, 70, 1) : Colors.transparent,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/Rock.png',
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: const [
                                Expanded(child: Divider(thickness: 1.5)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '▼ Select Instruments ▼',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),
                                ),
                                Expanded(child: Divider(thickness: 1.5)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // 악기 선택 이미지 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: selectedInstruments.keys.map((instrument) {
                                final isSelected = selectedInstruments[instrument]!;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedInstruments[instrument] = !isSelected;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color.fromRGBO(159, 79, 70, 1)
                                              : Colors.transparent,
                                          width: 4,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          'assets/images/${instrument.toLowerCase()}.png',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //악보 처리 및 다운로드
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            List<dynamic> genreParam = [
                              selectedGenre,
                              ...selectedInstruments.entries.map((e) => {e.key: e.value})
                            ];
                            downloadMidiFile(context, recordedNotes, genreParam);
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Generate & Download'
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

