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

 Anmerkungen Wolf:
 * wie machst Du die Abfrage über mehrere Wörter?
    Willst Du für jedes Wort eine eigene SQL-Abfrage machen?
    --> Ja das war zurzeit der Plan
 * Was machst Du, wenn Wörter an einzelnen Tagen nicht auftauchen?
    Beispiel: 'Goethe'
    Ich glaube, im Moment wird der fehlende Tag einfach übersprungen.
