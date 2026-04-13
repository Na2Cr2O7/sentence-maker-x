import 'package:flutter/material.dart';
import 'package:sentence_maker_x/src/rust/api/simple.dart';
import 'package:sentence_maker_x/src/rust/frb_generated.dart';
import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}

// 顶级函数（虽然当前未用 compute，但保留结构）
String _genSentenceInIsolate(String input) {
  return genSentence(name: input.replaceAll("，", ","));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '造句助手',
      
      // 启用深色模式：根据系统自动切换
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        // 可选：自定义深色下的文本/卡片颜色
        cardColor: Colors.grey[850],
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        // ),
      ),
      // 自动跟随系统主题
      themeMode: ThemeMode.system, // 可改为 ThemeMode.dark / ThemeMode.light 测试
      home: const SentenceMakerScreen(),
    );
  }
}

class SentenceMakerScreen extends StatefulWidget {
  const SentenceMakerScreen({super.key});

  @override
  State<SentenceMakerScreen> createState() => _SentenceMakerScreenState();
}

class _SentenceMakerScreenState extends State<SentenceMakerScreen> {
  final textController = TextEditingController();
  String result = "";
  bool isLoading = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _generateSentence() async {
    final input = textController.text.trim();
    if (input.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入词语")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      result = "";
    });

    final sentence = await Future.sync(() {
      return genSentence(name: input.replaceAll("，", ","));
    });

    if (!mounted) return;

    setState(() {
      result = sentence.isEmpty ? "未能生成句子，请换词重试。" : sentence;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题亮度，用于微调（可选）
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('造句助手'),
        centerTitle: true,
        // 可选：深色模式下 AppBar 更暗
        backgroundColor: isDark ? Colors.black87 : null,
        leading: Center(child:  IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed:  () {
            final textController = TextEditingController();
            textController.text="https://www.modelscope.cn/datasets/modelscope/chinese-poetry-collection/files";
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(

                title: const Text("关于"),
                content: const Text("造句助手\n数据集:"),
                actions: <Widget>[
                  TextField(controller: textController),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      // color: Colors.green,
                      padding: const EdgeInsets.all(14),
                      child: const Text("完成"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),),
      ),
      body: SingleChildScrollView(
        child: Center( // 👈 整体居中关键
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500), // 防止在大屏上过宽
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                children: [
                  const Text(
                    '请输入词语（用中文或英文逗号分隔）',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: '例如：苹果，吃，今天',
                        labelText: '词语列表',
                        alignLabelWithHint: true,
                      ),
                      maxLines: null,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generateSentence,
                      icon: const Icon(Icons.auto_stories_outlined),
                      label: const Text('生成句子'),
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (result.isNotEmpty)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                result,
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () async {
                                if (!mounted) return;
                                await Clipboard.setData(ClipboardData(text: result));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("已复制到剪贴板")),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}