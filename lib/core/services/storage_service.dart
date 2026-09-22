import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _visitedKey = 'visited_countries';

  /// Загрузка списка посещенных стран из памяти браузера/устройства
  static Future<Set<String>> getVisitedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(
      _visitedKey,
    );
    return list
            ?.map((code) => code.toLowerCase())
            .toSet() ??
        {
          'at', // 🇦🇹 Австрия
          'by', // 🇧🇾 Беларусь
          'be', // 🇧🇪 Бельгия
          'va', // 🇻🇦 Ватикан
          'gb', // 🇬🇧 Великобритания
          'vn', // 🇻🇳 Вьетнам
          'de', // 🇩🇪 Германия
          'ge', // 🇬🇪 Грузия
          'in', // 🇮🇳 Индия
          'es', // 🇪🇸 Испания
          'it', // 🇮🇹 Италия
          'kh', // 🇰🇭 Камбоджа
          'cn', // 🇨🇳 Китай
          'la', // 🇱🇦 Лаос
          'lv', // 🇱🇻 Латвия
          'lt', // 🇱🇹 Литва
          'li', // 🇱🇮 Лихтенштейн
          'lu', // 🇱🇺 Люксембург
          'my', // 🇲🇾 Малайзия
          'mc', // 🇲🇨 Монако
          'nl', // 🇳🇱 Нидерланды
          'ae', // 🇦🇪 ОАЭ
          'pl', // 🇵🇱 Польша
          'ru', // 🇷🇺 Россия
          'sm', // 🇸🇲 Сан-Марино
          'me', // 🇲🇪 Черногория
          'cz', // 🇨🇿 Чехия
          'ch', // 🇨🇭 Швейцария
          'se', // 🇸🇪 Швеция
          'lk', // 🇱🇰 Шри-Ланка
          'tr', // 🇹🇷 Турция
          'ua', // 🇺🇦 Украина
          'fi', // 🇫🇮 Финляндия
          'fr', // 🇫🇷 Франция
          'ee', // 🇪🇪 Эстония
          'kr', // 🇰🇷 Южная Корея
          'jp', // 🇯🇵 Япония
          'id', // 🇮🇩 Индонезия
        }; // Дефолтные страны, если память пуста
  }

  /// Сохранение обновленного списка
  static Future<void> saveVisitedCountries(
    Set<String> visitedCodes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _visitedKey,
      visitedCodes
          .map((code) => code.toLowerCase())
          .toList(),
    );
  }
}
