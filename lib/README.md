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

# Best practice: När ska man köra `firebase emulators:start --only ...`?

## När du ska använda Firebase Emulatorer

Kör `firebase emulators:start --only auth,firestore,storage` när du:

- **Utvecklar lokalt** och vill testa utan att påverka riktiga data i Firebase.
- Vill kunna skapa, ändra och ta bort användare och data utan risk.
- Vill testa säkerhetsregler (rules) för Firestore/Auth/Storage.
- Vill utveckla/testa offline eller utan internet.
- Vill undvika onödiga kostnader och kvotproblem i ditt riktiga Firebase-projekt.

---

## När du INTE ska använda emulatorerna

- När du vill testa mot **riktig produktion** (t.ex. bildvisning på web kräver riktig Storage).
- När du ska deploya till hosting eller visa appen för riktiga användare.
- När du behöver riktiga push-notiser, analytics, eller andra tjänster som inte stöds av emulatorn.

---

## Typisk utvecklingsrutin

1. **Starta emulatorerna:**
   ```sh
   firebase emulators:start --only auth,firestore,storage
   ```
2. **Kör din Flutter-app i debug-läge:**
   ```sh
   flutter run -d chrome
   ```
   eller
   ```sh
   flutter run
   ```
3. **Byt till riktiga Firebase (ta bort emulator-kod) när du:**
   - Ska testa bildvisning på web.
   - Ska deploya till hosting.
   - Vill testa mot riktiga användare/data.

---

## Tips

- **Emulatorer är bäst för utveckling och test.**
- **Riktig Firebase är bäst för produktion och web hosting.**
- Du kan alltid växla mellan emulator och riktig backend genom att använda `kDebugMode` i din kod.

---

## Spara pengar på Firebase (Blaze-planen)

1. **Komprimera bilder vid uppladdning**
   ```dart
   final pickedFile = await ImagePicker().pickImage(
     source: ImageSource.gallery,
     maxWidth: 800,
     maxHeight: 800,
     imageQuality: 70, // ~100–500 KB/bild
   );
   ```
   - Minskar lagrings- och nedladdningskostnad.

2. **Komprimera ytterligare med flutter_image_compress**
   ```dart
   import 'package:flutter_image_compress/flutter_image_compress.dart';

   Future<File> compressImage(File file) async {
     final compressedFile = await FlutterImageCompress.compressAndGetFile(
       file.path,
       file.path + '_compressed.jpg',
       quality: 70,
       minWidth: 800,
       minHeight: 800,
     );
     return File(compressedFile!.path);
   }
   ```
   - Använd före uppladdning till Storage.

3. **Cacha bilder i appen**
   ```dart
   import 'package:cached_network_image/cached_network_image.dart';

   CachedNetworkImage(
     imageUrl: 'https://your-storage-url/image.jpg',
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => Icon(Icons.error),
   );
   ```
   - Minskar antalet nedladdningar från Storage.

4. **Lazy loading av bilder**
   ```dart
   ListView.builder(
     itemCount: clothes.length,
     itemBuilder: (context, index) {
       return CachedNetworkImage(imageUrl: clothes[index].imageUrl);
     },
   );
   ```
   - Laddar bara bilder som syns på skärmen.

5. **Minimera Firestore-anrop**
   - Använd `.get()` istället för realtidslyssnare om du inte behöver live-uppdateringar:
     ```dart
     final query = FirebaseFirestore.instance.collection('clothes').limit(50);
     final snapshot = await query.get();
     ```

6. **Övervaka och sätt budgetvarningar**
   - Kolla användning i Firebase Console (Storage > Usage, Hosting > Usage).
   - Sätt budgetvarningar i Google Cloud Console (t.ex. $5/månad).

---

**Resultat:**
- Lagring och trafik hålls under gratisgränserna.
- Appen känns snabbare och billigare att drifta.

---

## Starta alla emulatorer (Auth, Firestore, Storage)

Kör detta kommando för att starta alla tre emulatorer samtidigt:

```sh
firebase emulators:start --only auth,firestore,storage
```

- **auth** = Firebase Authentication (testa inloggning, dummy users)
- **firestore** = Firestore-databasen (testa data utan att påverka produktion)
- **storage** = Firebase Storage (testa filuppladdning/visning lokalt)

Du kan nu utveckla och testa hela appen lokalt utan att använda riktiga Firebase-resurser.

---
