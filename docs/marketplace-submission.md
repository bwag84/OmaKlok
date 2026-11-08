# Voorbereide marketplace-inzending

Status: **concept — nog niet ingediend. Toestemming van Bart is nodig voordat deze tekst extern wordt geplaatst.**

Repository: https://github.com/bwag84/OmaKlok

Naam: OmaKlok

Categorie: Kids

Tags: Education, Kids, Launcher

## Beschrijving voor de inzending

OmaKlok helpt Nederlandse kinderen van 5–10 jaar klokkijken oefenen met een analoge klok, digitale antwoordkeuzes en zelf verplaatsbare wijzers. Vijf niveaus lopen van hele/halve uren tot losse minuten en herkenbare tijdverhalen. Nederlandse hulp, bediening met muis en toetsenbord, instelbaar aantal antwoorden en verwisselbare kanten. De native Qt Quick-app volgt het Omarchy-thema live en werkt volledig offline.

De shellplugin opent de desktopapp via een balkknop of panel summon. **De native OmaKlok-app moet vooraf worden geïnstalleerd** met de gedocumenteerde Arch-pakket- of gebruikersinstallatie. De plugin start geen installatie of build en meldt een ontbrekende binary.

Manifest: `manifest.json`, id `bwag84.omaklok`, schema 1, kinds `bar-widget` en `panel`.

Preview: `docs/screenshot.png`

Licentie: MIT

Netwerk/data: de app gebruikt geen netwerk. Alleen oefenvoorkeuren worden lokaal in QSettings bewaard. Geen kindprofielen of opgeslagen antwoorden.

## Procedure

1. Bouw en test met `bin/build`, `bin/test` en `omarchy plugin validate .`.
2. Publiceer de broncode, tag en release op de eigen GitHub-repository.
3. Vraag de eigenaar expliciet toestemming om de marketplace-inzending te plaatsen.
4. Gebruik na toestemming het actuele formulier vanaf https://plugins.omarchy.org/publish.html. De maintainer beslist over opname.

Officiële instructies: https://plugins.omarchy.org/publish.html en https://omarchy.org/manual/shell-plugins/.
