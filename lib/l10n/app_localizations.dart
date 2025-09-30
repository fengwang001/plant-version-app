import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myCreations.
  ///
  /// In en, this message translates to:
  /// **'My Creations'**
  String get myCreations;

  /// No description provided for @premiumCreator.
  ///
  /// In en, this message translates to:
  /// **'Premium Creator'**
  String get premiumCreator;

  /// No description provided for @premiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy unlimited AI features'**
  String get premiumDesc;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @myStats.
  ///
  /// In en, this message translates to:
  /// **'My Stats'**
  String get myStats;

  /// No description provided for @creations.
  ///
  /// In en, this message translates to:
  /// **'Creations'**
  String get creations;

  /// No description provided for @aiVideos.
  ///
  /// In en, this message translates to:
  /// **'AI Videos'**
  String get aiVideos;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PlantVision'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the world of plants'**
  String get appSubtitle;

  /// No description provided for @scanPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan Plant'**
  String get scanPlant;

  /// No description provided for @recentIdentifications.
  ///
  /// In en, this message translates to:
  /// **'Recent Identifications'**
  String get recentIdentifications;

  /// No description provided for @featuredPlant.
  ///
  /// In en, this message translates to:
  /// **'Featured Plant'**
  String get featuredPlant;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @flowers.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get flowers;

  /// No description provided for @trees.
  ///
  /// In en, this message translates to:
  /// **'Trees'**
  String get trees;

  /// No description provided for @succulents.
  ///
  /// In en, this message translates to:
  /// **'Succulents'**
  String get succulents;

  /// No description provided for @herbs.
  ///
  /// In en, this message translates to:
  /// **'Herbs'**
  String get herbs;

  /// No description provided for @tropical.
  ///
  /// In en, this message translates to:
  /// **'Tropical'**
  String get tropical;

  /// No description provided for @rareSpecies.
  ///
  /// In en, this message translates to:
  /// **'Rare Species'**
  String get rareSpecies;

  /// No description provided for @ferns.
  ///
  /// In en, this message translates to:
  /// **'Ferns'**
  String get ferns;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @aiCreate.
  ///
  /// In en, this message translates to:
  /// **'AI Create'**
  String get aiCreate;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文 (Chinese)'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語 (Japanese)'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어 (Korean)'**
  String get korean;

  /// No description provided for @guestLogin.
  ///
  /// In en, this message translates to:
  /// **'Guest Login'**
  String get guestLogin;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @noRecentIdentifications.
  ///
  /// In en, this message translates to:
  /// **'No recent identifications'**
  String get noRecentIdentifications;

  /// No description provided for @identifyPlantToStart.
  ///
  /// In en, this message translates to:
  /// **'Identify a plant to get started'**
  String get identifyPlantToStart;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @identificationSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get identificationSource;

  /// No description provided for @plantDetails.
  ///
  /// In en, this message translates to:
  /// **'Plant Details'**
  String get plantDetails;

  /// No description provided for @scientificName.
  ///
  /// In en, this message translates to:
  /// **'Scientific Name'**
  String get scientificName;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Common Name'**
  String get commonName;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @genus.
  ///
  /// In en, this message translates to:
  /// **'Genus'**
  String get genus;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning!'**
  String get greeting_morning;

  /// No description provided for @home_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Which plant friend would you like to care for today?'**
  String get home_subtitle;

  /// No description provided for @search_plants.
  ///
  /// In en, this message translates to:
  /// **'Search plants...'**
  String get search_plants;

  /// No description provided for @recommended_plants.
  ///
  /// In en, this message translates to:
  /// **'Recommended Plants'**
  String get recommended_plants;

  /// No description provided for @my_plants.
  ///
  /// In en, this message translates to:
  /// **'My Plants'**
  String get my_plants;

  /// No description provided for @no_plants_message.
  ///
  /// In en, this message translates to:
  /// **'No plants added yet\nTap + to add your first plant friend'**
  String get no_plants_message;

  /// No description provided for @plant_succulent_name.
  ///
  /// In en, this message translates to:
  /// **'Succulent'**
  String get plant_succulent_name;

  /// No description provided for @plant_succulent_description.
  ///
  /// In en, this message translates to:
  /// **'Easy care, perfect for beginners'**
  String get plant_succulent_description;

  /// No description provided for @plant_pothos_name.
  ///
  /// In en, this message translates to:
  /// **'Pothos'**
  String get plant_pothos_name;

  /// No description provided for @plant_pothos_description.
  ///
  /// In en, this message translates to:
  /// **'Air purifying, fast growing'**
  String get plant_pothos_description;

  /// No description provided for @plant_cactus_name.
  ///
  /// In en, this message translates to:
  /// **'Cactus'**
  String get plant_cactus_name;

  /// No description provided for @plant_cactus_description.
  ///
  /// In en, this message translates to:
  /// **'Drought tolerant, unique shape'**
  String get plant_cactus_description;

  /// No description provided for @plant_mint_name.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get plant_mint_name;

  /// No description provided for @plant_mint_description.
  ///
  /// In en, this message translates to:
  /// **'Fresh fragrance, edible'**
  String get plant_mint_description;

  /// No description provided for @plant_snake_name.
  ///
  /// In en, this message translates to:
  /// **'Snake Plant'**
  String get plant_snake_name;

  /// No description provided for @plant_snake_description.
  ///
  /// In en, this message translates to:
  /// **'Air purifying, extremely easy care'**
  String get plant_snake_description;

  /// No description provided for @care_level_easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get care_level_easy;

  /// No description provided for @care_level_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get care_level_medium;

  /// No description provided for @care_level_very_easy.
  ///
  /// In en, this message translates to:
  /// **'Very Easy'**
  String get care_level_very_easy;

  /// No description provided for @sunlight_indirect.
  ///
  /// In en, this message translates to:
  /// **'Indirect light'**
  String get sunlight_indirect;

  /// No description provided for @sunlight_scattered.
  ///
  /// In en, this message translates to:
  /// **'Scattered light'**
  String get sunlight_scattered;

  /// No description provided for @sunlight_direct.
  ///
  /// In en, this message translates to:
  /// **'Direct sunlight'**
  String get sunlight_direct;

  /// No description provided for @sunlight_partial.
  ///
  /// In en, this message translates to:
  /// **'Partial sunlight'**
  String get sunlight_partial;

  /// No description provided for @sunlight_low.
  ///
  /// In en, this message translates to:
  /// **'Low light'**
  String get sunlight_low;

  /// No description provided for @water_low.
  ///
  /// In en, this message translates to:
  /// **'Less water'**
  String get water_low;

  /// No description provided for @water_moist.
  ///
  /// In en, this message translates to:
  /// **'Keep moist'**
  String get water_moist;

  /// No description provided for @water_very_low.
  ///
  /// In en, this message translates to:
  /// **'Very little water'**
  String get water_very_low;

  /// No description provided for @water_frequent.
  ///
  /// In en, this message translates to:
  /// **'Water frequently'**
  String get water_frequent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
