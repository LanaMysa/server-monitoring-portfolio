# Monitoring auf git-dev

## Aufgabe des Servers

`git-dev` ist der zentrale Monitoring-Server. Auf diesem Server laufen Prometheus, Grafana und der Blackbox Exporter.

Prometheus sammelt die Daten von den anderen virtuellen Maschinen. Grafana zeigt diese Daten in Dashboards an.

## 1. System prüfen

Zuerst wurden das Betriebssystem und die aktiven Monitoring-Dienste geprüft:

```bash
hostnamectl
gitlab-ctl status | grep -E 'prometheus|node-exporter|postgres-exporter'
ss -lntp | grep -E ':(3000|9090|9100|9115|9187)\b'
```

Wichtige Ports:

- `9090` – Prometheus
- `9100` – Node Exporter
- `9115` – Blackbox Exporter
- `9187` – PostgreSQL Exporter
- `3000` – Grafana, wenn Grafana diesen Port verwendet

## 2. Konfiguration sichern

Vor jeder Änderung wurde eine Sicherung erstellt:

```bash
cp -a /etc/gitlab/gitlab.rb \
  /etc/gitlab/gitlab.rb.backup-YYYY-MM-DD
```

Dadurch kann die alte Konfiguration bei einem Fehler wiederhergestellt werden.

## 3. Prometheus-Ziele eintragen

Die externen Server wurden in der Datei `/etc/gitlab/gitlab.rb` unter `prometheus['scrape_configs']` eingetragen.

Für Systemmetriken verwendet Prometheus den Node Exporter:

```text
<SERVER-IP>:9100
```

Für Webseiten und TLS-Zertifikate verwendet Prometheus den Blackbox Exporter:

```text
127.0.0.1:9115
```

Für jeden Server wurden eigene