// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appName => 'xup-xup';

  @override
  String get appSlogan => 'Què cuinem avui?';

  @override
  String get navSuggestions => 'Què cuino?';

  @override
  String get navDishes => 'Els meus plats';

  @override
  String get navPantry => 'Rebost';

  @override
  String get navShopping => 'Compra';

  @override
  String get loginWelcomeBack => 'Benvingut/da';

  @override
  String get loginSignInContinue => 'Inicia sessió per continuar';

  @override
  String get loginEmail => 'Correu electrònic';

  @override
  String get loginEmailHint => 'el_teu@email.com';

  @override
  String get loginPassword => 'Contrasenya';

  @override
  String get loginSignIn => 'Iniciar sessió';

  @override
  String get loginOr => 'o';

  @override
  String get loginContinueGoogle => 'Continuar amb Google';

  @override
  String get loginNoAccount => 'No tens compte? ';

  @override
  String get loginSignUp => 'Registrar-se';

  @override
  String get loginValidateEmailEmpty => 'Introdueix el teu correu';

  @override
  String get loginValidateEmailInvalid => 'Introdueix un correu vàlid';

  @override
  String get loginValidatePasswordEmpty => 'Introdueix la teva contrasenya';

  @override
  String get loginValidatePasswordShort =>
      'La contrasenya ha de tenir almenys 6 caràcters';

  @override
  String get registerJoin => 'Uneix-te a xup-xup';

  @override
  String get registerCreateAccount => 'Crea el teu compte';

  @override
  String get registerFullName => 'Nom complet';

  @override
  String get registerFullNameHint => 'Joan Garcia';

  @override
  String get registerConfirmPassword => 'Confirmar contrasenya';

  @override
  String get registerPasswordHelper => 'Mínim 6 caràcters';

  @override
  String get registerCreateButton => 'Crear compte';

  @override
  String get registerSignUpGoogle => 'Registrar-se amb Google';

  @override
  String get registerAlreadyAccount => 'Ja tens un compte? ';

  @override
  String get registerValidateNameEmpty => 'Introdueix el teu nom';

  @override
  String get registerValidatePasswordEmpty => 'Introdueix una contrasenya';

  @override
  String get registerValidateConfirmEmpty => 'Confirma la teva contrasenya';

  @override
  String get registerValidatePasswordMatch =>
      'Les contrasenyes no coincideixen';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get somethingWentWrong => 'Alguna cosa ha anat malament';

  @override
  String get retry => 'Reintentar';

  @override
  String get dishesTitle => 'Els meus plats';

  @override
  String get dishesSearchHint => 'Cercar plat...';

  @override
  String get dishesNewDish => 'Nou plat';

  @override
  String get dishesFilterFavorites => 'Filtrar favorits';

  @override
  String dishesNoMatch(String query) {
    return 'Cap plat coincideix amb \"$query\"';
  }

  @override
  String get dishesEmpty => 'No tens cap plat encara';

  @override
  String get dishesEmptyFilter => 'No hi ha plats amb aquest filtre';

  @override
  String get dishesAddFirst => 'Afegeix el teu primer plat!';

  @override
  String get dishesRemoveFav => 'Treure';

  @override
  String get dishesFavorite => 'Favorit';

  @override
  String get dishesDelete => 'Eliminar';

  @override
  String get dishesDeleteTitle => 'Eliminar plat';

  @override
  String dishesDeleteConfirm(String name) {
    return 'Segur que vols eliminar \"$name\"?';
  }

  @override
  String dishesIngCount(int count) {
    return '$count ing.';
  }

  @override
  String get dishNotFound => 'Plat no trobat';

  @override
  String get dishIngredients => 'Ingredients';

  @override
  String get dishSteps => 'Passos';

  @override
  String get dishEdit => 'Editar';

  @override
  String get dishCooked => 'Cuinat!';

  @override
  String dishPersons(int count) {
    return '$count pers.';
  }

  @override
  String get dishAlternativesNeed1 => 'Alternatives (cal 1)';

  @override
  String get dishOptionals => 'Opcionals';

  @override
  String get dishMarkCooked => 'Marcar com a cuinat';

  @override
  String get dishServings => 'Porcions: ';

  @override
  String dishRecipeServingsChange(int original, int current) {
    return 'Recepta: $original porc. → Cuines: $current porc.';
  }

  @override
  String get dishRequired => 'Obligatoris:';

  @override
  String get dishAlternativesMin1 => 'Alternatives (mínim 1):';

  @override
  String get dishOptionalsLabel => 'Opcionals:';

  @override
  String dishCookedSuccess(String name, int servings) {
    return '$name cuinat per $servings! Ingredients actualitzats.';
  }

  @override
  String get dishMissingIngredients => 'Falten ingredients';

  @override
  String get addDishTitle => 'Nou plat';

  @override
  String get editDishTitle => 'Editar plat';

  @override
  String get addDishSave => 'Desar';

  @override
  String get addDishCamera => 'Càmera';

  @override
  String get addDishGallery => 'Galeria';

  @override
  String get addDishAddPhoto => 'Afegir foto';

  @override
  String get addDishName => 'Nom del plat';

  @override
  String get addDishValidateName => 'Introdueix el nom del plat';

  @override
  String get addDishDifficulty => 'Dificultat';

  @override
  String get addDishTime => 'Temps (min)';

  @override
  String get addDishServings => 'Porcions';

  @override
  String get addDishHealthy => 'Saludable';

  @override
  String get addDishIngredients => 'Ingredients';

  @override
  String get addDishAdd => 'Afegir';

  @override
  String get addDishNoIngredients => 'Cap ingredient afegit';

  @override
  String get addDishSteps => 'Passos (opcional)';

  @override
  String get addDishNoSteps => 'Cap pas afegit';

  @override
  String get addDishSelectIngredient => 'Selecciona ingredient';

  @override
  String get addDishCreateNew => 'Crear nou ingredient';

  @override
  String get addDishAddToPantry => 'Afegir al rebost';

  @override
  String get addDishNewIngredient => 'Nou ingredient';

  @override
  String get addDishCreateAndAdd => 'Crear i afegir';

  @override
  String get addDishSearch => 'Cercar...';

  @override
  String get addDishNoPantryIngredients => 'No tens ingredients al rebost';

  @override
  String get addDishNoIngredientsFound => 'No s\'han trobat ingredients';

  @override
  String addDishAvailable(String text) {
    return 'Disponible: $text';
  }

  @override
  String addDishPantryAvailable(String text) {
    return 'Disponible al rebost: $text';
  }

  @override
  String get addDishFirstAddPantry => 'Primer afegeix ingredients al rebost';

  @override
  String get addDishAllAdded => 'Ja has afegit tots els ingredients del rebost';

  @override
  String get addDishAtLeastOne => 'Afegeix almenys un ingredient';

  @override
  String addDishStepNumber(int number) {
    return 'Pas $number';
  }

  @override
  String get addDishStepDescription => 'Descripció del pas';

  @override
  String get addDishStepHint => 'Ex: Talla les verdures en daus petits';

  @override
  String addDishFirstInGroup(String group) {
    return 'Primer ingredient del grup $group';
  }

  @override
  String addDishAlternatives(String names) {
    return 'Alternatives: $names';
  }

  @override
  String get typeLabel => 'Tipus';

  @override
  String get typeRequired => 'Obligatori';

  @override
  String get typeOptional => 'Opcional';

  @override
  String get typeAlternative => 'Alternativa';

  @override
  String get typeIngredientLabel => 'Tipus d\'ingredient';

  @override
  String get typeRequiredDesc => 'Cal tenir-lo per fer el plat';

  @override
  String get typeOptionalDesc => 'Es pot afegir si el tens';

  @override
  String get typeAlternativeDesc => 'Intercanviable amb altres del grup';

  @override
  String get typeGroup => 'Grup: ';

  @override
  String get name => 'Nom';

  @override
  String get quantity => 'Quantitat';

  @override
  String get unit => 'Unitat';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get save => 'Desar';

  @override
  String get add => 'Afegir';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Tancar';

  @override
  String get ok => 'Entès';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get unitUnitats => 'unitats';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitCullerada => 'cullerada';

  @override
  String get unitCulleradeta => 'culleradeta';

  @override
  String get unitTassa => 'tassa';

  @override
  String get unitPessic => 'pessic';

  @override
  String get difficultyEasy => 'Fàcil';

  @override
  String get difficultyMedium => 'Mitjà';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get healthLevelHealthy => 'Saludable';

  @override
  String get healthLevelNormal => 'Normal';

  @override
  String get healthLevelUnhealthy => 'Poc saludable';

  @override
  String get pantryTitle => 'Rebost';

  @override
  String get pantrySearchHint => 'Cercar ingredient...';

  @override
  String get pantryAddButton => 'Afegir';

  @override
  String get pantryEmpty => 'El rebost està buit';

  @override
  String get pantryNoResults => 'No s\'han trobat ingredients';

  @override
  String get pantryAddIngredients => 'Afegeix ingredients!';

  @override
  String pantryExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count ingredient$_temp0 a punt de caducar';
  }

  @override
  String get pantryAddTitle => 'Afegir ingredient al rebost';

  @override
  String pantryEditTitle(String name) {
    return 'Editar $name';
  }

  @override
  String get pantryExpiry => 'Caducitat';

  @override
  String get pantryExpiryDate => 'Data de caducitat';

  @override
  String get pantryNoDate => 'Sense data';

  @override
  String pantryExpiredDaysAgo(int days) {
    return 'Caducat fa $days dies';
  }

  @override
  String get pantryExpiresToday => 'Caduca avui!';

  @override
  String get pantryExpiresTomorrow => 'Caduca demà';

  @override
  String pantryExpiresInDays(int days) {
    return 'Caduca en $days dies';
  }

  @override
  String pantryExpiresOn(String date) {
    return 'Caduca: $date';
  }

  @override
  String get pantryCannotDelete => 'No es pot eliminar';

  @override
  String pantryUsedIn(String name) {
    return 'L\'ingredient \"$name\" s\'utilitza en:';
  }

  @override
  String get pantryDishesLabel => 'Plats:';

  @override
  String get pantryShoppingLabel => 'Llista de la compra:';

  @override
  String get pantryDeleteFirst =>
      'Elimina primer aquests elements per poder eliminar l\'ingredient.';

  @override
  String get pantryUnderstood => 'Entès';

  @override
  String get pantryDeleteTitle => 'Eliminar ingredient';

  @override
  String pantryDeleteConfirm(String name) {
    return 'Segur que vols eliminar \"$name\"?';
  }

  @override
  String get scanTitle => 'Escanejar ticket';

  @override
  String get scanAddToPantry => 'Afegir al rebost';

  @override
  String get scanChangeImage => 'Canviar imatge';

  @override
  String get scanAnalyzing => 'Analitzant ticket...';

  @override
  String get scanRetry => 'Tornar a intentar';

  @override
  String get scanTakePhoto => 'Fes una foto del ticket de compra';

  @override
  String get scanNoIngredients => 'No s\'han trobat ingredients';

  @override
  String scanDetected(int count) {
    return 'Ingredients detectats ($count)';
  }

  @override
  String scanUncertain(int count) {
    return '$count amb dubtes';
  }

  @override
  String get scanSelectAll => 'Seleccionar tot';

  @override
  String get scanDeselectAll => 'Desseleccionar tot';

  @override
  String get scanDeselectUncertain => 'Desseleccionar dubtosos';

  @override
  String scanRemoveUncertain(int count) {
    return 'Eliminar $count dubtosos';
  }

  @override
  String get scanSelectAtLeastOne => 'Selecciona almenys un ingredient';

  @override
  String scanAddedSuccess(int count) {
    return '$count ingredients afegits al rebost!';
  }

  @override
  String get scanNewIngredient => 'Nou ingredient';

  @override
  String get scanEditIngredient => 'Editar ingredient';

  @override
  String get scanLinkIngredient => 'Vincular ingredient';

  @override
  String scanDetectedLabel(String name) {
    return 'Detectat: \"$name\"';
  }

  @override
  String get scanSearchPantry => 'Cercar al rebost...';

  @override
  String get scanCreateAsNew => 'Crear com a nou';

  @override
  String scanAddNameToPantry(String name) {
    return 'Afegir \"$name\" al rebost';
  }

  @override
  String get scanNoPantryIngredients => 'No hi ha ingredients al rebost';

  @override
  String scanTicketLabel(String text) {
    return 'Ticket: \"$text\"';
  }

  @override
  String get suggestionsTitle => 'Què cuino?';

  @override
  String get suggestionsSurprise => 'Sorpresa!';

  @override
  String get suggestionsHaveAll => 'Ho tinc tot';

  @override
  String suggestionsMaxMinutes(int minutes) {
    return '≤ $minutes min';
  }

  @override
  String suggestionsInPantry(int count) {
    return '$count ingredients al rebost';
  }

  @override
  String get suggestionsNoDishes => 'No tens cap plat creat';

  @override
  String get suggestionsNoMatch => 'No hi ha plats amb aquests filtres';

  @override
  String get suggestionsCreateFirst => 'Crear primer plat';

  @override
  String get suggestionsNoDishesCreated => 'No tens cap plat creat';

  @override
  String get suggestionsNoFilterMatch => 'No hi ha plats amb aquests filtres';

  @override
  String get suggestionsTodayCook => 'Avui cuines...';

  @override
  String get suggestionsViewRecipe => 'Veure recepta';

  @override
  String get shoppingTitle => 'Llista de la compra';

  @override
  String get shoppingAddButton => 'Afegir';

  @override
  String get shoppingEmpty => 'La llista de la compra està buida';

  @override
  String get shoppingAddWhat => 'Afegeix el que necessites comprar!';

  @override
  String get shoppingToBuy => 'Per comprar';

  @override
  String get shoppingBought => 'Comprats';

  @override
  String get shoppingToPantry => 'Al rebost';

  @override
  String get shoppingTransferTitle => 'Transferir al rebost';

  @override
  String get shoppingTransferToPantry => 'Transferir al rebost';

  @override
  String get shoppingTransferBody =>
      'Els articles marcats es mouran al rebost. Si ja existeixen, s\'afegirà la quantitat.';

  @override
  String get shoppingTransfer => 'Transferir';

  @override
  String get shoppingTransferSuccess => 'Articles transferits al rebost';

  @override
  String get shoppingDeleteChecked => 'Eliminar marcats';

  @override
  String get shoppingAddToList => 'Afegir a la llista';

  @override
  String get shoppingNewIngredient => 'Crear nou ingredient';

  @override
  String get shoppingAddToPantryAndList => 'Afegir al rebost i a la llista';

  @override
  String get shoppingNoPantryIngredients => 'No tens ingredients al rebost';

  @override
  String get shoppingNoIngredientsFound => 'No s\'han trobat ingredients';

  @override
  String shoppingInPantry(String text) {
    return 'Al rebost: $text';
  }

  @override
  String notificationExpiresTitle(String name) {
    return '⚠️ $name caduca avui!';
  }

  @override
  String get notificationExpiresBody => 'Utilitza\'l abans que caduqui!';

  @override
  String get notificationChannelName => 'Caducitat d\'ingredients';

  @override
  String get notificationChannelDesc =>
      'Notificacions de caducitat d\'ingredients';

  @override
  String get notificationTestTitle => '🧪 Test de notificació';

  @override
  String get notificationTestBody =>
      'Les notificacions funcionen correctament!';
}
