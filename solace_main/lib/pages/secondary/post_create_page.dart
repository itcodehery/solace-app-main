import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/models/social_post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toast/toast.dart';

// enum PostTags { mentalHealth, wellbeing, lifeTips, motivation }

class PostCreatePage extends StatefulWidget {
  const PostCreatePage({super.key});

  @override
  _PostCreatePageState createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final List<String> postTags = [
    "Mental Health",
    "Wellbeing",
    "Life Tips",
    "Motivation",
    "Guide",
    "Question",
    "Discussion",
  ];
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ProfanityFilter filter = ProfanityFilter();
  String selectedTag = "Mental Health";
  bool isPostingAnonymously = false;

  Future<void> _uploadPost() async {
    // Upload post to Supabase
    SocialPost? postToUpload;
    debugPrint("in upload!");
    try {
      final userDetails = await supabase
          .from('user')
          .select()
          .eq('email', supabase.auth.currentUser!.email!)
          .single();
      debugPrint("fetched user details");
      postToUpload = SocialPost(
        userId: isPostingAnonymously
            ? "12624b0e-7e80-454c-a024-2e99640615c7"
            : userDetails["id"],
        createdAt: DateTime.now(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: selectedTag,
      );
      debugPrint("initialized post");
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
    try {
      await supabase
          .from('social_posts')
          .insert(postToUpload!.toJson())
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Post uploaded successfully"),
                ),
              ));
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
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "What's on your mind?",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 12.0,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.white54),
                    hintText: "Post Title",
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: proprimaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    errorStyle: TextStyle(color: Colors.red.shade300),
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 60,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    }

                    if (filter.hasProfanity(value)) {
                      return "Please enter a valid title (no profanity)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.white54),
                    hintText: "Post Content",
                    hintMaxLines: 8,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: proprimaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    errorStyle: TextStyle(color: Colors.red.shade300),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 10,
                  maxLength: 400,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    }
                    if (filter.hasProfanity(value)) {
                      return "Please enter a valid content (no profanity)";
                    }
                    return null;
                  },
                ),
                // const ListTile(
                //   title: Text(
                //     "Tags",
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
                const SizedBox(height: 8.0),
                Wrap(
                  children: [
                    //chips
                    for (var tag in postTags)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          backgroundColor: prodarkGrey,
                          label: Text(
                            tag,
                            style: TextStyle(
                                color: selectedTag == tag
                                    ? prodarkGrey
                                    : Colors.white70),
                          ),
                          selected: selectedTag == tag,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                selectedTag = tag;
                              } else {
                                selectedTag = "";
                              }
                            });
                          },
                          selectedColor: proprimaryColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8.0),
                CheckboxListTile(
                  checkColor: Colors.black,
                  activeColor: proprimaryColor,
                  value: isPostingAnonymously,
                  onChanged: (v) {
                    //show toast

                    setState(() {
                      isPostingAnonymously = v!;
                    });
                    if (isPostingAnonymously) {
                      Toast.show(
                        backgroundColor: prodarkGrey,
                        "Posting anonymously!",
                        duration: 3,
                        gravity: 0,
                      );
                    }
                  },
                  title: const Text(
                    "Post Anonymously",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Your username will not be displayed in the post",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: proprimaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            showDialog(
              context: context,
              builder: (context) {
                //are you sure?
                return AlertDialog(
                  backgroundColor: prodarkGrey,
                  title: const Text("Are you sure?",
                      style: TextStyle(color: Colors.white)),
                  content: const Text("Do you want to post this?",
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        _uploadPost().then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Post uploaded successfully"),
                            ),
                          );
                        });
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                );
              },
            );
          }
        },
        label: const Text("Post"),
        icon: const Icon(Icons.post_add),
      ),
    );
  }
}
