import 'package:flutter/material.dart';
import 'package:pwsi/model/book.dart';
import 'package:pwsi/model/paginated_page.dart';
import 'package:pwsi/service/book_service.dart';
import 'package:pwsi/widgets/book_detail.dart';
import 'package:pwsi/widgets/user_profile.dart';

import '../model/user.dart';
import '../service/user_service.dart';

class BookListScreen extends StatefulWidget {
  final bool showRecommendations;

  const BookListScreen({super.key, this.showRecommendations = false});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  PaginatedPage<Book>? _page;
  bool _isLoading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    loadUserAndPage();
  }

  Future<void> loadUserAndPage({String? url}) async {
    await loadUser();
    setState(() => _isLoading = true);
    PaginatedPage<Book>? page;
    page =
        widget.showRecommendations
            ? await BookService.getRecommendationsForUser(_user!)
            : await BookService.getBookList(pageUrl: url);
    setState(() {
      _page = page;
      _isLoading = false;
    });
  }

  Future<void> loadUser() async {
    final fetchedUser = await UserService.getCurrentUser();
    setState(() {
      _user = fetchedUser;
    });
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.showRecommendations ? 'Twoje rekomendacje' : 'Lista książek'),
      actions: [
        if (_user != null && !widget.showRecommendations)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => UserProfileScreen(user: _user!, isMyProfile: true),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(_user!.profileUrl),
                radius: 18,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _page == null || _page!.items.isEmpty
              ? const Center(child: Text('Brak książek do wyświetlenia.'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _page!.items.length,
                      itemBuilder: (context, index) {
                        final book = _page!.items[index];
                        return ListTile(
                          leading: Image.network(
                            book.imageUrl,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                          title: Text(book.title),
                          subtitle: Text(
                            '${book.author.name}    Ocena: ${book.avgRating}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(book: book),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_page!.previousUrl != null)
                          ElevatedButton(
                            onPressed: () => loadUserAndPage(url: _page!.previousUrl),
                            child: const Text('Poprzednia strona'),
                          )
                        else
                          const SizedBox(),
                        if (_page!.nextUrl != null)
                          ElevatedButton(
                            onPressed: () => loadUserAndPage(url: _page!.nextUrl),
                            child: const Text('Następna strona'),
                          )
                        else
                          const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
