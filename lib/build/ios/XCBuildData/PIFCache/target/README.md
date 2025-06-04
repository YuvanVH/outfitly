Du behöver **inte** manuellt rensa dessa target-filer.
De är tillfälliga och hanteras automatiskt av Xcode/Flutter.

Vill du rensa dem (t.ex. om du har byggproblem eller vill frigöra utrymme), kör bara:

```sh
flutter clean
```

Detta tar bort alla genererade byggfiler, inklusive dessa targets, och bygger om dem nästa gång du kör eller bygger projektet.
