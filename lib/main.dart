import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('My App');
    setWindowMaxSize(const Size(1920, 1080));
    setWindowMinSize(const Size(1280, 720));
  }

  setupWindow();
  runApp(
    // Provide the model to all widgets within the app. We're using
    // ChangeNotifierProvider because that's a simple way to rebuild
    // widgets when a model changes. We could also just use
    // Provider, but then we would have to listen to Counter ourselves.
    //
    // Read Provider's docs to learn about all the available providers.
    ChangeNotifierProvider(
      // Initialize the model in the builder. That way, Provider
      // can own Counter's lifecycle, making sure to call `dispose`
      // when not needed anymore.
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 720;
const double windowHeight = 1060;
void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}

/// Simplest possible model, with just one field.
///
/// [ChangeNotifier] is a class in `flutter:foundation`. [Counter] does
/// _not_ depend on Provider.
class Counter with ChangeNotifier {
  int value = 0;

  void setAge(int newAge) {
    value = newAge;
    notifyListeners();
  }

  String get milestone {
    if (value <= 12) {
      return "You are a child";
    } else if (value <= 19) {
      return "Teenager Time";
    } else if (value <= 30) {
      return "You are a young adult";
    } else if (value <= 50) {
      return "You are an adult";
    } else {
      return "Golden Years!";
    }
  }

  Color get backgroundColor {
    if (value <= 12) {
      return Colors.lightBlue;
    } else if (value <= 19) {
      return Colors.lightGreen;
    } else if (value <= 30) {
      return Colors.yellow;
    } else if (value <= 50) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Color get progressionBarColor {
    if (value <= 33) {
      return Colors.green;
    } else if (value <= 67) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  double get progressValue {
    return value / 99;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    var counter = context.watch<Counter>();
    return Scaffold(
      appBar: AppBar(title: const Text('Age counter')),
      body: Center(
        child: Container(
          color: counter.backgroundColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(counter.milestone),
                // Consumer looks for an ancestor Provider widget
                // and retrieves its model (Counter, in this case).
                // Then it uses that model to build widgets, and will trigger
                // rebuilds if the model is updated.
                Consumer<Counter>(
                  builder:
                      (context, counter, child) => Text(
                        '${counter.value}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                ),
                Slider(
                  value: counter.value.toDouble(),
                  min: 0,
                  max: 99,
                  divisions: 99,
                  label: '${counter.value}',
                  onChanged: (newValue) {
                    counter.setAge(newValue.toInt());
                  },
                ),
                LinearProgressIndicator(
                  value: counter.progressValue,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    counter.progressionBarColor,
                  ),
                  minHeight: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
