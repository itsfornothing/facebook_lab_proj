import 'package:facebook_lab/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:facebook_lab/chat.dart';
import 'package:facebook_lab/create_post.dart';
import 'package:facebook_lab/create_story.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:facebook_lab/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:facebook_lab/live.dart';
import 'package:facebook_lab/market.dart';
import 'package:facebook_lab/notification.dart';
import 'package:facebook_lab/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// A simple splash screen that uses an IconButton to continue to `HomePage`.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.facebook, size: 100, color: Colors.blue[800])],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    HomeFeedScreen(),          // index 0 - Home feed
    const LiveScreen(),              // index 1 - Watch/Live
    const MarketScreen(),            // index 2 - Marketplace
    const NotificationScreen(),      // index 3 - Notifications
    const ProfileScreen(),           // index 4 - Profile (you can create this later)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We hide the app bar for most tabs — or you can make it conditional
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/music-bot.png'),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

// Extracted Home Feed into its own widget (the previous body content)
class HomeFeedScreen extends StatelessWidget {
  HomeFeedScreen({super.key});

  final List<Map<String, dynamic>> fakePosts = [
    {
      'user': 'Abebe Kebede',
      'avatar': 'assets/music-bot.png',
      'time': '2h',
      'text': 'Beautiful sunset in Addis today 🌅 Who else enjoyed it?',
      'image': 'assets/sunset.jpeg',
      'likes': '1.2K',
      'comments': '342',
      'shares': '89',
    },
    // ... other posts ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {},
          child: const Text(
            'facebook',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 3, 71, 126),
              fontSize: 28,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Quick actions row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/music-bot.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "What's on your mind?",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.green),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PostScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Stories row...
            SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // Create story card...
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StoryScreen()),
                    ),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[300],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Create\nStory",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Fake stories...
                  for (int i = 0; i < 5; i++)
                    Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/music-bot.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 12, thickness: 10, color: Colors.grey),

            // Posts
            ...fakePosts.map((post) => PostCard(post: post)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(post['avatar'])),
            title: Text(post['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(post['time']),
            trailing: const Icon(Icons.more_horiz),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(post['text']),
          ),
          if (post['image'] != null)
            Image.asset(post['image'], width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(post['likes']),
                    const SizedBox(width: 4),
                    const Text('·'),
                    const SizedBox(width: 4),
                    Text(post['comments']),
                  ],
                ),
                Text(post['shares']),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('Like')),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.comment_outlined), label: const Text('Comment')),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: const Text('Share')),
            ],
          ),
        ],
      ),
    );
  }
}