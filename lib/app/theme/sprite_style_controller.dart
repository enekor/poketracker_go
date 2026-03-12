import 'package:get/get.dart';
import 'package:poketracker_go/core/constants/api_constants.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

class SpriteStyleController extends GetxController {
  final HiveService _hiveService = Get.find<HiveService>();
  final RxBool usePixelArt = true.obs;

  @override
  void onInit() {
    super.onInit();
    final settings = _hiveService.getSettings();
    usePixelArt.value = settings.usePixelArt;
  }

  void toggleStyle() {
    usePixelArt.value = !usePixelArt.value;
    final settings = _hiveService.getSettings();
    settings.usePixelArt = usePixelArt.value;
    _hiveService.saveSettings(settings);
  }

  String spriteUrl(int id) => usePixelArt.value
      ? ApiConstants.spriteUrl(id)
      : ApiConstants.spriteHomeUrl(id);

  String spriteShinyUrl(int id) => usePixelArt.value
      ? ApiConstants.spriteShinyUrl(id)
      : ApiConstants.spriteHomeShinyUrl(id);

  /// Pikachu sprite URL matching the current style (for the toggle button).
  String get pikachuSpriteUrl => spriteUrl(25);
}
