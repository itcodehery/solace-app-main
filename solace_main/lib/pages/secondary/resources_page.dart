import 'package:flutter/material.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/models/resource_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<ResourceModel> resources = [];

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    try {
      final response = await supabase.from('resources').select();
      final List<ResourceModel> fetchedResources = [];
      for (final resource in response) {
        fetchedResources.add(ResourceModel.fromJson(resource));
      }
      setState(() {
        resources = fetchedResources;
      });
    } catch (error) {
      debugPrint('Error fetching resources: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Resources',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: resources.isNotEmpty
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        gradient: defaultGradient,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12))),
                    child: ListTile(
                      leading: const Icon(
                        Icons.link,
                        color: prodarkGrey,
                      ),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${resources.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(" resources found!"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: resources.length,
                      itemBuilder: (context, index) {
                        final resource = resources[index];
                        return Container(
                          margin: propaddingallexceptbottom,
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(
                                    color: Colors.white12, width: 0.4)),
                          ),
                          child: ListTile(
                            title: Text(
                              resource.resourceName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: mediumTextFontSize,
                              ),
                            ),
                            subtitle: Text(
                              resource.resourceDescription,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: smallTextFontSize,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.link,
                              color: Colors.white70,
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.black,
                                      title: Text(
                                        resource.resourceName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      content: Text(
                                        resource.resourceDescription,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: mediumTextFontSize,
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundBuilder:
                                                    (context, states, child) {
                                                  return Container(
                                                    width: double.infinity,
                                                    decoration:
                                                        const BoxDecoration(
                                                      gradient: defaultGradient,
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                shape: const WidgetStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    6))))),
                                            onPressed: () async {
                                              final Uri url = Uri.parse(
                                                  resource.resourceUrl);
                                              if (!await launchUrl(url)) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Could not launch the URL'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: FittedBox(
                                              child: Text(
                                                resource.resourceUrl,
                                                style: const TextStyle(
                                                  fontSize: mediumTextFontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: prodarkGrey,
                                                ),
                                              ),
                                            )),
                                      ],
                                    );
                                  });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: proprimaryColor,
              ),
            ),
    );
  }
}
