# DreamVoyager Frontend – Einrichtung auf einem neuen Laptop (Deutsch)

## 1) Projekt klonen

```powershell
git clone <REPO_URL>
cd DreamVoyager\DreamVoyagerFrontend\dream_voyager_frontend
```

`<REPO_URL>` durch die echte Repository-URL ersetzen.

## 2) Abhängigkeiten installieren

```powershell
flutter pub get
```

## 3) Backend starten (wichtig)

Die App erwartet eine API auf Port `3000`.

- Android Emulator nutzt: `http://10.0.2.2:3000/api`
- Desktop/Web nutzt: `http://localhost:3000/api`

Das heißt: Beim Emulator muss das Backend lokal auf dem Laptop laufen.

## 4) Emulator starten

- In Android Studio den Device Manager öffnen
- Emulator starten (am besten ein Pixel mit Google Play Image)

Geräte prüfen:

```powershell
flutter devices
```

## 5) App starten

```powershell
flutter run -d emulator-5554
```

Wenn deine Emulator-ID anders ist, entsprechend ersetzen.

## 6) Speech-to-Text / Mikrofon Troubleshooting

Wenn Spracheingabe nicht funktioniert:

1. Mikrofonzugriff im Emulator aktivieren
2. Google-App im Emulator einmal öffnen und Mikrofon erlauben
3. Prüfen, ob Spracheingabe in der Google-App selbst funktioniert
4. Emulator bei Bedarf per "Cold Boot" neu starten
