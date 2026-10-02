# Grafana Alerting

## Ziel

Grafana Alerting überwacht wichtige Zustände und Grenzwerte. Wenn ein Problem länger als die eingestellte Zeit besteht, wird eine Benachrichtigung erstellt.

## 1. Struktur der Alert-Regeln

Die Regeln wurden übersichtlich in Gruppen organisiert.

Im Ordner `Server-Monitoring` befinden sich:

```text
Dienststatus
Ressourcenauslastung
VM-Verfügbarkeit
```

Die Regeln für Zertifikate befinden sich in:

```text
TLS certificate checks
```

## 2. Bedeutung der Gruppen

### Dienststatus

Diese Gruppe überwacht wichtige Anwendungen und Dienste:

- GitLab-Weboberfläche
- LEIHS-Weboberfläche
- OTRS-Weboberfläche
- GitLab Runner
- Podman API
- PostgreSQL
- weitere wichtige Systemdienste

### Ressourcenauslastung

Diese Gruppe überwacht:

- CPU-Auslastung
- RAM-Auslastung
- Festplattenbelegung

### VM-Verfügbarkeit

Diese Gruppe prüft, ob die virtuellen Maschinen über den Node Exporter erreichbar sind.

### TLS certificate checks

Diese Gruppe überwacht die Restlaufzeit der TLS-Zertifikate.

## 3. Auswertungszeiten

Die Regeln werden regelmäßig ausgewertet:

```text
Evaluate every: 1m
Pending period: 2m
Keep firing for: 2m
```

`Pending period: 2m` bedeutet, dass ein Problem zwei Minuten bestehen muss, bevor der Alert ausgelöst wird.

`Keep firing for: 2m` bedeutet, dass der Alert nach der Normalisierung noch zwei Minuten angezeigt wird.

## 4. Labels

Jede Regel besitzt eindeutige Labels.

Beispiel:

```text
server = git
service = gitlab-web
severity = critical
```

Verwendete Schweregrade:

- `warning` – Warnung, Prüfung erforderlich
- `critical` – wichtiger Dienst oder Server ist ausgefallen

Die Labels helfen bei der Zuordnung und Weiterleitung der Benachrichtigungen.

## 5. Verfügbarkeit einer VM

Beispiel für eine Prometheus-Abfrage:

```promql
up{job="<NODE-JOB>"}
```

Alert-Bedingung:

```text
IS BELOW 1
```

Wenn der Wert `0` ist, kann Prometheus den Node Exporter nicht erreichen.

## 6. Webseite überwachen

Beispiel:

```promql
probe_success{job="<HTTPS-JOB>"}
```

Alert-Bedingung:

```text
IS BELOW 1
```

Diese Regel erkennt, wenn eine Webseite über HTTPS nicht erreichbar ist.

## 7. PostgreSQL überwachen

Die Verbindung zur PostgreSQL-Datenbank wird mit folgender Metrik geprüft:

```promql
pg_up{job="postgres", instance="localhost:9187"}
```

Alert-Bedingung:

```text
IS BELOW 1
```

Deadlocks werden mit folgender Abfrage überwacht:

```promql
sum(increase(pg_stat_database_deadlocks{datname="gitlabhq_production"}[15m]))
```

Alert-Bedingung:

```text
IS ABOVE 0
```

## 8. TLS-Zertifikate überwachen

Die Restlaufzeit eines Zertifikats kann so berechnet werden:

```promql
(probe_ssl_earliest_cert_expiry - time()) / 86400
```

Das Ergebnis zeigt die verbleibenden Tage.

Bei einer kurzen Restlaufzeit wird eine Warnung oder ein kritischer Alert ausgelöst.

## 9. Texte der Benachrichtigungen

Jede Regel enthält:

- eine kurze Zusammenfassung
- eine Beschreibung des Problems
- eine empfohlene Prüfung

Beispiel:

```text
Die GitLab-Weboberfläche ist über HTTPS nicht erreichbar.

Bitte GitLab, den Webserver, den HTTPS-Port 443,
die Firewall und die Netzwerkverbindung prüfen.
```

## 10. Benachrichtigungen

Für die Regeln wird der konfigurierte Contact Point verwendet:

```text
Server-Monitoring – Telegram und E-Mail
```

Passwörter und Tokens des Contact Points werden nicht in der Dokumentation oder im Git-Repository gespeichert.

## 11. Prüfung der Regeln

Vor dem Speichern wurde die Funktion verwendet:

```text
Preview alert rule condition
```

Im normalen Zustand wird angezeigt:

```text
Normal
```

Bei den neu erstellten Regeln wurde kein absichtlicher Dienstausfall erzeugt. Dadurch wurde ein unnötiger Ausfall der produktiven Systeme vermieden.

## Ergebnis

Die Alert-Regeln erkennen wichtige Ausfälle und hohe Ressourcenauslastungen. Durch einheitliche Namen, Labels und Gruppen können die Meldungen schnell einem Server und einem Dienst zugeordnet werden.