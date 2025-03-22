import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'database/database_helper.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables if using .env file
  try {
    await dotenv.load();
  } catch (e) {
    print('No .env file found or error loading it: $e');
  }
  
  // Initialize database
  await initDatabase();
  
  runApp(const MyApp());
}

Future<void> initDatabase() async {
  try {
    // Get application documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDocDir.path}/databases';
    
    // Create the directory if it doesn't exist
    Directory dbDir = Directory(dbPath);
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    
    // Initialize the database
    final dbHelper = DatabaseHelper();
    await dbHelper.database;
    
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Narrator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key, required this.title});

  final String title;

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final stories = await _databaseHelper.getAllStories();
      setState(() {
        _stories = stories.map((story) => {
          'id': story.id,
          'title': story.title,
          'createdAt': story.createdAt,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No stories yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to create story screen
                        },
                        child: const Text('Create New Story'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_stories[index]['title']),
                      subtitle: Text('Created: ${_stories[index]['createdAt'] ?? 'N/A'}'),
                      onTap: () {
                        // TODO: Navigate to story details screen
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create story screen
        },
        tooltip: 'Create Story',
        child: const Icon(Icons.add),
      ),
    );
  }
}
