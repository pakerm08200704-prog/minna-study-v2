import 'package:flutter/material.dart';
import 'grammar_detail_page.dart';
import '../utils/score_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<int, int> _highScores = {};

  final List<Map<String, dynamic>> lessons = const [
    {'title': '自我介紹', 'icon': Icons.face},
    {'title': '事物代名詞', 'icon': Icons.category},
    {'title': '場所代名詞', 'icon': Icons.location_on},
    {'title': '時間與星期', 'icon': Icons.access_time},
    {'title': '移動去來回', 'icon': Icons.directions_run},
    {'title': '動作與對象', 'icon': Icons.shopping_cart},
    {'title': '授受關係', 'icon': Icons.card_giftcard},
    {'title': '形容詞介紹', 'icon': Icons.wb_sunny},
    {'title': '好惡與能力', 'icon': Icons.favorite},
    {'title': '存在與位置', 'icon': Icons.home},
    {'title': '數量與期間', 'icon': Icons.exposure_plus_1},
    {'title': '過去式變化', 'icon': Icons.history},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllScores();
  }

  // 讀取分數的函式
  Future<void> _loadAllScores() async {
    Map<int, int> scores = {};
    for (int i = 1; i <= lessons.length; i++) {
      int s = await ScoreManager.getHighScore(i);
      scores[i] = s;
    }
    if (!mounted) return; // 確保元件還在畫面上才更新狀態
    setState(() {
      _highScores = scores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'SoraTalk: 大家的日語',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lessonNum = index + 1;
            final int currentScore = _highScores[lessonNum] ?? 0;
            
            // --- 邏輯判斷：以 10 題為滿分基準 ---
            final bool isFullScore = currentScore >= 10; 
            final bool isPassed = currentScore >= 6;    

            List<Color> gradientColors;
            IconData? statusIcon;
            Color borderColor;

            if (isFullScore) {
              gradientColors = [Colors.orange.shade400, Colors.orange.shade800];
              statusIcon = Icons.workspace_premium;
              borderColor = Colors.yellow.shade200;
            } else if (isPassed) {
              gradientColors = [Colors.green.shade400, Colors.green.shade700];
              statusIcon = Icons.check_circle_outline;
              borderColor = Colors.green.shade200;
            } else {
              final Color baseColor = Colors.indigo.withOpacity(0.8 - (index * 0.03));
              gradientColors = [baseColor, baseColor.withBlue(255)];
              statusIcon = null;
              borderColor = Colors.transparent;
            }

            return InkWell(
              onTap: () async {
                // 1. 使用 await 等待頁面返回
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrammarDetailPage(
                      lessonPath: 'lib/data/lesson_$lessonNum.json',
                    ),
                  ),
                );
                
                // 2. 返回後立刻重新載入分數
                _loadAllScores();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.last.withOpacity(0.4),
                      blurRadius: isFullScore ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isPassed 
                      ? Border.all(color: borderColor, width: 2) 
                      : null,
                ),
                child: Stack(
                  children: [
                    if (statusIcon != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(statusIcon, color: Colors.white, size: 28),
                      ),
                    
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            radius: 28,
                            child: Icon(lessons[index]['icon'], color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '第 $lessonNum 課',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              lessons[index]['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              // 動態顯示最高分與滿分門檻
                              currentScore > 0 ? '最高分: $currentScore/10' : '尚未測驗',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}