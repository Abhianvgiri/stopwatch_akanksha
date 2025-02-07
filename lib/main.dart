import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Stopwatch',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with SingleTickerProviderStateMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Timer? _blinkTimer;
  bool _isBlinking = false;
  bool _isTextVisible = true;
  bool _isRunning = false;
  final List<String> _laps = [];

  /// 🛠 **Fixed Animation Initialization**
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();

      // Start blinking effect when paused
      _isBlinking = true;
      _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _isTextVisible = !_isTextVisible;
        });
      });

      // Stop animation when paused
      _animationController.reverse();
      _isRunning = false;
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        setState(() {});
      });

      // Stop blinking when running
      _blinkTimer?.cancel();
      _isBlinking = false;
      _isTextVisible = true;

      // Start animation when running
      _animationController.forward();
      _isRunning = true;
    }

    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _laps.clear();
    _blinkTimer?.cancel();
    _isBlinking = false;
    _isTextVisible = true;
    _isRunning = false;
    _animationController.reverse();
    setState(() {});
  }

  void _recordLap() {
    String lapTime = _formatTime(_stopwatch.elapsedMilliseconds);
    _laps.insert(0, lapTime);
    setState(() {});
  }

  String _formatTime(int milliseconds) {
    int centiseconds = (milliseconds ~/ 10) % 100;
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ 60000) % 60;
    int hours = (milliseconds ~/ 3600000);
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}";
  }

  double _getProgress() {
    return (_stopwatch.elapsedMilliseconds % 60000) / 60000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stopwatch",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            ScaleTransition(
              scale: _scaleAnimation,
              child: CircularPercentIndicator(
                radius: 140.0,
                lineWidth: 12.0,
                animation: true,
                animationDuration: 500,
                animateFromLastPercent: true,
                percent: _getProgress(),
                center: Visibility(
                  visible: !_isBlinking || _isTextVisible, // Blinking effect
                  child: Text(
                    _formatTime(_stopwatch.elapsedMilliseconds),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                progressColor: _isRunning ? Colors.green : Colors.blueAccent,
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _customButton(
                    _stopwatch.isRunning ? "Pause" : "Start", _startStopwatch, Colors.blue),
                const SizedBox(width: 20),
                _customButton("Lap", _recordLap, Colors.orange),
                const SizedBox(width: 20),
                _customButton("Reset", _resetStopwatch, Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lap Times",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _laps.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Lap ${_laps.length - index}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _laps[index],
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
