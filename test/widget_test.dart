import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 這裡確保 import 了你的 main.dart
import 'package:minna_study/main.dart'; 

void main() {
  testWidgets('App 啟動與介面載入測試', (WidgetTester tester) async {
    // 修正點：const 後面必須有空格，且類別名稱需完全符合 SoraTalkApp
    await tester.pumpWidget(const SoraTalkApp());

    // 驗證畫面上是否有出現「第」這個字（對應第 1 課、第 2 課等列表文字）
    // 使用 textContaining 來增加容錯率
    expect(find.textContaining('第'), findsWidgets);

    // 驗證是否有一個列表元件 (ListView)
    expect(find.byType(ListView), findsOneWidget);
  });
}