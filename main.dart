import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const TimeTrackerApp());
}

class Activity {
  String name;
  bool isTiming;
  Stopwatch stopwatch;
  Timer? timer;

  Activity(this.name) : isTiming = false, stopwatch = Stopwatch();

  void reset() {
    stopwatch.reset();
  }
}

class TimeTrackerApp extends StatelessWidget {
  const TimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Time Tracker',
      debugShowCheckedModeBanner: false,
      home: const TimeTrackerPage(),
    );
  }
}

class TimeTrackerPage extends StatefulWidget {
  const TimeTrackerPage({super.key});

  @override
  State<TimeTrackerPage> createState() => _TimeTrackerPageState();
}

class _TimeTrackerPageState extends State<TimeTrackerPage> {
  final List<Activity> activities = [];
  final TextEditingController _activityController = TextEditingController();

  void _addActivity() {
    String newName = _activityController.text.trim();
    if (newName.isNotEmpty && activities.every((a) => a.name != newName)) {
      setState(() {
        activities.add(Activity(newName));
        _activityController.clear();
      });
    }
  }

  void _toggleTiming(Activity activity) {
    setState(() {
      if (!activity.isTiming) {
        activity.stopwatch.start();
        activity.isTiming = true;
        activity.timer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {});
        });
      } else {
        activity.stopwatch.stop();
        activity.isTiming = false;
        activity.timer?.cancel();
      }
    });
  }

  void _deleteActivity(Activity activity) {
    setState(() {
      activity.timer?.cancel();
      activities.remove(activity);
    });
  }

  void _resetActivity(Activity activity) {
    setState(() {
      activity.stopwatch.reset();
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return '${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  void dispose() {
    for (var act in activities) {
      act.timer?.cancel();
    }
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Time Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackedTasksPage(activities: activities),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add new activity
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _activityController,
                    decoration: const InputDecoration(
                      labelText: 'Enter activity name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addActivity(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addActivity,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Main List
            Expanded(
              child: activities.isEmpty
                  ? const Center(
                      child: Text(
                        'Add an activity to begin tracking your time!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final act = activities[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(act.name),
                            subtitle: Text(
                              'Time: ${_formatDuration(act.stopwatch.elapsed)}',
                              style: TextStyle(
                                color: act.isTiming
                                    ? Colors.green
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _toggleTiming(act),
                                  icon: Icon(
                                    act.isTiming
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                  ),
                                  label: Text(act.isTiming ? 'Stop' : 'Start'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: act.isTiming
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () => _resetActivity(act),
                                  tooltip: 'Reset Timer',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => _deleteActivity(act),
                                  tooltip: 'Delete Task',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Second Page to show tracked tasks
class TrackedTasksPage extends StatelessWidget {
  final List<Activity> activities;

  const TrackedTasksPage({super.key, required this.activities});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return '${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracked Tasks")),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final act = activities[index];
          return ListTile(
            title: Text(act.name),
            subtitle: Text(
              "Final Time: ${_formatDuration(act.stopwatch.elapsed)}",
            ),
          );
        },
      ),
    );
  }
}
