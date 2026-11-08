# Verificatie van versie 0.1.0

Getest op Omarchy 4.5.0, x86_64, Qt 6.12.0.

- `bin/build`: native app succesvol gebouwd.
- `bin/test`: Qt Test-suite voor Nederlandse tijdtaal, afronding en middernacht, 2.700 gegenereerde oefeningen met unieke antwoordkeuzes op alle niveaus/aantallen, score en opnieuw proberen, wijzerbediening, dagdelen, beide gemengde oefenvormen, themawisselingen en echte QML-interactie.
- QML-interactie: antwoorden met cijfertoetsen, spatie om te controleren en verder te gaan, wijzerkeuze met M/U, pijltjestoetsen, klikken op de klok, alle niveaus en aantallen, omwisselen van kanten, modaliteit van hulp.
- Screenshots van meerkeuze, zelf wijzers zetten, tijdverhalen, hulp en een venster van 800×700 visueel gecontroleerd. Geen QML-waarschuwingen in de suite.
- `omarchy plugin validate .`: manifest geaccepteerd.
- Shell-entrypoint afzonderlijk in Quickshell geladen. Zowel het tonen van de installatiehulp bij een ontbrekende binary als het starten van een vervangende testbinary gecontroleerd. De bestaande desktopconfiguratie is daarvoor niet aangepast.
- `makepkg -f --noconfirm`: Arch-pakket gebouwd.
- `bin/install-user`: binary, launcher en pictogram voor de huidige gebruiker geïnstalleerd.

De Arch-build voor aarch64 en andere Qt-versies zijn niet lokaal getest. Een GitHub Actions-sjabloon staat in `docs/ci-check.yml`. Het beschikbare GitHub-token mist de `workflow`-scope; plaats dit bestand later in `.github/workflows/check.yml` om CI te activeren. De marketplace-inzending is nog niet ingediend.
