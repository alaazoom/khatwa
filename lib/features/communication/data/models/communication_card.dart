import 'package:cloud_firestore/cloud_firestore.dart';

class CommunicationCard {
  const CommunicationCard({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.label,
    required this.imageUrl,
    required this.imagePath,
    required this.audioUrl,
    required this.audioPath,
    required this.createdAt,
  });

  final String id;
  final String parentId;
  final String childId;
  final String label;
  final String imageUrl;
  final String imagePath;
  final String audioUrl;
  final String audioPath;
  final DateTime createdAt;

  factory CommunicationCard.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return CommunicationCard(
      id: doc.id,
      parentId: data['parentId'] as String? ?? '',
      childId: data['childId'] as String? ?? '',
      label: data['label'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      imagePath: data['imagePath'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      audioPath: data['audioPath'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}