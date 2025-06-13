import 'package:flutter/material.dart';
import 'package:pwsi/model/paginated_page.dart';
import 'package:pwsi/model/review.dart';
import 'package:pwsi/model/user.dart';
import 'package:pwsi/service/review_service.dart';
import 'package:pwsi/service/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  final bool isMyProfile;

  const UserProfileScreen({super.key, required this.user, this.isMyProfile = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  PaginatedPage<Review>? _reviewPage;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({String? pageUrl}) async {
    setState(() => _isLoadingReviews = true);
    final page = await ReviewService.getUserReviews(widget.user.id, pageUrl: pageUrl);
    setState(() {
      _reviewPage = page;
      _isLoadingReviews = false;
    });
  }

  void _showEditProfileDialog() {
    final bioController = TextEditingController(text: widget.user.bio ?? '');
    final pictureController = TextEditingController(text: widget.user.profileUrl);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edytuj profil'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: pictureController,
                decoration: const InputDecoration(labelText: 'URL zdjęcia profilowego'),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Opis (bio)'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nowe hasło'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Zapisz'),
            onPressed: () async {
              final newBio = bioController.text;
              final newPicture = pictureController.text;
              final newPassword = passwordController.text;

              final results = await Future.wait([
                if (newBio != widget.user.bio)
                  UserService.updateBio(newBio)
                else
                  Future.value(true),
                if (newPicture != widget.user.profileUrl)
                  Future.value(true)//UserService.updateProfilePicture(newPicture)
                else
                  Future.value(true),
                if (newPassword.isNotEmpty)
                  Future.value(true)//UserService.updatePassword(newPassword)
                else
                  Future.value(true),
              ]);

              final success = results.every((r) => r);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil zaktualizowany')),
                );
                setState(() {
                  widget.user.bio = newBio;
                  widget.user.profileUrl = newPicture;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nie udało się zaktualizować profilu')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isMyProfile ? 'Mój profil' : 'Profil użytkownika'),
        actions: [
          if (widget.isMyProfile)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edytuj profil',
              onPressed: _showEditProfileDialog,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.profileUrl),
              radius: 30,
            ),
            title: Text(user.username),
            subtitle: Text(user.bio ?? 'Brak opisu'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Recenzje:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: _isLoadingReviews
                ? const Center(child: CircularProgressIndicator())
                : _reviewPage == null || _reviewPage!.items.isEmpty
                ? const Center(child: Text('Brak recenzji.'))
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _reviewPage!.items.length,
                    itemBuilder: (context, index) {
                      final review = _reviewPage!.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(review.content),
                          subtitle: Text(
                            '${review.sentiment.toUpperCase()} • ${review.createdAt.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_reviewPage!.previousUrl != null)
                        ElevatedButton(
                          onPressed: () => _loadReviews(pageUrl: _reviewPage!.previousUrl),
                          child: const Text('Poprzednia strona'),
                        )
                      else
                        const SizedBox(),
                      if (_reviewPage!.nextUrl != null)
                        ElevatedButton(
                          onPressed: () => _loadReviews(pageUrl: _reviewPage!.nextUrl),
                          child: const Text('Następna strona'),
                        )
                      else
                        const SizedBox(),
                    ],
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
