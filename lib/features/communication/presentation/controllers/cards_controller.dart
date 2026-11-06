import 'dart:async';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/communication/data/content_repository.dart';
import 'package:ajyal/features/communication/data/models/communication_card.dart';
import 'package:ajyal/features/communication/data/models/story_item.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CardsController extends GetxController {
  final ContentRepository _content = Get.find<ContentRepository>();
  final ChildRepository _children = Get.find<ChildRepository>();
  final AudioPlayer _player = AudioPlayer();

  final status = ViewStatus.loading.obs;
  final errorMessage = RxnString();
  final child = Rxn<ChildProfile>();
  final cards = <CommunicationCard>[].obs;
  final stories = <StoryItem>[].obs;
  final query = ''.obs;
  final isSaving = false.obs;
  final playingCardId = RxnString();

  StreamSubscription<List<CommunicationCard>>? _cardsSub;
  StreamSubscription<List<StoryItem>>? _storiesSub;
  StreamSubscription<void>? _playerSub;

  List<CommunicationCard> get visibleCards {
    final needle = query.value.trim().toLowerCase();
    if (needle.isEmpty) return cards;
    return cards.where((c) => c.label.toLowerCase().contains(needle)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _playerSub = _player.onPlayerComplete.listen((_) {
      playingCardId.value = null;
    });
    load();
  }

  void load() {
    _cardsSub?.cancel();
    _storiesSub?.cancel();
    errorMessage.value = null;
    status.value = ViewStatus.loading;

    final profile = _children.getProfile();
    child.value = profile;
    if (profile == null) {
      status.value = ViewStatus.empty;
      return;
    }

    try {
      _cardsSub = _content.watchCards(profile.id).listen(
        (list) {
          cards.assignAll(list);
          status.value = ViewStatus.success;
        },
        onError: (Object e) {
          errorMessage.value = resolveErrorMessage(e);
          status.value = ViewStatus.error;
        },
      );
      _storiesSub = _content.watchStories(profile.id).listen(
        (list) => stories.assignAll(list),
        onError: (_) {},
      );
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
      status.value = ViewStatus.error;
    }
  }

  void setQuery(String value) => query.value = value;

  // ---------- البطاقات ----------

  Future<void> saveCard({
    CommunicationCard? existing,
    required String label,
    String? imageFilePath,
    String? audioFilePath,
  }) async {
    final profile = child.value;
    if (profile == null) return;

    final hasImage =
        imageFilePath != null || (existing?.imageUrl.isNotEmpty ?? false);
    final hasAudio =
        audioFilePath != null || (existing?.audioUrl.isNotEmpty ?? false);
    if (!hasImage) {
      _showError(
        const AppException(AppErrorType.validation, 'err_card_image_required'),
      );
      return;
    }
    if (!hasAudio) {
      _showError(
        const AppException(AppErrorType.validation, 'err_card_audio_required'),
      );
      return;
    }

    isSaving.value = true;
    try {
      await _content.saveCard(
        childId: profile.id,
        existing: existing,
        label: label,
        imageFilePath: imageFilePath,
        audioFilePath: audioFilePath,
      );
      if (Get.isBottomSheetOpen == true) Get.back();
      Get.snackbar(
        'app_name'.tr,
        'card_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCard(CommunicationCard card) async {
    try {
      await _content.deleteCard(card);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> playCard(CommunicationCard card) async {
    if (card.audioUrl.isEmpty) return;
    try {
      await _player.stop();
      playingCardId.value = card.id;
      await _player.play(UrlSource(card.audioUrl));
    } catch (e) {
      playingCardId.value = null;
      debugPrint('CardsController.playCard failed: $e');
      _showError(e);
    }
  }

  // ---------- القصص ----------

  Future<void> saveStory({
    required String title,
    required String youtubeUrl,
  }) async {
    final profile = child.value;
    if (profile == null) return;

    isSaving.value = true;
    try {
      await _content.saveStory(
        childId: profile.id,
        title: title,
        youtubeUrl: youtubeUrl,
      );
      if (Get.isBottomSheetOpen == true) Get.back();
      Get.snackbar(
        'app_name'.tr,
        'story_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _showError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteStory(StoryItem story) async {
    try {
      await _content.deleteStory(story.id);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> openStory(StoryItem story) async {
    final opened = await launchUrl(
      Uri.parse(story.watchUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      Get.snackbar(
        'app_name'.tr,
        'err_unknown'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showError(Object error) => Get.snackbar(
        'app_name'.tr,
        resolveErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );

  @override
  void onClose() {
    _cardsSub?.cancel();
    _storiesSub?.cancel();
    _playerSub?.cancel();
    _player.dispose();
    super.onClose();
  }
}

class CardsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(CardsController.new);
}