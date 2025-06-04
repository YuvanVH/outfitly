# Outfitly

Outfitly är en Flutter-app för garderobshantering med Firebase-integration.

## Struktur

```
lib/
├── models/          # Data-modeller (t.ex. wardrobe_item.dart)
├── screens/         # Alla skärmar (login, wardrobe, user, etc)
│   ├── wardrobe/widgets/  # Återanvändbara wardrobe-widgets
│   ├── user/widgets/      # Återanvändbara user-widgets
├── widgets/         # Globala återanvändbara widgets
├── services/        # Firebase-tjänster (auth_service.dart, wardrobe_service.dart)
├── constants/       # Konstanter (wardrobe_constants.dart)
├── themes/          # Teman (light_mode.dart, dark_mode.dart)
├── router/          # Routing (app_router.dart)
├── firebase_options.dart  # Autogenererad av flutterfire configure
├── main.dart        # Appens entrypoint
```

## Firebase-setup

- `firebase_options.dart` genereras med `flutterfire configure` och ska **inte ändras manuellt**.
- Emulatorer används endast i debug-läge och med host `127.0.0.1`.
- CORS för Storage är satt för både localhost och hosting-URL i `cors.json`.

## Viktiga kodmönster

- **Firebase initieras i main.dart** med:
  ```dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ```
- **Emulatorer används endast i debug:**
  ```dart
  if (kDebugMode) {
    FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }
  ```
- **Splash och login fungerar direkt efter runApp.**
- **Ingen onödig väntan på authStateChanges innan runApp.**

## Temahantering

- Temat sparas i SharedPreferences och kan växlas mellan ljus/mörk.

## CORS

- `cors.json` innehåller både localhost och hosting-URL för utveckling och produktion.

## Tips

- Om du får "Firebase initialization failed" – kontrollera att du inte använder emulatorer i production och att `firebase_options.dart` är korrekt.
- För bildvisning på web, använd aldrig Storage-emulatorn.

Tips:
Om du får `zsh: command not found: gsutil` betyder det att Google Cloud SDK (och gsutil) inte är installerat eller inte finns i din PATH.

**Så här installerar du gsutil:**

1. Installera Google Cloud SDK:
   https://cloud.google.com/sdk/docs/install

2. Efter installation, kör:
   ```sh
   gcloud auth login
   gcloud config set project outfitly-app
   ```

3. Nu kan du använda:
   ```sh
   gsutil cors set cors.json gs://outfitly-app.firebasestorage.app
   ```

För att öppna build/web/index.html i webbläsaren:

1. Bygg projektet för web:
   ```sh
   flutter build web
   ```

2. Öppna filen i webbläsaren:
   - Gå till mappen: `/Users/vanessa/Desktop/LIA_Examensarbete_PM/Examensarbete/outfitly/build/web/`
   - Dubbelklicka på `index.html`
     **eller**
     öppna terminalen och kör:
   ```sh
   open build/web/index.html
   ```
   (På Windows: `start build/web/index.html`)

**Obs:**
Vissa funktioner (t.ex. Firebase Auth) fungerar inte fullt ut om du bara öppnar filen direkt (file://).

**Enklare sätt:**
Kör istället:
```sh
flutter run -d chrome --release
```
Då startar Flutter en lokal server och öppnar appen i webbläsaren – ingen extra Python-server behövs!

För manuella tester av build-mappen kan du fortfarande använda:
```sh
cd build/web
python3 -m http.server 8080
```
och besök `http://localhost:8080` i webbläsaren.
