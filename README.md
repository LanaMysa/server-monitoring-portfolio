# Monitoring der virtuellen Maschinen

Dieses Projekt beschreibt die Einrichtung eines zentralen Monitorings für mehrere virtuelle Maschinen in einer Praxisumgebung.

## Ziel des Projekts

Das Ziel ist, wichtige Server und Dienste zentral zu überwachen. Probleme sollen schnell in Grafana sichtbar sein. Bei wichtigen Fehlern wird zusätzlich eine Benachrichtigung gesendet.

## Überwachte Systeme

Folgende Systeme werden überwacht:

- `git-dev`
- `git`
- `leihs`
- `wwihelpdesk`
- `gitlab-runner`

## Verwendete Komponenten

- Prometheus sammelt die Messwerte.
- Node Exporter liefert Systemdaten wie CPU, RAM, Festplatte und Netzwerk.
- Blackbox Exporter prüft Webseiten, HTTPS und TLS-Zertifikate.
- PostgreSQL Exporter liefert Informationen über die Datenbank.
- Grafana zeigt die Daten in Dashboards.
- Grafana Alerting überwacht wichtige Grenzwerte und Ausfälle.

## Überwachte Werte

Das Monitoring zeigt unter anderem:

- Erreichbarkeit der Server
- Status wichtiger Dienste
- CPU-Auslastung
- RAM-Auslastung
- Festplattenbelegung
- Festplattenaktivität
- Netzwerkverkehr
- Load Average
- Erreichbarkeit der Webseiten
- Laufzeit der TLS-Zertifikate
- PostgreSQL-Status und Datenbankwerte
- GitLab-Benutzerkonten

## Dokumentation

- [Zentraler Monitoring-Server git-dev](docs/01-git-dev.md)
- [Produktiver GitLab-Server git](docs/02-git.md)
- [LEIHS](docs/03-leihs.md)
- [WWI Helpdesk](docs/04-wwihelpdesk.md)
- [GitLab Runner](docs/05-gitlab-runner.md)
- [Grafana Alerting](docs/06-alerting.md)


## Projektstruktur

- `docs` enthält die Anleitungen und Erklärungen.
- `screenshots/dashboards` enthält Bilder der Grafana-Dashboards.
- `screenshots/alerts` enthält Bilder der Alert-Regeln.
- `screenshots/terminal` enthält Prüfungen aus dem Terminal.
- `config-examples` enthält Konfigurationsbeispiele ohne Passwörter und Tokens.
- `scripts` enthält verwendete Skripte ohne geheime Daten.

## Sicherheit

Passwörter, Tokens, private SSH-Schlüssel und andere Zugangsdaten werden nicht in diesem Repository gespeichert.

Sensible Werte werden in Beispielen durch Platzhalter ersetzt, zum Beispiel:

```text
<IP-ADRESSE>
<PASSWORT>
<TOKEN>
```