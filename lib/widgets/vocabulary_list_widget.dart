import 'package:flutter/material.dart';
import 'dart:js' as js;
import '../data/vocabulary_data.dart';

class VocabularyListWidget extends StatelessWidget {
  final int lessonNumber;
  const VocabularyListWidget({super.key, required this.lessonNumber});

  // 優化後的 Web Speech API 呼叫邏輯
  void _speak(String text) {
    if (text.isEmpty) return;

    js.context.callMethod('eval', [
      """
      (function() {
        // 先取消正在播放的語音
        window.speechSynthesis.cancel();
        
        var msg = new SpeechSynthesisUtterance();
        msg.text = '$text';
        msg.lang = 'ja-JP';
        msg.rate = 0.9;  // 語速調整，0.9 較為自然
        msg.pitch = 1.0; // 音調

        // 核心優化：獲取所有可用語音清單
        var voices = window.speechSynthesis.getVoices();
        
        // 優先順序：1. Google 日本語 (Chrome 內建) 2. 任何日文語音
        var selectedVoice = voices.find(function(v) {
          return v.name.includes('Google') && v.lang.includes('ja');
        }) || voices.find(function(v) {
          return v.lang.includes('ja');
        });

        if (selectedVoice) {
          msg.voice = selectedVoice;
        }

        window.speechSynthesis.speak(msg);
      })();
      """
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final List<Vocabulary>? vocabs = allVocabulary[lessonNumber];

    if (vocabs == null || vocabs.isEmpty) {
      return const Center(child: Text('目前沒有單字資料'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vocabs.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
      itemBuilder: (context, index) {
        final item = vocabs[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          title: Text(
            item.kanji.isNotEmpty ? item.kanji : item.kana,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.kanji.isNotEmpty) Text(item.kana, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(item.mean, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () => _speak(item.kana),
          ),
          onTap: () => _speak(item.kana),
        );
      },
    );
  }
}