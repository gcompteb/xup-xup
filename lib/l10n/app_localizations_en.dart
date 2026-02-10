// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'xup-xup';

  @override
  String get appSlogan => 'Know what to cook';

  @override
  String get navSuggestions => 'What to cook?';

  @override
  String get navDishes => 'My dishes';

  @override
  String get navPantry => 'Pantry';

  @override
  String get navShopping => 'Shopping';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSignInContinue => 'Sign in to continue';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginEmailHint => 'your@email.com';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSignIn => 'Sign In';

  @override
  String get loginOr => 'or';

  @override
  String get loginContinueGoogle => 'Continue with Google';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginSignUp => 'Sign Up';

  @override
  String get loginValidateEmailEmpty => 'Please enter your email';

  @override
  String get loginValidateEmailInvalid => 'Please enter a valid email';

  @override
  String get loginValidatePasswordEmpty => 'Please enter your password';

  @override
  String get loginValidatePasswordShort =>
      'Password must be at least 6 characters';

  @override
  String get registerJoin => 'Join xup-xup';

  @override
  String get registerCreateAccount => 'Create your account';

  @override
  String get registerFullName => 'Full Name';

  @override
  String get registerFullNameHint => 'John Doe';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerPasswordHelper => 'At least 6 characters';

  @override
  String get registerCreateButton => 'Create Account';

  @override
  String get registerSignUpGoogle => 'Sign up with Google';

  @override
  String get registerAlreadyAccount => 'Already have an account? ';

  @override
  String get registerValidateNameEmpty => 'Please enter your name';

  @override
  String get registerValidatePasswordEmpty => 'Please enter a password';

  @override
  String get registerValidateConfirmEmpty => 'Please confirm your password';

  @override
  String get registerValidatePasswordMatch => 'Passwords do not match';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get dishesTitle => 'My dishes';

  @override
  String get dishesSearchHint => 'Search dish...';

  @override
  String get dishesNewDish => 'New dish';

  @override
  String get dishesFilterFavorites => 'Filter favorites';

  @override
  String dishesNoMatch(String query) {
    return 'No dish matches \"$query\"';
  }

  @override
  String get dishesEmpty => 'No dishes yet';

  @override
  String get dishesEmptyFilter => 'No dishes with this filter';

  @override
  String get dishesAddFirst => 'Add your first dish!';

  @override
  String get dishesRemoveFav => 'Remove';

  @override
  String get dishesFavorite => 'Favorite';

  @override
  String get dishesDelete => 'Delete';

  @override
  String get dishesDeleteTitle => 'Delete dish';

  @override
  String dishesDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String dishesIngCount(int count) {
    return '$count ing.';
  }

  @override
  String get dishNotFound => 'Dish not found';

  @override
  String get dishIngredients => 'Ingredients';

  @override
  String get dishSteps => 'Steps';

  @override
  String get dishEdit => 'Edit';

  @override
  String get dishCooked => 'Cooked!';

  @override
  String dishPersons(int count) {
    return '$count pers.';
  }

  @override
  String get dishAlternativesNeed1 => 'Alternatives (need 1)';

  @override
  String get dishOptionals => 'Optional';

  @override
  String get dishMarkCooked => 'Mark as cooked';

  @override
  String get dishServings => 'Servings: ';

  @override
  String dishRecipeServingsChange(int original, int current) {
    return 'Recipe: $original serv. → Cooking: $current serv.';
  }

  @override
  String get dishRequired => 'Required:';

  @override
  String get dishAlternativesMin1 => 'Alternatives (min 1):';

  @override
  String get dishOptionalsLabel => 'Optional:';

  @override
  String dishCookedSuccess(String name, int servings) {
    return '$name cooked for $servings! Ingredients updated.';
  }

  @override
  String get dishMissingIngredients => 'Missing ingredients';

  @override
  String get addDishTitle => 'New dish';

  @override
  String get editDishTitle => 'Edit dish';

  @override
  String get addDishSave => 'Save';

  @override
  String get addDishCamera => 'Camera';

  @override
  String get addDishGallery => 'Gallery';

  @override
  String get addDishAddPhoto => 'Add photo';

  @override
  String get addDishName => 'Dish name';

  @override
  String get addDishValidateName => 'Enter dish name';

  @override
  String get addDishDifficulty => 'Difficulty';

  @override
  String get addDishTime => 'Time (min)';

  @override
  String get addDishServings => 'Servings (people)';

  @override
  String get addDishIngredients => 'Ingredients';

  @override
  String get addDishAdd => 'Add';

  @override
  String get addDishNoIngredients => 'No ingredients added';

  @override
  String get addDishSteps => 'Steps (optional)';

  @override
  String get addDishNoSteps => 'No steps added';

  @override
  String get addDishSelectIngredient => 'Select ingredient';

  @override
  String get addDishCreateNew => 'Create new ingredient';

  @override
  String get addDishAddToPantry => 'Add to pantry';

  @override
  String get addDishNewIngredient => 'New ingredient';

  @override
  String get addDishCreateAndAdd => 'Create and add';

  @override
  String get addDishSearch => 'Search...';

  @override
  String get addDishNoPantryIngredients => 'No ingredients in pantry';

  @override
  String get addDishNoIngredientsFound => 'No ingredients found';

  @override
  String addDishAvailable(String text) {
    return 'Available: $text';
  }

  @override
  String addDishPantryAvailable(String text) {
    return 'Available in pantry: $text';
  }

  @override
  String get addDishFirstAddPantry => 'First add ingredients to pantry';

  @override
  String get addDishAllAdded => 'All pantry ingredients already added';

  @override
  String get addDishAtLeastOne => 'Add at least one ingredient';

  @override
  String addDishStepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get addDishStepDescription => 'Step description';

  @override
  String get addDishStepHint => 'E.g.: Dice the vegetables into small cubes';

  @override
  String addDishFirstInGroup(String group) {
    return 'First ingredient of group $group';
  }

  @override
  String addDishAlternatives(String names) {
    return 'Alternatives: $names';
  }

  @override
  String get typeLabel => 'Type';

  @override
  String get typeRequired => 'Required';

  @override
  String get typeOptional => 'Optional';

  @override
  String get typeAlternative => 'Alternative';

  @override
  String get typeIngredientLabel => 'Ingredient type';

  @override
  String get typeRequiredDesc => 'Needed to make the dish';

  @override
  String get typeOptionalDesc => 'Can be added if available';

  @override
  String get typeAlternativeDesc => 'Interchangeable with others in group';

  @override
  String get typeGroup => 'Group: ';

  @override
  String get name => 'Name';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get unitUnitats => 'units';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitCullerada => 'tbsp';

  @override
  String get unitCulleradeta => 'tsp';

  @override
  String get unitTassa => 'cup';

  @override
  String get unitPessic => 'pinch';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get pantryTitle => 'Pantry';

  @override
  String get pantrySearchHint => 'Search ingredient...';

  @override
  String get pantryAddButton => 'Add';

  @override
  String get pantryEmpty => 'Pantry is empty';

  @override
  String get pantryNoResults => 'No ingredients found';

  @override
  String get pantryAddIngredients => 'Add ingredients!';

  @override
  String pantryExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count ingredient$_temp0 expiring soon';
  }

  @override
  String get pantryAddTitle => 'Add ingredient to pantry';

  @override
  String pantryEditTitle(String name) {
    return 'Edit $name';
  }

  @override
  String get pantryExpiry => 'Expiry';

  @override
  String get pantryExpiryDate => 'Expiry date';

  @override
  String get pantryNoDate => 'No date';

  @override
  String pantryExpiredDaysAgo(int days) {
    return 'Expired $days days ago';
  }

  @override
  String get pantryExpiresToday => 'Expires today!';

  @override
  String get pantryExpiresTomorrow => 'Expires tomorrow';

  @override
  String pantryExpiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String pantryExpiresOn(String date) {
    return 'Expires: $date';
  }

  @override
  String get pantryCannotDelete => 'Cannot delete';

  @override
  String pantryUsedIn(String name) {
    return 'The ingredient \"$name\" is used in:';
  }

  @override
  String get pantryDishesLabel => 'Dishes:';

  @override
  String get pantryShoppingLabel => 'Shopping list:';

  @override
  String get pantryDeleteFirst =>
      'Delete these items first to remove the ingredient.';

  @override
  String get pantryUnderstood => 'Understood';

  @override
  String get pantryDeleteTitle => 'Delete ingredient';

  @override
  String pantryDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get scanTitle => 'Scan receipt';

  @override
  String get scanAddToPantry => 'Add to pantry';

  @override
  String get scanChangeImage => 'Change image';

  @override
  String get scanAnalyzing => 'Analyzing receipt...';

  @override
  String get scanRetry => 'Try again';

  @override
  String get scanTakePhoto => 'Take a photo of the receipt';

  @override
  String get scanNoIngredients => 'No ingredients found';

  @override
  String scanDetected(int count) {
    return 'Detected ingredients ($count)';
  }

  @override
  String scanUncertain(int count) {
    return '$count with doubts';
  }

  @override
  String get scanSelectAll => 'Select all';

  @override
  String get scanDeselectAll => 'Deselect all';

  @override
  String get scanDeselectUncertain => 'Deselect uncertain';

  @override
  String scanRemoveUncertain(int count) {
    return 'Remove $count uncertain';
  }

  @override
  String get scanSelectAtLeastOne => 'Select at least one ingredient';

  @override
  String scanAddedSuccess(int count) {
    return '$count ingredients added to pantry!';
  }

  @override
  String get scanNewIngredient => 'New ingredient';

  @override
  String get scanEditIngredient => 'Edit ingredient';

  @override
  String get scanLinkIngredient => 'Link ingredient';

  @override
  String scanDetectedLabel(String name) {
    return 'Detected: \"$name\"';
  }

  @override
  String get scanSearchPantry => 'Search in pantry...';

  @override
  String get scanCreateAsNew => 'Create as new';

  @override
  String scanAddNameToPantry(String name) {
    return 'Add \"$name\" to pantry';
  }

  @override
  String get scanNoPantryIngredients => 'No ingredients in pantry';

  @override
  String scanTicketLabel(String text) {
    return 'Ticket: \"$text\"';
  }

  @override
  String get suggestionsTitle => 'What to cook?';

  @override
  String get suggestionsSurprise => 'Surprise!';

  @override
  String get suggestionsHaveAll => 'I have everything';

  @override
  String suggestionsInPantry(int count) {
    return '$count ingredients in pantry';
  }

  @override
  String get suggestionsNoDishes => 'No dishes yet';

  @override
  String get suggestionsNoMatch => 'No dishes match these filters';

  @override
  String get suggestionsCreateFirst => 'Create first dish';

  @override
  String get suggestionsNoDishesCreated => 'No dishes yet';

  @override
  String get suggestionsNoFilterMatch => 'No dishes match these filters';

  @override
  String get suggestionsTodayCook => 'Today you cook...';

  @override
  String get suggestionsViewRecipe => 'View recipe';

  @override
  String get shoppingTitle => 'Shopping list';

  @override
  String get shoppingAddButton => 'Add';

  @override
  String get shoppingEmpty => 'Shopping list is empty';

  @override
  String get shoppingAddWhat => 'Add what you need to buy!';

  @override
  String get shoppingToBuy => 'To buy';

  @override
  String get shoppingBought => 'Bought';

  @override
  String get shoppingToPantry => 'To pantry';

  @override
  String get shoppingTransferTitle => 'Transfer to pantry';

  @override
  String get shoppingTransferToPantry => 'Transfer to pantry';

  @override
  String get shoppingTransferBody =>
      'Checked items will be moved to the pantry. If they already exist, the quantity will be added.';

  @override
  String get shoppingTransfer => 'Transfer';

  @override
  String get shoppingTransferSuccess => 'Items transferred to pantry';

  @override
  String get shoppingDeleteChecked => 'Delete checked';

  @override
  String get shoppingAddToList => 'Add to list';

  @override
  String get shoppingNewIngredient => 'Create new ingredient';

  @override
  String get shoppingAddToPantryAndList => 'Add to pantry and list';

  @override
  String get shoppingNoPantryIngredients => 'No ingredients in pantry';

  @override
  String get shoppingNoIngredientsFound => 'No ingredients found';

  @override
  String shoppingInPantry(String text) {
    return 'In pantry: $text';
  }

  @override
  String notificationExpiresTitle(String name) {
    return '⚠️ $name expires today!';
  }

  @override
  String get notificationExpiresBody => 'Use it before it expires!';

  @override
  String get notificationChannelName => 'Ingredient expiry';

  @override
  String get notificationChannelDesc => 'Ingredient expiry notifications';

  @override
  String get notificationTestTitle => '🧪 Test notification';

  @override
  String get notificationTestBody => 'Notifications are working correctly!';
}
