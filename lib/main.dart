import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: IconSelectScreen(),
  ));
}

class IconSelectScreen extends StatefulWidget {
  @override
  _IconSelectScreenState createState() => _IconSelectScreenState();
}

class _IconSelectScreenState extends State<IconSelectScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedEmotion; // 클릭된 감정을 저장

  // 감정 데이터 저장 함수
  Future<void> saveEmotion(String emotion) async {
    try {
      await _firestore.collection('emotions').add({
        'emotion': emotion, // 선택한 감정
        'date': DateTime.now().toIso8601String(), // 저장 시각
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_selectedEmotion 감정이 저장되었습니다!')),
      );
      print('Emotion saved: $emotion');
    } catch (e) {
      print('Error saving emotion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('감정 기록'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  '현재 감정에 맞는 아이콘을 선택하세요',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    EmotionIcon(
                      label: '행복',
                      imagePath: 'assets/images/happy.png',
                      isSelected: _selectedEmotion == '행복',
                      onSelectEmotion: _onEmotionSelected,
                    ),
                    EmotionIcon(
                      label: '놀람',
                      imagePath: 'assets/images/surprised.png',
                      isSelected: _selectedEmotion == '놀람',
                      onSelectEmotion: _onEmotionSelected,
                    ),
                    EmotionIcon(
                      label: '중립',
                      imagePath: 'assets/images/neutral.png',
                      isSelected: _selectedEmotion == '중립',
                      onSelectEmotion: _onEmotionSelected,
                    ),
                    EmotionIcon(
                      label: '두려움',
                      imagePath: 'assets/images/fear.png',
                      isSelected: _selectedEmotion == '두려움',
                      onSelectEmotion: _onEmotionSelected,
                    ),
                    EmotionIcon(
                      label: '분노',
                      imagePath: 'assets/images/angry.png',
                      isSelected: _selectedEmotion == '분노',
                      onSelectEmotion: _onEmotionSelected,
                    ),
                    EmotionIcon(
                      label: '슬픔',
                      imagePath: 'assets/images/sad.png',
                      isSelected: _selectedEmotion == '슬픔',
                      onSelectEmotion: _onEmotionSelected,
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_selectedEmotion != null) {
                saveEmotion(_selectedEmotion!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('감정을 선택해주세요!')),
                );
              }
            },
            child: Text('저장하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 93, 176, 244),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: '감정기록',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart),
                label: '감정분석',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                label: '더보기',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  break;
                case 2:
                  break;
                case 3:
                  break;
              }
            },
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
          ),
        ],
      ),
    );
  }

  // 감정 선택 처리
  void _onEmotionSelected(String emotion) {
    setState(() {
      _selectedEmotion = emotion;
    });
  }
}

class EmotionIcon extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final Function(String) onSelectEmotion;

  const EmotionIcon({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onSelectEmotion,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelectEmotion(label);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, size: 100, color: Colors.red);
              },
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
