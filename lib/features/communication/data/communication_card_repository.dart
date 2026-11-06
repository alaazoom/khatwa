// import 'dart:convert';

// import 'package:ajyal/core/storage/storage_service.dart';
// import 'package:ajyal/features/communication/data/models/communication_card.dart';
// import 'package:flutter/foundation.dart';


// class CommunicationCardRepository {
//   CommunicationCardRepository({required StorageService storage})
//       : _storage = storage;

//   final StorageService _storage;

//   static const List<CommunicationCard> defaultCards = [
//     CommunicationCard(
//       id: 'default_play',
//       label: 'card_want_play',
//       category: CardCategory.activities,
//       iconName: 'play',
//       tone: CardTone.tertiary,
//     ),
//     CommunicationCard(
//       id: 'default_water',
//       label: 'card_want_water',
//       category: CardCategory.needs,
//       iconName: 'water',
//       tone: CardTone.primary,
//     ),
//     CommunicationCard(
//       id: 'default_rest',
//       label: 'card_want_rest',
//       category: CardCategory.needs,
//       iconName: 'rest',
//       tone: CardTone.secondary,
//     ),
//     CommunicationCard(
//       id: 'default_help',
//       label: 'card_need_help',
//       category: CardCategory.needs,
//       iconName: 'help',
//       tone: CardTone.tertiary,
//     ),
//   ];

//   List<CommunicationCard> getCards(String childId) {
//     final raw = _storage.read<String>(StorageKeys.cards(childId));
//     if (raw == null) return List<CommunicationCard>.of(defaultCards);
//     try {
//       final list = jsonDecode(raw) as List<dynamic>;
//       return list
//           .map((e) => CommunicationCard.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e, stack) {
//       debugPrint('CommunicationCardRepository.getCards failed: $e\n$stack');
//       return List<CommunicationCard>.of(defaultCards);
//     }
//   }

//   Future<void> saveCards(String childId, List<CommunicationCard> cards) =>
//       _storage.write(
//         StorageKeys.cards(childId),
//         jsonEncode(cards.map((c) => c.toJson()).toList()),
//       );
// }