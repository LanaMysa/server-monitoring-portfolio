# Monitoring der VM WWI Helpdesk

## Aufgabe des Servers

Auf der VM `wwihelpdesk` läuft die Helpdesk-Anwendung OTRS. Für diesen Server werden die Systemressourcen, wichtige Dienste, die Weboberfläche und das TLS-Zertifikat überwacht.

## 1. System prüfen

Zuerst wurden der Hostname, das Betriebssystem und die IP-Adresse geprüft:

```bash
hostnamectl
cat /etc/os-release
hostname -I
```

## 2. Node Exporter prüfen

Der Node Exporter liefert die Systemmetriken an Prometheus.

Der Status wurde geprüft:

```bash
systemctl status node_exporter
```

Der Port wurde kontrolliert:

```bash
ss -lntp | grep ':9100'
```

Der Node Exporter verwendet Port `9100`.

## 3. Node Exporter lokal testen

Die Metriken wurden direkt auf der VM geprüft:

```bash
curl --noproxy '*' -fsS \
  http://127.0.0.1:9100/metrics | head
```

Wenn Prometheus-Metriken angezeigt werden, arbeitet der Node Exporter.

## 4. Verbindung vom Monitoring-Server testen

Der zentrale Prometheus-Server muss den Node Exporter erreichen können.

Die Verbindung wurde von `git-dev` geprüft:

```bash
curl --noproxy '*' -fsS --connect-timeout 5 \
  http://<WWIHELPDESK-IP>:9100/metrics | head
```

Der Zugriff auf Port `9100` soll möglichst nur für den zentralen Monitoring-Server erlaubt sein.

## 5. Prometheus-Job einrichten

Auf `git-dev` wurde ein Prometheus-Job für WWI Helpdesk eingetragen:

```text
job_name: wwihelpdesk-node
target: <WWIHELPDESK-IP>:9100
server: wwihelpdesk
environment: production
```

Die GitLab-Konfiguration wurde geprüft:

```bash
/opt/gitlab/embedded/bin/ruby -c /etc/gitlab/gitlab.rb
```

Erwartetes Ergebnis:

```text
Syntax OK
```

Danach wurde die Konfiguration übernommen:

```bash
gitlab-ctl reconfigure
```

## 6. Prometheus-Verbindung testen

Die Verbindung wurde über die Prometheus-API geprüft:

```bash
curl --noproxy '*' -fsS --get \
  --data-urlencode 'query=up{job="wwihelpdesk-node"}' \
  http://127.0.0.1:9090/api/v1/query
```

Das Ergebnis `1` bedeutet, dass Prometheus den Node Exporter erreicht.

## 7. OTRS-Weboberfläche überwachen

Für die öffentliche Weboberfläche wurde ein Blackbox-Job eingerichtet:

```text
job_name: wwihelpdesk-https
target: https://wwihelpdesk.example.com/
server: wwihelpdesk
service: otrs-web
```

Der Blackbox Exporter prüft:

- Erreichbarkeit der Webseite
- HTTP-Statuscode
- HTTPS/TLS
- Ablaufdatum des Zertifikats

## 8. HTTPS-Prüfung testen

Folgende Prometheus-Metriken wurden geprüft:

```promql
probe_success{job="wwihelpdesk-https"}
```

```promql
probe_http_status_code{job="wwihelpdesk-https"}
```

```promql
probe_http_ssl{job="wwihelpdesk-https"}
```

Das Ergebnis war:

```text
probe_success = 1
probe_http_status_code = 200
probe_http_ssl = 1
```

HTTP-Code `200` bedeutet, dass die Webseite erfolgreich erreichbar ist.

## 9. Grafana-Dashboard

Das Dashboard für WWI Helpdesk zeigt:

- Serverstatus
- wichtige Dienste
- CPU-Auslastung
- RAM-Auslastung
- Load Average
- Festplattenbelegung
- Festplattenaktivität
- Netzwerkverkehr
- Erreichbarkeit der OTRS-Weboberfläche
- Restlaufzeit des TLS-Zertifikats

## 10. Alert-Regeln

Für WWI Helpdesk wurden folgende Alert-Regeln eingerichtet:

- WWI-Helpdesk-Server nicht erreichbar
- wichtiger Dienst ausgefallen
- OTRS-Weboberfläche nicht erreichbar
- CPU-Auslastung hoch
- RAM-Auslastung hoch
- Festplatte fast voll
- TLS-Zertifikat läuft bald ab

## Ergebnis

Die VM `wwihelpdesk` wird zentral von Prometheus auf `git-dev` überwacht. Grafana zeigt die Systemwerte, den Status der OTRS-Weboberfläche und die Restlaufzeit des TLS-Zertifikats an.