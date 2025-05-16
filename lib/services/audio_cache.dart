import 'dart:html' as html;

final Map<String, html.AudioElement> audioCache = {};

void preloadAllNotes(List<String> notes) {
  for (var note in notes) {
    audioCache[note] = html.AudioElement('sounds/$note.mp3')
      ..preload = 'auto'
      ..load();
  }
}

void playCachedNote(String note) {
  final player = audioCache[note];
  if (player != null) {
    try {
      player.currentTime = 0;
      player.play().then((_) {
        print('재생 성공: $note');
      }).catchError((e) {
        print('오디오 재생 오류: $e');
      });
    } catch (e) {
      print('예외 발생: $e');
    }
  } else {
    print('오디오 없음: $note');
  }
}
