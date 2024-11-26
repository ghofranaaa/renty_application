import 'package:flutter/material.dart';
import 'package:renty/shared/main_scaffold.dart';
import 'package:renty/services/post_services.dart';
import 'package:renty/models/post.dart';
import 'package:renty/features/profile/post_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onPostCreated;
  final bool showSearch;
  const HomeScreen({super.key, required this.onPostCreated, this.showSearch = false});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Post>> posts;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Focus node to control keyboard input

  @override
  void initState() {
    super.initState();
    fetchPosts();

    // Focus on the search bar if `showSearch` is true
    if (widget.showSearch) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _searchFocusNode.requestFocus(); // Open the keyboard
    });
    }
  }

  void fetchPosts() {
    posts = CreatePostService().getPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _searchController.clear();
      fetchPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFf8f2ea),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: AppBar(
              backgroundColor: Color(0xFFf8f2ea),
              elevation: 0,
              flexibleSpace: Stack(
                children: [
                  Positioned(
                    top: 8.0,
                    left: 16.0,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15.0,
                    left: 80.0,
                    child: Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshPosts,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: 20),
                      _buildIntroSection(),
                      SizedBox(height: 20),
                      _buildCategories(),
                      SizedBox(height: 20),
                      _buildOffers(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode, // Attach the focus node
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (query) {
        _searchPosts(query); // Trigger search on input change
      },
    );
  }

  void _searchPosts(String query) {
    if (query.isEmpty) {
      fetchPosts(); // Fetch all posts if query is empty
    } else {
      setState(() {
        posts = CreatePostService().searchPosts(query);
      });
    }
  }

  Widget _buildIntroSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Your Passion!',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 45,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF51abb2),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
              image: AssetImage('assets/home.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final List<Map<String, String>> categories = [
      {'name': 'Guitar', 'image': 'assets/category_1.png'},
      {'name': 'Violin', 'image': 'assets/category_2.png'},
      {'name': 'Piano', 'image': 'assets/category_3.png'},
      {'name': 'Drums', 'image': 'assets/category_4.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () => _fetchPostsByCategory(category['name']!),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(35),
                      image: DecorationImage(
                        image: AssetImage(category['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _fetchPostsByCategory(String category) {
    setState(() {
      posts = CreatePostService().getPostsByCategory(category);
    });
  }


  Widget _buildOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offers',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        FutureBuilder<List<Post>>(
          future: posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No posts found for "${_searchController.text}".'));
            } else {
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data![index];
                  return GestureDetector(
                      onTap: () {
                    // Navigate to the post details page when clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailsScreen(post: post),
                      ),
                    );
                  },
                  child: _buildPostCard(post));
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display post image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                image: (post.image != null && post.image!.isNotEmpty)
                    ? DecorationImage(
                  image: NetworkImage(
                    'http://10.0.2.2:5000/uploads/${post.image}',
                  ),
                  fit: BoxFit.cover,
                )
                    : null,
                color: (post.image == null || post.image!.isEmpty)
                    ? Colors.grey[200]
                    : null,
              ),
              child: (post.image == null || post.image!.isEmpty)
                  ? const Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 50,
                        color: Color(0xFF51abb2),
                      ),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title[0].toUpperCase() + post.title.substring(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,

                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Status: ${post.status}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00712d),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '\$${post.price}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
