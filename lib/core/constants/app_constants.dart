import 'package:flutter/material.dart';
import 'package:xup_xup/l10n/app_localizations.dart';

class AppConstants {
  static const String appName = 'Xup-Xup';
  
  static const List<String> difficultyKeys = [
    'easy',
    'medium',
    'hard',
  ];

  static String normalizeDifficultyKey(String value) {
    switch (value) {
      case 'Fàcil':
        return 'easy';
      case 'Mitjà':
        return 'medium';
      case 'Difícil':
        return 'hard';
      default:
        return difficultyKeys.contains(value) ? value : 'medium';
    }
  }

  static String localizedDifficulty(BuildContext context, String key) {
    final normalized = normalizeDifficultyKey(key);
    final l10n = AppLocalizations.of(context)!;
    switch (normalized) {
      case 'easy':
        return l10n.difficultyEasy;
      case 'medium':
        return l10n.difficultyMedium;
      case 'hard':
        return l10n.difficultyHard;
      default:
        return key;
    }
  }
  
  static const List<String> unitKeys = [
    'unitats',
    'g',
    'kg',
    'ml',
    'l',
    'cullerada',
    'culleradeta',
    'tassa',
    'pessic',
  ];

  static String localizedUnit(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'unitats':
        return l10n.unitUnitats;
      case 'g':
        return l10n.unitG;
      case 'kg':
        return l10n.unitKg;
      case 'ml':
        return l10n.unitMl;
      case 'l':
        return l10n.unitL;
      case 'cullerada':
        return l10n.unitCullerada;
      case 'culleradeta':
        return l10n.unitCulleradeta;
      case 'tassa':
        return l10n.unitTassa;
      case 'pessic':
        return l10n.unitPessic;
      default:
        return key;
    }
  }
}

class UnitConverter {
  static double toBaseUnit(double quantity, String unit) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return quantity * 1000;
      case 'g':
        return quantity;
      case 'l':
        return quantity * 1000;
      case 'ml':
        return quantity;
      default:
        return quantity;
    }
  }

  static String getBaseUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'kg':
      case 'g':
        return 'g';
      case 'l':
      case 'ml':
        return 'ml';
      default:
        return unit;
    }
  }

  static bool areCompatible(String unit1, String unit2) {
    return getBaseUnit(unit1) == getBaseUnit(unit2);
  }

  static double convert(double quantity, String fromUnit, String toUnit) {
    if (!areCompatible(fromUnit, toUnit)) {
      return quantity;
    }
    final base = toBaseUnit(quantity, fromUnit);
    switch (toUnit.toLowerCase()) {
      case 'kg':
        return base / 1000;
      case 'g':
        return base;
      case 'l':
        return base / 1000;
      case 'ml':
        return base;
      default:
        return quantity;
    }
  }
}
