import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pwsi/model/paginated_page.dart';

import '../model/author.dart';
import '../model/book.dart';
import '../model/review.dart';
import '../model/user.dart';
import '../provider/auth_provider.dart';
import '../service/review_service.dart';
import '../widgets/user_profile.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Future<PaginatedPage<Review>?> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewService.getReviewsForBook(widget.book.id);
  }

  void _showAuthorDialog(Author author) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(author.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Narodowość: ${author.nationality}'),
            const SizedBox(height: 8),
            if (author.birthDate != null)
              Text('Data urodzenia: ${author.birthDate!.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 8),
            Text('Opis:\n${author.description}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Zamknij'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfileScreen(user: user)),
    );
  }

  Widget _buildReviewCard(Review review, {bool isOwnReview = false}) {
    return Card(
      color: isOwnReview ? Colors.blue.shade50 : null,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _navigateToUserProfile(context, review.user),
          child: CircleAvatar(
            backgroundImage: NetworkImage(review.user.profileUrl),
            onBackgroundImageError: (_, __) {},
            radius: 22,
          ),
        ),
        title: GestureDetector(
          onTap: () => _navigateToUserProfile(context, review.user),
          child: Row(
            children: [
              Text(
                review.user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (isOwnReview)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    '(TWOJA RECENZJA)',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(review.content),
            const SizedBox(height: 4),
            Text(
              '${review.sentiment.toUpperCase()} • ${review.createdAt.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOrEditReviewDialog({Review? existingReview}) {
    final contentController = TextEditingController(text: existingReview?.content ?? '');
    String sentiment = existingReview?.sentiment ?? 'neutral';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingReview == null ? 'Dodaj recenzję' : 'Edytuj recenzję'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Treść recenzji'),
          maxLines: 3,
        ),
        actions: [
          if (existingReview != null)
            TextButton(
              child: const Text('Usuń', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await ReviewService.deleteReview(existingReview.id);
                Navigator.pop(context);
                setState(() {
                  _reviewsFuture = ReviewService.getReviewsForBook(widget.book.id);
                });
              },
            ),
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(existingReview == null ? 'Dodaj' : 'Zapisz'),
            onPressed: () async {
              final content = contentController.text.trim();
              if (content.length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recenzja musi mieć przynajmniej 10 znaków.')),
                );
                return;
              }
              final user = Provider.of<AuthProvider>(context, listen: false).user!;
              final updatedReview = Review(
                id: existingReview?.id ?? 0,
                content: content,
                sentiment: sentiment,
                createdAt: existingReview?.createdAt ?? DateTime.now(),
                user: user,
              );
              final success = existingReview == null
                  ? await ReviewService.createReview(widget.book.id, updatedReview)
                  : await ReviewService.updateReview(updatedReview);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Zapisano recenzję' : 'Nie udało się zapisać')),
              );
              setState(() {
                _reviewsFuture = ReviewService.getReviewsForBook(widget.book.id);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButtons(PaginatedPage<Review> page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (page.previousUrl != null)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _reviewsFuture = ReviewService.getReviewsForBook(widget.book.id, pageUrl: page.previousUrl);
              });
            },
            child: const Text('Poprzednia strona'),
          ),
        if (page.nextUrl != null)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _reviewsFuture = ReviewService.getReviewsForBook(widget.book.id, pageUrl: page.nextUrl);
              });
            },
            child: const Text('Następna strona'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: FutureBuilder<PaginatedPage<Review>?>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
            return const Center(child: Text('Brak recenzji dla tej książki.'));
          }

          final page = snapshot.data!;
          final reviews = page.items;
          final user = auth.user;
          final ownReview = user == null
              ? null
              : reviews.firstWhere(
                (r) => r.user.id == user.id,
            orElse: () => Review(
              id: -1,
              content: '',
              sentiment: 'neutral',
              createdAt: DateTime.now(),
              user: user,
            ),
          );
          final displayedOwnReview = ownReview == null || ownReview.id == -1 ? null : ownReview;
          final otherReviews = ownReview == null ? reviews : reviews.where((r) => r.id != ownReview.id).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Image.network(
                widget.book.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 150),
              ),
              const SizedBox(height: 12),
              Center(child: Text(widget.book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(height: 6),
              Center(child: Text(widget.book.category, style: const TextStyle(fontSize: 16, color: Colors.grey))),
              const SizedBox(height: 6),
              Center(child: Text('Ocena: ${widget.book.avgRating}', style: const TextStyle(fontSize: 16, color: Colors.grey))),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => _showAuthorDialog(widget.book.author),
                  child: Text('Autor: ${widget.book.author.name}', style: const TextStyle(fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(widget.book.description, textAlign: TextAlign.justify, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Data publikacji: ${widget.book.publishedDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: Text('Recenzje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
              ),
              if (displayedOwnReview != null) _buildReviewCard(displayedOwnReview, isOwnReview: true),
              ...otherReviews.map((r) => _buildReviewCard(r)),
              const SizedBox(height: 10),
              _buildPaginationButtons(page),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
      floatingActionButton: auth.isLoggedIn
          ? FutureBuilder<PaginatedPage<Review>?>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final user = auth.user;
          final existingReview = user == null
              ? null
              : snapshot.data!.items.firstWhere(
                (r) => r.user.id == user.id,
            orElse: () => Review(
              id: -1,
              content: '',
              sentiment: 'neutral',
              createdAt: DateTime.now(),
              user: user,
            ),
          );
          final reviewToEdit = existingReview == null || existingReview.id == -1 ? null : existingReview;
          return FloatingActionButton(
            onPressed: () => _showAddOrEditReviewDialog(existingReview: reviewToEdit),
            tooltip: reviewToEdit == null ? 'Dodaj recenzję' : 'Edytuj recenzję',
            child: Icon(reviewToEdit == null ? Icons.rate_review : Icons.edit),
          );
        },
      )
          : null,
    );
  }
}
