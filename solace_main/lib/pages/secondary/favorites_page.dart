import 'package:flutter/material.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/models/social_post.dart';
import 'package:solace_main/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  UserModel? currentUser;
  List<SocialPost>? favoritePosts;

  @override
  void initState() {
    _fetchUserDetailsForFavorite().then((v) {
      _fetchFavoritePostList();
    });
    super.initState();
  }

  Future<void> _fetchUserDetailsForFavorite() async {
    debugPrint("fetching user details");
    try {
      var userdetail = await supabase
          .from('user')
          .select()
          .eq('email', supabase.auth.currentUser!.email!)
          .single();
      if (userdetail.isNotEmpty) {
        currentUser = UserModel.fromJson(userdetail);
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchFavoritePostList() async {
    debugPrint("Fetching favorite posts");

    // Ensure that currentUser and favoritesList are not null
    if (currentUser == null || currentUser!.favoritesList == null) {
      debugPrint("No current user or favorites list available");
      return;
    }

    List<String> favoritePostIds =
        currentUser!.favoritesList!.split(",").sublist(1);
    debugPrint(favoritePostIds.length.toString());
    List<SocialPost> testfavoritePosts = [];

    try {
      for (var postId in favoritePostIds) {
        final response =
            await supabase.from('social_posts').select().eq('id', postId);
        if (response.isEmpty) {
          continue;
        }
        for (var post in response) {
          testfavoritePosts.add(SocialPost.fromJson(post));
        }
      }
      setState(() {
        favoritePosts = testfavoritePosts;
      });
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            duration: const Duration(seconds: 10),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error occurred: $e'),
            duration: const Duration(seconds: 10),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favoritePosts == null
          ? const Center(
              child: CircularProgressIndicator(
                color: proprimaryColor,
              ),
            )
          : favoritePosts!.isEmpty
              ? const Center(
                  child: Text("No favorite posts yet!",
                      style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  itemCount: favoritePosts!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(favoritePosts![index].title!,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        favoritePosts![index].content!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
    );
  }
}
