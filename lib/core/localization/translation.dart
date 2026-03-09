/// This file contains the translation keys for localization in the app.
/// It imports the `get` package for translations.
/// The `MyTranslation` class extends the `Translations` class and overrides the `keys` getter.
/// The `keys` getter returns a map of translation keys for different languages.
/// Each language has its own map of key-value pairs, where the key is a unique identifier and the value is the translated text.
library;

import 'package:get/get.dart';

class MyTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {"ar": {}, "en": {}};
}
