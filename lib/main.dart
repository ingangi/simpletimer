import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:platform_info/platform_info.dart';
import 'package:getwidget/getwidget.dart';
import 'tasks.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Config();
  runApp(const SimpleTimer());
  print(Platform.instance.version);
  if (Platform.I.isMacOS || Platform.I.isWindows) {
    print("platform is desktop will resize window");
    doWhenWindowReady(() {
      appWindow.minSize = const Size(400, 200);
      appWindow.size = const Size(800, 600);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class SimpleTimer extends StatelessWidget {
  const SimpleTimer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Timer',
      theme: ThemeData(
          primaryColor: Color.fromARGB(0, 0x24, 0x37, 0x63),
          dialogBackgroundColor: Color.fromARGB(0, 0xFF, 0x6E, 0x31)),
      routes: {
        '/main': (context) => const MainPage(),
      },
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> GetTaskList() {
    return Config()
        .tasks
        .map((e) => GFListTile(
            avatar: GFAvatar(),
            onTap: () {
              print("tapped");
            },
            titleText: e.title,
            subTitleText: e.desc,
            icon: Icon(Icons.favorite)))
        .toList();
  }

  void AddTask() {
    print("Add Task");
    setState(() {
      Config().tasks.add(TimerTask("New Timer", "Not set"));
    });
  }

  @override
  Widget build(BuildContext context) {
    var routerParam = ModalRoute.of(context)?.settings.arguments;
    print("_MainState build with routerParam: ${routerParam}");
    return Scaffold(
      appBar: AppBar(title: const Text('Main')),
      body: Column(children: [
        Column(children: GetTaskList()),
        GFButton(
          onPressed: AddTask,
          text: "Add",
          icon: const Icon(Icons.add),
          type: GFButtonType.outline,
          // textColor: Colors.white,
          // color: Colors.black, //Color(0xFF6E31),
          // color: Color.fromARGB(0, 0xFF, 0x6E, 0x31),
        ),
      ]),
    );
  }
}
