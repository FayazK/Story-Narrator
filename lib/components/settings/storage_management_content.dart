import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class StorageManagementContent extends StatelessWidget {
  const StorageManagementContent({super.key});

  Future<void> _openDatabaseDirectory(BuildContext context) async {
    try {
      Directory documentsDirectory = await getApplicationSupportDirectory();
      String dbPath = join(documentsDirectory.path, 'databases');
      final Uri uri = Uri.parse('file://$dbPath');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Handle the case where the directory cannot be opened
        debugPrint('Could not launch $uri');
        // TODO: Show a more user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open directory: $dbPath'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening database directory: $e');
      // TODO: Show a more user-friendly error message
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening directory: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage Management',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text('Database Details:'),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _getDatabasePath(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading database path: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final dbPath = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Database Name: story_narrator.db'),
                    const SizedBox(height: 4),
                    Text('Storage Location: $dbPath'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _openDatabaseDirectory(context),
                      child: const Text('Open Database Directory'),
                    ),
                  ],
                );
              } else {
                return const Text('Database path not available.');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String> _getDatabasePath() async {
    Directory documentsDirectory = await getApplicationSupportDirectory();
    return join(documentsDirectory.path, 'databases');
  }
}
