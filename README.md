# Xup-Xup

App de cuina per gestionar plats, ingredients i llista de la compra.

## Funcionalitats

- **Què cuino?**: Veu quins plats pots fer amb els ingredients disponibles al rebost, amb indicador de completitud i selecció aleatòria ("Sorpresa!").
- **Els meus plats**: Crea i gestiona receptes amb foto, ingredients, temps de preparació, dificultat i passos.
- **Rebost**: Gestiona els ingredients que tens disponibles amb quantitats i unitats.
- **Llista de la compra**: Afegeix el que necessites comprar i transfereix-ho al rebost quan ho hagis comprat.

## Tecnologies

- **Flutter** (Dart)
- **Firebase**:
  - Firebase Auth (autenticació amb email i Google)
  - Cloud Firestore (base de dades)
  - Firebase Storage (emmagatzematge de fotos)
- **Riverpod** (gestió d'estat)
- **GoRouter** (navegació)

## Configuració inicial

### 1. Prerequisits

- Flutter SDK instal·lat
- Compte de Firebase

### 2. Configurar Firebase

1. Crea un projecte a [Firebase Console](https://console.firebase.google.com/)

2. Activa els següents serveis:
   - Authentication (Email/Password i Google Sign-In)
   - Cloud Firestore
   - Storage

3. Instal·la FlutterFire CLI si no ho has fet:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. Configura Firebase al projecte:
   ```bash
   flutterfire configure
   ```
   Això generarà automàticament el fitxer `lib/firebase_options.dart`.

### 3. Configurar Google Sign-In (Android)

1. A Firebase Console, ves a Project Settings > General
2. Afegeix l'empremta SHA-1 del teu certificat de depuració:
   ```bash
   cd android && ./gradlew signingReport
   ```
3. Descarrega el fitxer `google-services.json` actualitzat i posa'l a `android/app/`

### 4. Configurar Google Sign-In (iOS)

1. A Firebase Console, descarrega `GoogleService-Info.plist`
2. Afegeix-lo a `ios/Runner/` via Xcode
3. Afegeix al fitxer `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>REVERSED_CLIENT_ID_FROM_GOOGLESERVICE_INFO_PLIST</string>
       </array>
     </dict>
   </array>
   ```

### 5. Regles de seguretat de Firestore

A Firebase Console > Firestore > Rules, configura les regles:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /dishes/{dishId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
    match /ingredients/{ingredientId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
    match /shopping_items/{itemId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 6. Regles de Storage

A Firebase Console > Storage > Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /dishes/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Executar l'app

```bash
flutter pub get
flutter run
```

## Estructura del projecte

```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   └── theme/
├── features/
│   ├── auth/
│   ├── dishes/
│   ├── pantry/
│   ├── shopping/
│   └── suggestions/
├── router/
└── shared/
    ├── models/
    ├── repositories/
    └── widgets/
```

## Llicència

Aquest projecte és privat i per a ús personal.
