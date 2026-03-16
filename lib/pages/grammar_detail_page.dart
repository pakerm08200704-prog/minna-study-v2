import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'quiz_page.dart';
import '../widgets/vocabulary_list_widget.dart'; // 確保路徑正確

class GrammarDetailPage extends StatefulWidget {
  final String lessonPath;
  const GrammarDetailPage({super.key, required this.lessonPath});

  @override
  State<GrammarDetailPage> createState() => _GrammarDetailPageState();
}

class _GrammarDetailPageState extends State<GrammarDetailPage> {
  Map<String, dynamic>? _fullData;

  Future<Map<String, dynamic>> loadData() async {
    if (_fullData != null) return _fullData!;

    String response;
    try {
      response = await rootBundle.loadString(widget.lessonPath);
    } catch (e) {
      response = await rootBundle.loadString('assets/${widget.lessonPath}');
    }

    _fullData = json.decode(response);
    return _fullData!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final int lessonNumber = data['lessonNumber'] ?? 0;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(data['title'] ?? '第 $lessonNumber 課'),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              // --- 修改 TabBar 樣式 ---
              bottom: TabBar(
                indicatorColor: Colors.orange,
                indicatorWeight: 4,         // 增加底部指示線厚度
                labelColor: Colors.white,    // 選中時文字顏色反白
                unselectedLabelColor: Colors.white.withOpacity(0.6), // 未選中時稍微透明
                labelStyle: const TextStyle(
                  fontSize: 18,              // 放大選中文字
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,              // 未選中文字大小
                ),
                // 滑鼠移動過去時的效果 (Overlay)
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.white.withOpacity(0.15); // 懸停時淡淡白光效果
                    }
                    return null;
                  },
                ),
                tabs: const [
                  Tab(
                    text: '單字', 
                    icon: Icon(Icons.translate, size: 28), // 放大圖示
                  ),
                  Tab(
                    text: '文法', 
                    icon: Icon(Icons.book, size: 28), 
                  ),
                  Tab(
                    text: '測驗', 
                    icon: Icon(Icons.edit_note, size: 32), // 測驗圖示稍大增加重點感
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                VocabularyListWidget(lessonNumber: lessonNumber),
                _buildGrammarList(data),
                _buildQuizEntry(data),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrammarList(Map<String, dynamic> data) {
    final grammarPoints = data['grammarPoints'] as List;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: grammarPoints.length,
      itemBuilder: (context, index) {
        final point = grammarPoints[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  point['explanation'],
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const Divider(height: 30),
                ...(point['examples'] as List).map((ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex['jp'],
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ex['kana'],
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex['zh'],
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey[800]),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizEntry(Map<String, dynamic> data) {
    if (data['quiz'] == null) {
      return const Center(child: Text('本課暫無測驗資料'));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.edit_note, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text('準備好開始測驗了嗎？', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    quizData: data['quiz'],
                    lessonNumber: data['lessonNumber'],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('開始測驗', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}