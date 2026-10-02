# Monitoring der VM LEIHS

## Aufgabe des Servers

Auf der VM `leihs` läuft die LEIHS-Webanwendung. Für diesen Server werden die Systemressourcen, die Erreichbarkeit der Webseite und das TLS-Zertifikat überwacht.

## 1. System prüfen

Zuerst wurden das Betriebssystem, der Hostname und die IP-Adresse geprüft:

```bash
hostnamectl
cat /etc/os-release
hostname -I
```

Auf dem Server läuft Ubuntu Server 22.04 LTS.

## 2. Node Exporter prüfen

Der Node Exporter liefert Systemmetriken an Prometheus.

Der Status wurde geprüft:

```bash
systemctl status node_exporter
```

Der verwendete Port wurde kontrolliert:

```bash
ss -lntp | grep ':9100'
```

Der Node Exporter muss auf Port `9100` erreichbar sein.

## 3. Node Exporter lokal testen

Die Metriken wurden direkt auf der VM geprüft:

```bash
curl --noproxy '*' -fsS \
  http://127.0.0.1:9100/metrics | head
```

Wenn mehrere Prometheus-Metriken angezeigt werden, arbeitet der Node Exporter.

## 4. Netzwerkzugriff prüfen

Der zentrale Prometheus-Server muss die VM auf Port `9100` erreichen können.

Die Verbindung wurde von `git-dev` geprüft:

```bash
curl --noproxy '*' -fsS --connect-timeout 5 \
  http://<LEIHS-IP>:9100/metrics | head
```

Der Zugriff auf Port `9100` soll möglichst nur für den zentralen Monitoring-Server erlaubt sein.

## 5. Prometheus-Job einrichten

Auf `git-dev` wurde in `/etc/gitlab/gitlab.rb` ein Prometheus-Job für LEIHS eingetragen:

```text
job_name: leihs-node
target: <LEIHS-IP>:9100
server: leihs
environment: development
```

Nach der Änderung wurde die Syntax geprüft:

```bash
/opt/gitlab/embedded/bin/ruby -c /etc/gitlab/gitlab.rb
```

Danach wurde die Konfiguration übernommen:

```bash
gitlab-ctl reconfigure
```

## 6. Prometheus-Verbindung testen

Die Verbindung wurde über die Prometheus-API geprüft:

```bash
curl --noproxy '*' -fsS --get \
  --data-urlencode 'query=up{job="leihs-node"}' \
  http://127.0.0.1:9090/api/v1/query
```

Das Ergebnis `1` bedeutet, dass Prometheus den Node Exporter erreicht.

## 7. HTTPS-Prüfung einrichten

Für die LEIHS-Weboberfläche wurde ein Blackbox-Job eingerichtet:

```text
job_name: leihs-https
target: https://leihs.example.com/
server: leihs
service: leihs-web
```

Der Blackbox Exporter prüft:

- Erreichbarkeit der Webseite
- HTTP-Statuscode
- HTTPS/TLS
- Ablaufdatum des Zertifikats

## 8. HTTPS-Prüfung testen

Folgende Prometheus-Metriken wurden kontrolliert:

```promql
probe_success{job="leihs-https"}
```

```promql
probe_http_status_code{job="leihs-https"}
```

```promql
probe_http_ssl{job="leihs-https"}
```

Dabei bedeutet:

- `probe_success = 1` – die Webseite ist erreichbar.
- `probe_http_ssl = 1` – HTTPS wird verwendet.
- HTTP-Code `302` – die Webseite leitet auf eine andere Seite weiter. Das ist bei LEIHS normal.

## 9. Grafana-Dashboard

Das Dashboard für LEIHS zeigt:

- Serverstatus
- wichtige Dienste
- CPU-Auslastung
- RAM-Auslastung
- Load Average
- Festplattenbelegung
- Festplattenaktivität
- Netzwerkverkehr
- Erreichbarkeit der LEIHS-Weboberfläche
- Restlaufzeit des TLS-Zertifikats

## 10. Alert-Regeln

Für LEIHS wurden folgende Alert-Regeln eingerichtet:

- LEIHS-Server nicht erreichbar
- wichtiger Dienst ausgefallen
- LEIHS-Weboberfläche nicht erreichbar
- CPU-Auslastung hoch
- RAM-Auslastung hoch
- Festplatte fast voll
- TLS-Zertifikat läuft bald ab

## Ergebnis

Die VM `leihs` wird zentral von Prometheus auf `git-dev` überwacht. Grafana zeigt die Systemwerte und den Zustand der LEIHS-Weboberfläche an. Bei wichtigen Problemen kann eine Benachrichtigung gesendet werden.