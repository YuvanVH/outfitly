# Outfitly

## Examensarbete 2025

### Struktur

lib/
├── models/          # Data-modeller och logik för att hantera data (t.ex. wardrobeItems, users)
├── screens/         # Alla skärmar i appen (t.ex. HomeScreen, LoginScreen)
│   ├── login/       # Undermapp för inloggningsrelaterade skärmar
│   ├── wardrobe/    # Undermapp för garderobsrelaterade skärmar
├── widgets/         # Återanvändbara widgets (t.ex. knappar, formulär)
├── router/          # Appens routing-konfiguration (t.ex. GoRouter)
├── services/        # Abstraktion för Firebase-tjänster (t.ex. autentisering, Firestore)
├── utils/           # Hjälpfunktioner, konstanter eller teman
├── main.dart        # Huvudfilen som startar appen

---

### Förklaring av mappar

models/
Här lägger man data-modeller och logik för att hantera data. T.ex. addWardrobeItem.dart kan flyttas hit. Om man har fler funktioner för att hantera garderobsdata, kan du skapa en fil som wardrobe_model.dart.

screens/
Alla skärmar i appen organiseras här. Du kan skapa undermappar för specifika funktioner, som login/ för inloggning och wardrobe/ för garderobsrelaterade skärmar.

widgets/
Återanvändbara UI-komponenter som knappar, kort eller formulärfält. T.ex. om du har en widget för att visa garderobsobjekt, kan du skapa en fil wardrobe_item_card.dart här.

router/
Här lägger du routing-logik, som din app_router.dart.

services/
Här kan du abstrahera Firebase-tjänster. T.ex. skapa en fil auth_service.dart för autentisering och firestore_service.dart för Firestore-logik. Detta gör att din kod blir mer modulär och lättare att underhålla.

utils/
Hjälpfunktioner, konstanter eller teman. T.ex. om du har färgteman eller globala konstanter, kan du skapa en fil theme.dart eller constants.dart.

---

## Firebase-setup

- `firebase_options.dart` genereras med `flutterfire configure` och ska **inte ändras manuellt**.
- Emulatorer används endast i debug-läge och med host `127.0.0.1`.
- CORS för Storage är satt för både localhost och hosting-URL i `cors.json`.

### Viktiga kodmönster

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

### Temahantering

- Temat sparas i SharedPreferences och kan växlas mellan ljus/mörk.

### CORS

- `cors.json` innehåller både localhost och hosting-URL för utveckling och produktion.

### Tips

- Om du får "Firebase initialization failed" – kontrollera att du inte använder emulatorer i production och att `firebase_options.dart` är korrekt.
- För bildvisning på web, använd aldrig Storage-emulatorn.

---
