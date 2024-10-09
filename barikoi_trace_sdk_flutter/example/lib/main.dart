import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  BarikoiTraceSdkFlutter(apiKey: 'YOUR_API_KEY');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BarikoiTraceSdkFlutter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!context.mounted) return;
                try {
                  final user = await BarikoiTraceSdkFlutter.instance
                      .setOrCreateUser(name: "test", phone: "01676529696");

                  print(user.user.id);
                  userid = user.user.id;
                  setState(() {});
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Set or Create User'),
            ),
            Text('User Id: $userid'),
            const Divider(),
            ElevatedButton(
              onPressed: () async {
                if (!context.mounted) return;
                try {
                  await BarikoiTraceSdkFlutter.instance
                      .startTracking(userId: userid ?? '');
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Start Tracking'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!context.mounted) return;
                try {
                  await BarikoiTraceSdkFlutter.instance.stopTracking();
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Stop Tracking'),
            ),
            const Divider()
          ],
        ),
      ),
    );
  }
}
