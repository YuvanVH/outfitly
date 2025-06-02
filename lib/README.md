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

Förklaring av mappar
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
