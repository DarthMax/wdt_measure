#HOW TO:

  * R starten
  * install.r ausführen falls RMySQL noch nicht installiert ist
  * in pro.r die daten für die SQL Connection eintragen
  * pro.r ausführen diese ließt die Daten ein (aktuell nur für das Wort Haus
  * lin_filt.r ausführen
    * Führt 2x gleitender Mittelwert aus mit 2 unterschiedlichen Fenstern. Es werden nur vergangene Werte beachtet !!!
    * Es wird einmal noch Holt Winters ausgeführt (exponentiale Glättung mit saisonaller Schwankung) Erklrärung folgt

## TODO

 * Doku
 * Werte speichern in der Tabelle
 * Tests auf Wörter des Tages
