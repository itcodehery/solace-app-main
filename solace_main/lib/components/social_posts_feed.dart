import 'package:days_ago/days_ago.dart';
import 'package:flutter/material.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/models/social_post.dart';
import 'package:solace_main/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialPostsFeed extends StatefulWidget {
  const SocialPostsFeed({super.key});

  @override
  _SocialPostsFeedState createState() => _SocialPostsFeedState();
}

class _SocialPostsFeedState extends State<SocialPostsFeed> {
  List<SocialPost> topPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    // Fetch posts from Supabase
    try {
      var allPosts = await supabase.from('social_posts').select();
      List<Map<String, dynamic>> top10Posts = [];

      if (allPosts.isNotEmpty) {
        if (allPosts.length > 10) {
          top10Posts = allPosts.sublist(0, 10);
        } else {
          top10Posts = allPosts;
        }
        setState(() {
          for (var e in top10Posts) {
            topPosts.add(SocialPost.fromJson(e));
          }
        });
      } else {
        return;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: topPosts.length,
          itemBuilder: (context, index) {
            return PostWidgetProper(post: topPosts[index]);
          },
        ),
      ],
    );
  }
}

class PostWidgetProper extends StatefulWidget {
  const PostWidgetProper({
    super.key,
    required this.post,
  });

  final SocialPost post;

  @override
  State<PostWidgetProper> createState() => _PostWidgetProperState();
}

class _PostWidgetProperState extends State<PostWidgetProper> {
  UserModel? userDetail;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
  }

  Future<void> _fetchUserDetail() async {
    try {
      // Fetch user details from Supabase
      final response = await supabase
          .from('user')
          .select()
          .eq('id', widget.post.userId!)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          userDetail = UserModel.fromJson(response);
        });
        _fetchFavoritesStatus();
      } else {
        debugPrint('No user data found');
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error occurred: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchFavoritesStatus() async {
    debugPrint("Getting favorites");
    if (userDetail?.favoritesList != null &&
        userDetail!.favoritesList!.contains(widget.post.id!.toString())) {
      setState(() {
        isFavorite = true;
      });
    } else {
      setState(() {
        isFavorite = false;
      });
    }
  }

  Future<void> addToFavorites() async {
    debugPrint("Adding to favorites");
    try {
      await supabase.from('user').upsert({
        'id': userDetail!.id,
        'favorites_list': "${userDetail!.favoritesList!},${widget.post.id!}",
      });
      setState(() {
        isFavorite = true;
      });
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> removeFromFavorites() async {
    debugPrint("Removing from favorites");
    try {
      await supabase.from('user').upsert({
        'id': userDetail!.id,
        'favorites_list':
            userDetail!.favoritesList!.replaceAll("${widget.post.id!},", ""),
      });
      setState(() {
        isFavorite = false;
      });
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: propaddingdefaulthorizontal,
      child: GestureDetector(
        onTap: () {
          _fetchFavoritesStatus().then((v) => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    color: prodarkGrey,
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: propaddingallexceptbottom,
                              child: Row(
                                children: [
                                  _buildPostTag(widget.post.tags!),
                                  const Spacer(),
                                  Text(
                                    userDetail != null
                                        ? "by u/${userDetail!.username}"
                                        : "Loading...",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: mediumTextFontSize,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ListTile(
                              title: Text(
                                widget.post.title!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: bigTextFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                widget.post.content!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: smallTextFontSize,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (isFavorite) {
                                      await removeFromFavorites();
                                    } else {
                                      await addToFavorites();
                                    }
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ));
        },
        child: Card(
          color: prodarkGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: propaddingdefaultall,
                child: Row(
                  children: [
                    _buildPostTag(widget.post.tags!),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        DaysAgo(widget.post.createdAt!).getString,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: smallTextFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                dense: true,
                title: Text(
                  widget.post.title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: bigTextFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.post.content!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: smallTextFontSize,
                  ),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTag(String tagString) {
    return Container(
      width: 115,
      height: 30,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: FittedBox(
        child: Text(
          tagString,
          style: const TextStyle(
            letterSpacing: -0.2,
            color: proprimaryLighterColor,
            fontSize: smallTextFontSize,
          ),
        ),
      ),
    );
  }
}
