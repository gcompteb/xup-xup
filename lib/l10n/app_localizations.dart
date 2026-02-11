import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'xup-xup'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Know what to cook'**
  String get appSlogan;

  /// No description provided for @navSuggestions.
  ///
  /// In en, this message translates to:
  /// **'What to cook?'**
  String get navSuggestions;

  /// No description provided for @navDishes.
  ///
  /// In en, this message translates to:
  /// **'My dishes'**
  String get navDishes;

  /// No description provided for @navPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get navPantry;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSignInContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSignInContinue;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOr;

  /// No description provided for @loginContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueGoogle;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUp;

  /// No description provided for @loginValidateEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get loginValidateEmailEmpty;

  /// No description provided for @loginValidateEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get loginValidateEmailInvalid;

  /// No description provided for @loginValidatePasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginValidatePasswordEmpty;

  /// No description provided for @loginValidatePasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginValidatePasswordShort;

  /// No description provided for @registerJoin.
  ///
  /// In en, this message translates to:
  /// **'Join xup-xup'**
  String get registerJoin;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerCreateAccount;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get registerFullNameHint;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get registerPasswordHelper;

  /// No description provided for @registerCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateButton;

  /// No description provided for @registerSignUpGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get registerSignUpGoogle;

  /// No description provided for @registerAlreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerAlreadyAccount;

  /// No description provided for @registerValidateNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get registerValidateNameEmpty;

  /// No description provided for @registerValidatePasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get registerValidatePasswordEmpty;

  /// No description provided for @registerValidateConfirmEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get registerValidateConfirmEmpty;

  /// No description provided for @registerValidatePasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerValidatePasswordMatch;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @dishesTitle.
  ///
  /// In en, this message translates to:
  /// **'My dishes'**
  String get dishesTitle;

  /// No description provided for @dishesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search dish...'**
  String get dishesSearchHint;

  /// No description provided for @dishesNewDish.
  ///
  /// In en, this message translates to:
  /// **'New dish'**
  String get dishesNewDish;

  /// No description provided for @dishesFilterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Filter favorites'**
  String get dishesFilterFavorites;

  /// No description provided for @dishesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No dish matches \"{query}\"'**
  String dishesNoMatch(String query);

  /// No description provided for @dishesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dishes yet'**
  String get dishesEmpty;

  /// No description provided for @dishesEmptyFilter.
  ///
  /// In en, this message translates to:
  /// **'No dishes with this filter'**
  String get dishesEmptyFilter;

  /// No description provided for @dishesAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first dish!'**
  String get dishesAddFirst;

  /// No description provided for @dishesRemoveFav.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get dishesRemoveFav;

  /// No description provided for @dishesFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get dishesFavorite;

  /// No description provided for @dishesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dishesDelete;

  /// No description provided for @dishesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete dish'**
  String get dishesDeleteTitle;

  /// No description provided for @dishesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String dishesDeleteConfirm(String name);

  /// No description provided for @dishesIngCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ing.'**
  String dishesIngCount(int count);

  /// No description provided for @dishNotFound.
  ///
  /// In en, this message translates to:
  /// **'Dish not found'**
  String get dishNotFound;

  /// No description provided for @dishIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get dishIngredients;

  /// No description provided for @dishSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get dishSteps;

  /// No description provided for @dishEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dishEdit;

  /// No description provided for @dishCooked.
  ///
  /// In en, this message translates to:
  /// **'Cooked!'**
  String get dishCooked;

  /// No description provided for @dishPersons.
  ///
  /// In en, this message translates to:
  /// **'{count} pers.'**
  String dishPersons(int count);

  /// No description provided for @dishAlternativesNeed1.
  ///
  /// In en, this message translates to:
  /// **'Alternatives (need 1)'**
  String get dishAlternativesNeed1;

  /// No description provided for @dishOptionals.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get dishOptionals;

  /// No description provided for @dishMarkCooked.
  ///
  /// In en, this message translates to:
  /// **'Mark as cooked'**
  String get dishMarkCooked;

  /// No description provided for @dishServings.
  ///
  /// In en, this message translates to:
  /// **'Servings: '**
  String get dishServings;

  /// No description provided for @dishRecipeServingsChange.
  ///
  /// In en, this message translates to:
  /// **'Recipe: {original} serv. → Cooking: {current} serv.'**
  String dishRecipeServingsChange(int original, int current);

  /// No description provided for @dishRequired.
  ///
  /// In en, this message translates to:
  /// **'Required:'**
  String get dishRequired;

  /// No description provided for @dishAlternativesMin1.
  ///
  /// In en, this message translates to:
  /// **'Alternatives (min 1):'**
  String get dishAlternativesMin1;

  /// No description provided for @dishOptionalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional:'**
  String get dishOptionalsLabel;

  /// No description provided for @dishCookedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} cooked for {servings}! Ingredients updated.'**
  String dishCookedSuccess(String name, int servings);

  /// No description provided for @dishMissingIngredients.
  ///
  /// In en, this message translates to:
  /// **'Missing ingredients'**
  String get dishMissingIngredients;

  /// No description provided for @addDishTitle.
  ///
  /// In en, this message translates to:
  /// **'New dish'**
  String get addDishTitle;

  /// No description provided for @editDishTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit dish'**
  String get editDishTitle;

  /// No description provided for @addDishSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addDishSave;

  /// No description provided for @addDishCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get addDishCamera;

  /// No description provided for @addDishGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get addDishGallery;

  /// No description provided for @addDishAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addDishAddPhoto;

  /// No description provided for @addDishName.
  ///
  /// In en, this message translates to:
  /// **'Dish name'**
  String get addDishName;

  /// No description provided for @addDishValidateName.
  ///
  /// In en, this message translates to:
  /// **'Enter dish name'**
  String get addDishValidateName;

  /// No description provided for @addDishDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get addDishDifficulty;

  /// No description provided for @addDishTime.
  ///
  /// In en, this message translates to:
  /// **'Time (min)'**
  String get addDishTime;

  /// No description provided for @addDishServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get addDishServings;

  /// No description provided for @addDishHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get addDishHealthy;

  /// No description provided for @addDishIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get addDishIngredients;

  /// No description provided for @addDishAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addDishAdd;

  /// No description provided for @addDishNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients added'**
  String get addDishNoIngredients;

  /// No description provided for @addDishSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps (optional)'**
  String get addDishSteps;

  /// No description provided for @addDishNoSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps added'**
  String get addDishNoSteps;

  /// No description provided for @addDishSelectIngredient.
  ///
  /// In en, this message translates to:
  /// **'Select ingredient'**
  String get addDishSelectIngredient;

  /// No description provided for @addDishCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new ingredient'**
  String get addDishCreateNew;

  /// No description provided for @addDishAddToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add to pantry'**
  String get addDishAddToPantry;

  /// No description provided for @addDishNewIngredient.
  ///
  /// In en, this message translates to:
  /// **'New ingredient'**
  String get addDishNewIngredient;

  /// No description provided for @addDishCreateAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Create and add'**
  String get addDishCreateAndAdd;

  /// No description provided for @addDishSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get addDishSearch;

  /// No description provided for @addDishNoPantryIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients in pantry'**
  String get addDishNoPantryIngredients;

  /// No description provided for @addDishNoIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found'**
  String get addDishNoIngredientsFound;

  /// No description provided for @addDishAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available: {text}'**
  String addDishAvailable(String text);

  /// No description provided for @addDishPantryAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available in pantry: {text}'**
  String addDishPantryAvailable(String text);

  /// No description provided for @addDishFirstAddPantry.
  ///
  /// In en, this message translates to:
  /// **'First add ingredients to pantry'**
  String get addDishFirstAddPantry;

  /// No description provided for @addDishAllAdded.
  ///
  /// In en, this message translates to:
  /// **'All pantry ingredients already added'**
  String get addDishAllAdded;

  /// No description provided for @addDishAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient'**
  String get addDishAtLeastOne;

  /// No description provided for @addDishStepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String addDishStepNumber(int number);

  /// No description provided for @addDishStepDescription.
  ///
  /// In en, this message translates to:
  /// **'Step description'**
  String get addDishStepDescription;

  /// No description provided for @addDishStepHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Dice the vegetables into small cubes'**
  String get addDishStepHint;

  /// No description provided for @addDishFirstInGroup.
  ///
  /// In en, this message translates to:
  /// **'First ingredient of group {group}'**
  String addDishFirstInGroup(String group);

  /// No description provided for @addDishAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives: {names}'**
  String addDishAlternatives(String names);

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @typeRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get typeRequired;

  /// No description provided for @typeOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get typeOptional;

  /// No description provided for @typeAlternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get typeAlternative;

  /// No description provided for @typeIngredientLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient type'**
  String get typeIngredientLabel;

  /// No description provided for @typeRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'Needed to make the dish'**
  String get typeRequiredDesc;

  /// No description provided for @typeOptionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Can be added if available'**
  String get typeOptionalDesc;

  /// No description provided for @typeAlternativeDesc.
  ///
  /// In en, this message translates to:
  /// **'Interchangeable with others in group'**
  String get typeAlternativeDesc;

  /// No description provided for @typeGroup.
  ///
  /// In en, this message translates to:
  /// **'Group: '**
  String get typeGroup;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @unitUnitats.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get unitUnitats;

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitL.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get unitL;

  /// No description provided for @unitCullerada.
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get unitCullerada;

  /// No description provided for @unitCulleradeta.
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get unitCulleradeta;

  /// No description provided for @unitTassa.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get unitTassa;

  /// No description provided for @unitPessic.
  ///
  /// In en, this message translates to:
  /// **'pinch'**
  String get unitPessic;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @healthLevelHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthLevelHealthy;

  /// No description provided for @healthLevelNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get healthLevelNormal;

  /// No description provided for @healthLevelUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get healthLevelUnhealthy;

  /// No description provided for @pantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantryTitle;

  /// No description provided for @pantrySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search ingredient...'**
  String get pantrySearchHint;

  /// No description provided for @pantryAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get pantryAddButton;

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Pantry is empty'**
  String get pantryEmpty;

  /// No description provided for @pantryNoResults.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found'**
  String get pantryNoResults;

  /// No description provided for @pantryAddIngredients.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients!'**
  String get pantryAddIngredients;

  /// No description provided for @pantryExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredient{count, plural, =1{} other{s}} expiring soon'**
  String pantryExpiringSoon(int count);

  /// No description provided for @pantryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient to pantry'**
  String get pantryAddTitle;

  /// No description provided for @pantryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String pantryEditTitle(String name);

  /// No description provided for @pantryExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get pantryExpiry;

  /// No description provided for @pantryExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get pantryExpiryDate;

  /// No description provided for @pantryNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get pantryNoDate;

  /// No description provided for @pantryExpiredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {days} days ago'**
  String pantryExpiredDaysAgo(int days);

  /// No description provided for @pantryExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today!'**
  String get pantryExpiresToday;

  /// No description provided for @pantryExpiresTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Expires tomorrow'**
  String get pantryExpiresTomorrow;

  /// No description provided for @pantryExpiresInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String pantryExpiresInDays(int days);

  /// No description provided for @pantryExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String pantryExpiresOn(String date);

  /// No description provided for @pantryCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete'**
  String get pantryCannotDelete;

  /// No description provided for @pantryUsedIn.
  ///
  /// In en, this message translates to:
  /// **'The ingredient \"{name}\" is used in:'**
  String pantryUsedIn(String name);

  /// No description provided for @pantryDishesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dishes:'**
  String get pantryDishesLabel;

  /// No description provided for @pantryShoppingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shopping list:'**
  String get pantryShoppingLabel;

  /// No description provided for @pantryDeleteFirst.
  ///
  /// In en, this message translates to:
  /// **'Delete these items first to remove the ingredient.'**
  String get pantryDeleteFirst;

  /// No description provided for @pantryUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get pantryUnderstood;

  /// No description provided for @pantryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete ingredient'**
  String get pantryDeleteTitle;

  /// No description provided for @pantryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String pantryDeleteConfirm(String name);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanTitle;

  /// No description provided for @scanAddToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add to pantry'**
  String get scanAddToPantry;

  /// No description provided for @scanChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get scanChangeImage;

  /// No description provided for @scanAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing receipt...'**
  String get scanAnalyzing;

  /// No description provided for @scanRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get scanRetry;

  /// No description provided for @scanTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the receipt'**
  String get scanTakePhoto;

  /// No description provided for @scanNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found'**
  String get scanNoIngredients;

  /// No description provided for @scanDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected ingredients ({count})'**
  String scanDetected(int count);

  /// No description provided for @scanUncertain.
  ///
  /// In en, this message translates to:
  /// **'{count} with doubts'**
  String scanUncertain(int count);

  /// No description provided for @scanSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get scanSelectAll;

  /// No description provided for @scanDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get scanDeselectAll;

  /// No description provided for @scanDeselectUncertain.
  ///
  /// In en, this message translates to:
  /// **'Deselect uncertain'**
  String get scanDeselectUncertain;

  /// No description provided for @scanRemoveUncertain.
  ///
  /// In en, this message translates to:
  /// **'Remove {count} uncertain'**
  String scanRemoveUncertain(int count);

  /// No description provided for @scanSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one ingredient'**
  String get scanSelectAtLeastOne;

  /// No description provided for @scanAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients added to pantry!'**
  String scanAddedSuccess(int count);

  /// No description provided for @scanNewIngredient.
  ///
  /// In en, this message translates to:
  /// **'New ingredient'**
  String get scanNewIngredient;

  /// No description provided for @scanEditIngredient.
  ///
  /// In en, this message translates to:
  /// **'Edit ingredient'**
  String get scanEditIngredient;

  /// No description provided for @scanLinkIngredient.
  ///
  /// In en, this message translates to:
  /// **'Link ingredient'**
  String get scanLinkIngredient;

  /// No description provided for @scanDetectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected: \"{name}\"'**
  String scanDetectedLabel(String name);

  /// No description provided for @scanSearchPantry.
  ///
  /// In en, this message translates to:
  /// **'Search in pantry...'**
  String get scanSearchPantry;

  /// No description provided for @scanCreateAsNew.
  ///
  /// In en, this message translates to:
  /// **'Create as new'**
  String get scanCreateAsNew;

  /// No description provided for @scanAddNameToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add \"{name}\" to pantry'**
  String scanAddNameToPantry(String name);

  /// No description provided for @scanNoPantryIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients in pantry'**
  String get scanNoPantryIngredients;

  /// No description provided for @scanTicketLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket: \"{text}\"'**
  String scanTicketLabel(String text);

  /// No description provided for @suggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'What to cook?'**
  String get suggestionsTitle;

  /// No description provided for @suggestionsSurprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise!'**
  String get suggestionsSurprise;

  /// No description provided for @suggestionsHaveAll.
  ///
  /// In en, this message translates to:
  /// **'I have everything'**
  String get suggestionsHaveAll;

  /// No description provided for @suggestionsMaxMinutes.
  ///
  /// In en, this message translates to:
  /// **'≤ {minutes} min'**
  String suggestionsMaxMinutes(int minutes);

  /// No description provided for @suggestionsInPantry.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients in pantry'**
  String suggestionsInPantry(int count);

  /// No description provided for @suggestionsNoDishes.
  ///
  /// In en, this message translates to:
  /// **'No dishes yet'**
  String get suggestionsNoDishes;

  /// No description provided for @suggestionsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No dishes match these filters'**
  String get suggestionsNoMatch;

  /// No description provided for @suggestionsCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create first dish'**
  String get suggestionsCreateFirst;

  /// No description provided for @suggestionsNoDishesCreated.
  ///
  /// In en, this message translates to:
  /// **'No dishes yet'**
  String get suggestionsNoDishesCreated;

  /// No description provided for @suggestionsNoFilterMatch.
  ///
  /// In en, this message translates to:
  /// **'No dishes match these filters'**
  String get suggestionsNoFilterMatch;

  /// No description provided for @suggestionsTodayCook.
  ///
  /// In en, this message translates to:
  /// **'Today you cook...'**
  String get suggestionsTodayCook;

  /// No description provided for @suggestionsViewRecipe.
  ///
  /// In en, this message translates to:
  /// **'View recipe'**
  String get suggestionsViewRecipe;

  /// No description provided for @shoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingTitle;

  /// No description provided for @shoppingAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get shoppingAddButton;

  /// No description provided for @shoppingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Shopping list is empty'**
  String get shoppingEmpty;

  /// No description provided for @shoppingAddWhat.
  ///
  /// In en, this message translates to:
  /// **'Add what you need to buy!'**
  String get shoppingAddWhat;

  /// No description provided for @shoppingToBuy.
  ///
  /// In en, this message translates to:
  /// **'To buy'**
  String get shoppingToBuy;

  /// No description provided for @shoppingBought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get shoppingBought;

  /// No description provided for @shoppingToPantry.
  ///
  /// In en, this message translates to:
  /// **'To pantry'**
  String get shoppingToPantry;

  /// No description provided for @shoppingTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer to pantry'**
  String get shoppingTransferTitle;

  /// No description provided for @shoppingTransferToPantry.
  ///
  /// In en, this message translates to:
  /// **'Transfer to pantry'**
  String get shoppingTransferToPantry;

  /// No description provided for @shoppingTransferBody.
  ///
  /// In en, this message translates to:
  /// **'Checked items will be moved to the pantry. If they already exist, the quantity will be added.'**
  String get shoppingTransferBody;

  /// No description provided for @shoppingTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get shoppingTransfer;

  /// No description provided for @shoppingTransferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Items transferred to pantry'**
  String get shoppingTransferSuccess;

  /// No description provided for @shoppingDeleteChecked.
  ///
  /// In en, this message translates to:
  /// **'Delete checked'**
  String get shoppingDeleteChecked;

  /// No description provided for @shoppingAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get shoppingAddToList;

  /// No description provided for @shoppingNewIngredient.
  ///
  /// In en, this message translates to:
  /// **'Create new ingredient'**
  String get shoppingNewIngredient;

  /// No description provided for @shoppingAddToPantryAndList.
  ///
  /// In en, this message translates to:
  /// **'Add to pantry and list'**
  String get shoppingAddToPantryAndList;

  /// No description provided for @shoppingNoPantryIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients in pantry'**
  String get shoppingNoPantryIngredients;

  /// No description provided for @shoppingNoIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found'**
  String get shoppingNoIngredientsFound;

  /// No description provided for @shoppingInPantry.
  ///
  /// In en, this message translates to:
  /// **'In pantry: {text}'**
  String shoppingInPantry(String text);

  /// No description provided for @notificationExpiresTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ {name} expires today!'**
  String notificationExpiresTitle(String name);

  /// No description provided for @notificationExpiresBody.
  ///
  /// In en, this message translates to:
  /// **'Use it before it expires!'**
  String get notificationExpiresBody;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient expiry'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Ingredient expiry notifications'**
  String get notificationChannelDesc;

  /// No description provided for @notificationTestTitle.
  ///
  /// In en, this message translates to:
  /// **'🧪 Test notification'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are working correctly!'**
  String get notificationTestBody;
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
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
