import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:facebook_lab/firebase_options.dart';

// Uncomment these as you create the actual files
import 'package:facebook_lab/chat.dart';
import 'package:facebook_lab/create_post.dart';
import 'package:facebook_lab/create_story.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// ───────────────────────────────────────────────
// Splash Screen
// ───────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Icon(Icons.facebook, size: 100, color: Colors.blue[800]),
      ),
    );
  }
}

// ───────────────────────────────────────────────
// Data Models
// ───────────────────────────────────────────────
class Post {
  final String user;
  final String avatar;
  final String time;
  final String text;
  final String? image;

  int likesCount;
  bool isLikedByMe;
  final List<Comment> comments;

  Post({
    required this.user,
    required this.avatar,
    required this.time,
    required this.text,
    this.image,
    this.likesCount = 1200,
    this.isLikedByMe = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];
}

class Comment {
  final String user;
  final String avatar;
  final String text;
  final String time;

  Comment({
    required this.user,
    required this.avatar,
    required this.text,
    required this.time,
  });
}

// ───────────────────────────────────────────────
// Main Home Page with Bottom Navigation
// ───────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeFeedScreen(),
    const LiveScreen(),
    const MarketScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────
// Home Feed Screen (Main Content)
// ───────────────────────────────────────────────
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late List<Post> posts;

  @override
  void initState() {
    super.initState();
    posts = [
      Post(
        user: "Abebe Kebede",
        avatar: "assets/music-bot.png",
        time: "2h",
        text: "Beautiful sunset in Addis today 🌅 Who else enjoyed it?",
        image: "assets/sunset.jpeg",
        likesCount: 1240,
        comments: [
          Comment(user: "Sara Alemu", avatar: "assets/music-bot.png", text: "Wow, very beautiful! Where was this?", time: "1h"),
          Comment(user: "Yonas T.", avatar: "assets/music-bot.png", text: "Ethiopia never disappoints ❤️", time: "45m"),
        ],
      ),
      Post(
        user: "Meron Desta",
        avatar: "assets/music-bot.png",
        time: "5h",
        text: "Just tried the new buna place in Bole! 10/10 recommend ☕",
        likesCount: 890,
      ),
    ];
  }

  void toggleLike(int index) {
    setState(() {
      final post = posts[index];
      post.isLikedByMe = !post.isLikedByMe;
      post.likesCount += post.isLikedByMe ? 1 : -1;
    });
  }

  void addComment(int postIndex, String commentText) {
    if (commentText.trim().isEmpty) return;

    setState(() {
      final newComment = Comment(
        user: "You",
        avatar: "assets/music-bot.png",
        text: commentText.trim(),
        time: "Just now",
      );
      posts[postIndex].comments.add(newComment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "facebook",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.blue[900],
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Quick create post area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PostScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.green),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PostScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              // Stories
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // Create story button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StoryScreen()),
                      ),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: Colors.blue, size: 32),
                            ),
                            const SizedBox(height: 8),
                            const Text("Create\nStory", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    // Fake stories
                    ...List.generate(6, (i) => Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/music-bot.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              const Divider(height: 12, thickness: 10, color: Color(0xFFe4e6eb)),

              // Posts feed
              ...List.generate(
                posts.length,
                (index) => PostCard(
                  post: posts[index],
                  onLike: () => toggleLike(index),
                  onComment: (text) => addComment(index, text),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────
// Post Card Widget
// ───────────────────────────────────────────────
class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final Function(String) onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final p = widget.post;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(p.avatar)),
            title: Text(p.user, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(p.time),
            trailing: const Icon(Icons.more_horiz),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(p.text),
          ),
          if (p.image != null)
            Image.asset(p.image!, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${p.likesCount}",
                      style: TextStyle(color: p.isLikedByMe ? Colors.blue[700] : null),
                    ),
                    const SizedBox(width: 8),
                    Text("${p.comments.length} comments"),
                  ],
                ),
                const Text("42 shares"),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: widget.onLike,
                icon: Icon(
                  p.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: p.isLikedByMe ? Colors.blue[700] : null,
                ),
                label: Text(
                  "Like",
                  style: TextStyle(color: p.isLikedByMe ? Colors.blue[700] : null),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.comment_outlined),
                label: const Text("Comment"),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
                label: const Text("Share"),
              ),
            ],
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    widget.onComment(_commentController.text);
                    _commentController.clear();
                  },
                ),
              ],
            ),
          ),
          if (p.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: p.comments.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(c.avatar),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.user, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(c.text),
                                const SizedBox(height: 4),
                                Text(
                                  c.time,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}