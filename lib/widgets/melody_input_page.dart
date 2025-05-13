// lib/widgets/melody_input_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Directory;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
  void startCountdownAndRecording() {
    setState(() {
      countdown = 3;
    });
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          countdown = -1;
        });
        startRecording(); // 카운트다운 종료 후 녹음 시작
      }
    });
  }

  void startRecording() {
    setState(() {
      isRecording = true;
      currentBeat = 0;
      recordedNotes.clear();
      activeNotes.clear();
      recordingStartTime = DateTime.now();
    });

    metronomeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _metronomePlayer.play(AssetSource('sounds/met.mp3')).catchError((error) {
        print("Metronome error: $error");
      });
      setState(() {
        currentBeat++;
      });
      if (currentBeat >= totalBeats) {
        stopRecording();
      }
    });
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
            ),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // 카운트다운 / 녹음 상태 표시 영역
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      countdown > -1
                          ? '시작까지 $countdown초'
                          : isRecording
                              ? 'Recording... Beat ${currentBeat + 1}/$totalBeats'
                              : '녹음을 시작하려면 \'멜로디 작곡\' 버튼을 누르세요',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                          startCountdownAndRecording();
                        }
                      },
                      icon: isRecording
                          ? const Icon(Icons.stop)
                          : const Icon(Icons.fiber_manual_record),
                      label: Text(isRecording ? '멈춤' : '멜로디 작곡'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
                        // 장르 선택
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "장르 선택",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
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
                                        width: 5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.asset(
                                      'assets/images/jazz.png',
                                      width: 80,
                                      height: 80,
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
                                        width: 5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.asset(
                                      'assets/images/Rock.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 악기 선택
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "악기 선택",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: selectedInstruments.keys.map((instrument) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: FilterChip(
                                    label: Text(instrument),
                                    selected: selectedInstruments[instrument]!,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        selectedInstruments[instrument] = selected;
                                      });
                                    },
                                    selectedColor: Color.fromRGBO(159, 79, 70, 1),
                                    checkmarkColor: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
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
                      label: const Text('악보 처리 및 다운로드'),
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
    );
  }
}

