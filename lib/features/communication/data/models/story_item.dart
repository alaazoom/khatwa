import 'package:cloud_firestore/cloud_firestore.dart';

class StoryItem {
  const StoryItem({
    required this.id,
    required this.childId,
    required this.title,
    required this.youtubeUrl,
    required this.videoId,
    required this.createdAt,
  });

  final String id;
  final String childId;
  final String title;
  final String youtubeUrl;
  final String videoId;
  final DateTime createdAt;

  String get watchUrl => 'https://www.youtube.com/watch?v=$videoId';

  factory StoryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return StoryItem(
      id: doc.id,
      childId: data['childId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      youtubeUrl: data['youtubeUrl'] as String? ?? '',
      videoId: data['videoId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

  /// يستخرج معرّف الفيديو من روابط youtube.com و youtu.be و shorts و embed.
  static String? extractYoutubeId(String input) {
    var text = input.trim();
    if (text.isEmpty) return null;
    if (!text.startsWith('http')) text = 'https://$text';
    final uri = Uri.tryParse(text);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    String? id;
    if (host == 'youtu.be' || host == 'www.youtu.be') {
      id = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    } else if (host.endsWith('youtube.com')) {
      id = uri.queryParameters['v'];
      if (id == null) {
        const markers = {'embed', 'shorts', 'live'};
        final segments = uri.pathSegments;
        final index = segments.indexWhere(markers.contains);
        if (index != -1 && index + 1 < segments.length) {
          id = segments[index + 1];
        }
      }
    }

    if (id == null || !_idPattern.hasMatch(id)) return null;
    return id;
  }
}