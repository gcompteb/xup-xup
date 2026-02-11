// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'xup-xup';

  @override
  String get appSlogan => 'Sabe qué cocinar';

  @override
  String get navSuggestions => '¿Qué cocino?';

  @override
  String get navDishes => 'Mis platos';

  @override
  String get navPantry => 'Despensa';

  @override
  String get navShopping => 'Compra';

  @override
  String get loginWelcomeBack => 'Bienvenido/a';

  @override
  String get loginSignInContinue => 'Inicia sesión para continuar';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginEmailHint => 'tu@email.com';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginSignIn => 'Iniciar sesión';

  @override
  String get loginOr => 'o';

  @override
  String get loginContinueGoogle => 'Continuar con Google';

  @override
  String get loginNoAccount => '¿No tienes cuenta? ';

  @override
  String get loginSignUp => 'Registrarse';

  @override
  String get loginValidateEmailEmpty => 'Introduce tu correo';

  @override
  String get loginValidateEmailInvalid => 'Introduce un correo válido';

  @override
  String get loginValidatePasswordEmpty => 'Introduce tu contraseña';

  @override
  String get loginValidatePasswordShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get registerJoin => 'Únete a xup-xup';

  @override
  String get registerCreateAccount => 'Crea tu cuenta';

  @override
  String get registerFullName => 'Nombre completo';

  @override
  String get registerFullNameHint => 'Juan García';

  @override
  String get registerConfirmPassword => 'Confirmar contraseña';

  @override
  String get registerPasswordHelper => 'Mínimo 6 caracteres';

  @override
  String get registerCreateButton => 'Crear cuenta';

  @override
  String get registerSignUpGoogle => 'Registrarse con Google';

  @override
  String get registerAlreadyAccount => '¿Ya tienes una cuenta? ';

  @override
  String get registerValidateNameEmpty => 'Introduce tu nombre';

  @override
  String get registerValidatePasswordEmpty => 'Introduce una contraseña';

  @override
  String get registerValidateConfirmEmpty => 'Confirma tu contraseña';

  @override
  String get registerValidatePasswordMatch => 'Las contraseñas no coinciden';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get somethingWentWrong => 'Algo ha ido mal';

  @override
  String get retry => 'Reintentar';

  @override
  String get dishesTitle => 'Mis platos';

  @override
  String get dishesSearchHint => 'Buscar plato...';

  @override
  String get dishesNewDish => 'Nuevo plato';

  @override
  String get dishesFilterFavorites => 'Filtrar favoritos';

  @override
  String dishesNoMatch(String query) {
    return 'Ningún plato coincide con \"$query\"';
  }

  @override
  String get dishesEmpty => 'No tienes ningún plato aún';

  @override
  String get dishesEmptyFilter => 'No hay platos con este filtro';

  @override
  String get dishesAddFirst => '¡Añade tu primer plato!';

  @override
  String get dishesRemoveFav => 'Quitar';

  @override
  String get dishesFavorite => 'Favorito';

  @override
  String get dishesDelete => 'Eliminar';

  @override
  String get dishesDeleteTitle => 'Eliminar plato';

  @override
  String dishesDeleteConfirm(String name) {
    return '¿Seguro que quieres eliminar \"$name\"?';
  }

  @override
  String dishesIngCount(int count) {
    return '$count ing.';
  }

  @override
  String get dishNotFound => 'Plato no encontrado';

  @override
  String get dishIngredients => 'Ingredientes';

  @override
  String get dishSteps => 'Pasos';

  @override
  String get dishEdit => 'Editar';

  @override
  String get dishCooked => '¡Cocinado!';

  @override
  String dishPersons(int count) {
    return '$count pers.';
  }

  @override
  String get dishAlternativesNeed1 => 'Alternativas (necesita 1)';

  @override
  String get dishOptionals => 'Opcionales';

  @override
  String get dishMarkCooked => 'Marcar como cocinado';

  @override
  String get dishServings => 'Porciones: ';

  @override
  String dishRecipeServingsChange(int original, int current) {
    return 'Receta: $original porc. → Cocinas: $current porc.';
  }

  @override
  String get dishRequired => 'Obligatorios:';

  @override
  String get dishAlternativesMin1 => 'Alternativas (mínimo 1):';

  @override
  String get dishOptionalsLabel => 'Opcionales:';

  @override
  String dishCookedSuccess(String name, int servings) {
    return '$name cocinado para $servings! Ingredientes actualizados.';
  }

  @override
  String get dishMissingIngredients => 'Faltan ingredientes';

  @override
  String get addDishTitle => 'Nuevo plato';

  @override
  String get editDishTitle => 'Editar plato';

  @override
  String get addDishSave => 'Guardar';

  @override
  String get addDishCamera => 'Cámara';

  @override
  String get addDishGallery => 'Galería';

  @override
  String get addDishAddPhoto => 'Añadir foto';

  @override
  String get addDishName => 'Nombre del plato';

  @override
  String get addDishValidateName => 'Introduce el nombre del plato';

  @override
  String get addDishDifficulty => 'Dificultad';

  @override
  String get addDishTime => 'Tiempo (min)';

  @override
  String get addDishServings => 'Porciones';

  @override
  String get addDishHealthy => 'Saludable';

  @override
  String get addDishIngredients => 'Ingredientes';

  @override
  String get addDishAdd => 'Añadir';

  @override
  String get addDishNoIngredients => 'Ningún ingrediente añadido';

  @override
  String get addDishSteps => 'Pasos (opcional)';

  @override
  String get addDishNoSteps => 'Ningún paso añadido';

  @override
  String get addDishSelectIngredient => 'Seleccionar ingrediente';

  @override
  String get addDishCreateNew => 'Crear nuevo ingrediente';

  @override
  String get addDishAddToPantry => 'Añadir a la despensa';

  @override
  String get addDishNewIngredient => 'Nuevo ingrediente';

  @override
  String get addDishCreateAndAdd => 'Crear y añadir';

  @override
  String get addDishSearch => 'Buscar...';

  @override
  String get addDishNoPantryIngredients =>
      'No tienes ingredientes en la despensa';

  @override
  String get addDishNoIngredientsFound => 'No se han encontrado ingredientes';

  @override
  String addDishAvailable(String text) {
    return 'Disponible: $text';
  }

  @override
  String addDishPantryAvailable(String text) {
    return 'Disponible en despensa: $text';
  }

  @override
  String get addDishFirstAddPantry =>
      'Primero añade ingredientes a la despensa';

  @override
  String get addDishAllAdded =>
      'Ya has añadido todos los ingredientes de la despensa';

  @override
  String get addDishAtLeastOne => 'Añade al menos un ingrediente';

  @override
  String addDishStepNumber(int number) {
    return 'Paso $number';
  }

  @override
  String get addDishStepDescription => 'Descripción del paso';

  @override
  String get addDishStepHint => 'Ej: Corta las verduras en dados pequeños';

  @override
  String addDishFirstInGroup(String group) {
    return 'Primer ingrediente del grupo $group';
  }

  @override
  String addDishAlternatives(String names) {
    return 'Alternativas: $names';
  }

  @override
  String get typeLabel => 'Tipo';

  @override
  String get typeRequired => 'Obligatorio';

  @override
  String get typeOptional => 'Opcional';

  @override
  String get typeAlternative => 'Alternativa';

  @override
  String get typeIngredientLabel => 'Tipo de ingrediente';

  @override
  String get typeRequiredDesc => 'Necesario para hacer el plato';

  @override
  String get typeOptionalDesc => 'Se puede añadir si lo tienes';

  @override
  String get typeAlternativeDesc => 'Intercambiable con otros del grupo';

  @override
  String get typeGroup => 'Grupo: ';

  @override
  String get name => 'Nombre';

  @override
  String get quantity => 'Cantidad';

  @override
  String get unit => 'Unidad';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get add => 'Añadir';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Cerrar';

  @override
  String get ok => 'Entendido';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get unitUnitats => 'unidades';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitCullerada => 'cucharada';

  @override
  String get unitCulleradeta => 'cucharadita';

  @override
  String get unitTassa => 'taza';

  @override
  String get unitPessic => 'pizca';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get healthLevelHealthy => 'Saludable';

  @override
  String get healthLevelNormal => 'Normal';

  @override
  String get healthLevelUnhealthy => 'Poco saludable';

  @override
  String get pantryTitle => 'Despensa';

  @override
  String get pantrySearchHint => 'Buscar ingrediente...';

  @override
  String get pantryAddButton => 'Añadir';

  @override
  String get pantryEmpty => 'La despensa está vacía';

  @override
  String get pantryNoResults => 'No se han encontrado ingredientes';

  @override
  String get pantryAddIngredients => '¡Añade ingredientes!';

  @override
  String pantryExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count ingrediente$_temp0 a punto de caducar';
  }

  @override
  String get pantryAddTitle => 'Añadir ingrediente a la despensa';

  @override
  String pantryEditTitle(String name) {
    return 'Editar $name';
  }

  @override
  String get pantryExpiry => 'Caducidad';

  @override
  String get pantryExpiryDate => 'Fecha de caducidad';

  @override
  String get pantryNoDate => 'Sin fecha';

  @override
  String pantryExpiredDaysAgo(int days) {
    return 'Caducado hace $days días';
  }

  @override
  String get pantryExpiresToday => '¡Caduca hoy!';

  @override
  String get pantryExpiresTomorrow => 'Caduca mañana';

  @override
  String pantryExpiresInDays(int days) {
    return 'Caduca en $days días';
  }

  @override
  String pantryExpiresOn(String date) {
    return 'Caduca: $date';
  }

  @override
  String get pantryCannotDelete => 'No se puede eliminar';

  @override
  String pantryUsedIn(String name) {
    return 'El ingrediente \"$name\" se utiliza en:';
  }

  @override
  String get pantryDishesLabel => 'Platos:';

  @override
  String get pantryShoppingLabel => 'Lista de la compra:';

  @override
  String get pantryDeleteFirst =>
      'Elimina primero estos elementos para poder eliminar el ingrediente.';

  @override
  String get pantryUnderstood => 'Entendido';

  @override
  String get pantryDeleteTitle => 'Eliminar ingrediente';

  @override
  String pantryDeleteConfirm(String name) {
    return '¿Seguro que quieres eliminar \"$name\"?';
  }

  @override
  String get scanTitle => 'Escanear ticket';

  @override
  String get scanAddToPantry => 'Añadir a la despensa';

  @override
  String get scanChangeImage => 'Cambiar imagen';

  @override
  String get scanAnalyzing => 'Analizando ticket...';

  @override
  String get scanRetry => 'Volver a intentar';

  @override
  String get scanTakePhoto => 'Haz una foto del ticket de compra';

  @override
  String get scanNoIngredients => 'No se han encontrado ingredientes';

  @override
  String scanDetected(int count) {
    return 'Ingredientes detectados ($count)';
  }

  @override
  String scanUncertain(int count) {
    return '$count con dudas';
  }

  @override
  String get scanSelectAll => 'Seleccionar todo';

  @override
  String get scanDeselectAll => 'Deseleccionar todo';

  @override
  String get scanDeselectUncertain => 'Deseleccionar dudosos';

  @override
  String scanRemoveUncertain(int count) {
    return 'Eliminar $count dudosos';
  }

  @override
  String get scanSelectAtLeastOne => 'Selecciona al menos un ingrediente';

  @override
  String scanAddedSuccess(int count) {
    return '¡$count ingredientes añadidos a la despensa!';
  }

  @override
  String get scanNewIngredient => 'Nuevo ingrediente';

  @override
  String get scanEditIngredient => 'Editar ingrediente';

  @override
  String get scanLinkIngredient => 'Vincular ingrediente';

  @override
  String scanDetectedLabel(String name) {
    return 'Detectado: \"$name\"';
  }

  @override
  String get scanSearchPantry => 'Buscar en despensa...';

  @override
  String get scanCreateAsNew => 'Crear como nuevo';

  @override
  String scanAddNameToPantry(String name) {
    return 'Añadir \"$name\" a la despensa';
  }

  @override
  String get scanNoPantryIngredients => 'No hay ingredientes en la despensa';

  @override
  String scanTicketLabel(String text) {
    return 'Ticket: \"$text\"';
  }

  @override
  String get suggestionsTitle => '¿Qué cocino?';

  @override
  String get suggestionsSurprise => '¡Sorpresa!';

  @override
  String get suggestionsHaveAll => 'Lo tengo todo';

  @override
  String suggestionsMaxMinutes(int minutes) {
    return '≤ $minutes min';
  }

  @override
  String suggestionsInPantry(int count) {
    return '$count ingredientes en la despensa';
  }

  @override
  String get suggestionsNoDishes => 'No tienes ningún plato';

  @override
  String get suggestionsNoMatch => 'No hay platos con estos filtros';

  @override
  String get suggestionsCreateFirst => 'Crear primer plato';

  @override
  String get suggestionsNoDishesCreated => 'No tienes ningún plato creado';

  @override
  String get suggestionsNoFilterMatch => 'No hay platos con estos filtros';

  @override
  String get suggestionsTodayCook => 'Hoy cocinas...';

  @override
  String get suggestionsViewRecipe => 'Ver receta';

  @override
  String get shoppingTitle => 'Lista de la compra';

  @override
  String get shoppingAddButton => 'Añadir';

  @override
  String get shoppingEmpty => 'La lista de la compra está vacía';

  @override
  String get shoppingAddWhat => '¡Añade lo que necesitas comprar!';

  @override
  String get shoppingToBuy => 'Por comprar';

  @override
  String get shoppingBought => 'Comprados';

  @override
  String get shoppingToPantry => 'A la despensa';

  @override
  String get shoppingTransferTitle => 'Transferir a la despensa';

  @override
  String get shoppingTransferToPantry => 'Transferir a la despensa';

  @override
  String get shoppingTransferBody =>
      'Los artículos marcados se moverán a la despensa. Si ya existen, se sumará la cantidad.';

  @override
  String get shoppingTransfer => 'Transferir';

  @override
  String get shoppingTransferSuccess => 'Artículos transferidos a la despensa';

  @override
  String get shoppingDeleteChecked => 'Eliminar marcados';

  @override
  String get shoppingAddToList => 'Añadir a la lista';

  @override
  String get shoppingNewIngredient => 'Crear nuevo ingrediente';

  @override
  String get shoppingAddToPantryAndList => 'Añadir a la despensa y a la lista';

  @override
  String get shoppingNoPantryIngredients =>
      'No tienes ingredientes en la despensa';

  @override
  String get shoppingNoIngredientsFound => 'No se han encontrado ingredientes';

  @override
  String shoppingInPantry(String text) {
    return 'En despensa: $text';
  }

  @override
  String notificationExpiresTitle(String name) {
    return '⚠️ ¡$name caduca hoy!';
  }

  @override
  String get notificationExpiresBody => '¡Úsalo antes de que caduque!';

  @override
  String get notificationChannelName => 'Caducidad de ingredientes';

  @override
  String get notificationChannelDesc =>
      'Notificaciones de caducidad de ingredientes';

  @override
  String get notificationTestTitle => '🧪 Test de notificación';

  @override
  String get notificationTestBody =>
      '¡Las notificaciones funcionan correctamente!';
}
