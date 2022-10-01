# bikerenting-etl

## Problembeschreibung

Eine Firme, die Mieträder anbietet sammelt Daten zu Fahrten mit ihren Rädern. Sie wollen diese nun nutzen um die attraktivsten Standorte herauszufinden.

Hierfür habe ich einen Batch-Job entwickelt, welcher den CSV in ein richtiges Format bringt, in einen S3 Bucket lädt und dann mithilfe von DBT in ein Redshift Datawarehouse im Star-Schema lädt. Auf dieses kann dann mit Tableau zugegriffen werden, um eine Analyse duhzuführen.

## Verwendete Technologien

- Python 
- Aws (S3, Redshift) 
- Docker 
- Airflow 
- Dbt 
- Tableau 

## Architektur
![a](https://github.com/SurlaRoute14/bikerenting-etl/blob/main/bilder/ARCHITEKTUR-2.png)


## Ablauf: 

Sämtliche Schritte die typischerweise lokal ablaufen habe ich mithilfe von Docker containerisiert. Dies betrifft das Transformieren der Csv Datei und Laden dieser in Redshift, sowie die Datenmodellierung und das Testen in DBT. Apache Airflow läuft ebenfalls mit Docker-Compose. 

**1.** *Laden & Transformieren der CSV Datei und Laden in S3*

Mithilfe eines Containerisierten Python Skriptes Transformiere ich die CSV Datei, um fehlende Werte zu behandeln und falsche Datumswerte                                   zu berichtigen. Die CSV Datei  wird dann in einen S3 Bucket mit dem Namen „bikerenting“ geladen. 

**2.** *Laden von S3 zu Redshift*

Nachdem eine Verbindung zu Redshift hergestellt wurde, wird ein Stage Table erstellt, falls dieser noch nicht existiert. Im nächsten Schritt wird die CSV Datei aus S3 in den Redshift Stage Table kopiert. 

Das Skript und der Dockerfile zu Schritt 1 & 2 lassen sich [hier](https://github.com/SurlaRoute14/bikerenting-etl/tree/main/python_script_container) finden: 

**3.** *Datenmodellierung und Testen mit DBT*

DBT ermöglicht es mir, die SQL-Queries vor dem Ausführen erst zu testen. Dabei werden die Daten in meinem Redshift Stage-Table in das Star Schema transformiert. DBT macht es mir neben dem testen der Queries möglich, dieses in anderen zu referenzieren, was die Entwicklung sehr vereinfacht.
DBT selbst wird über Docker deployed. Der Projektordner lässt sich [hier](https://github.com/SurlaRoute14/bikerenting-etl/tree/main/dbt) finden und muss in den eigenen DBT Ordner gezogen werden, sowie die projects.yaml Datei mit den eigenen Zugangsdaten ausgefüllt werden und die Tests und Skripte werden von Airflow ausgeführt. 
Der finale Datamart sieht so aus:

![a](https://github.com/SurlaRoute14/bikerenting-etl/blob/main/bilder/datamart.png)

Die Stations Dimensions-Tabelle inkludiert dabei slowly changing dimensions, da manche Stationen in der Zukunft vielleicht nicht mehr verwendet werden. 
Auch habe ich eine extra Tabelle für das Datum und die Zeit implementiert, genau so wie Kimball dies empfiehlt. 

**4.** *Orchestrierung mit Apache Airflow*

Airflow muss über Docker-Compose ausgeführt werden, eine Anleitung findet sich [hier](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html) 

Schritt 1,2 und 3 werden alle über Airflow ausgeführt. Hierfür verwende ich den Docker Operator um die Docker Images und damit das Skript auszuführen. Der DAG hierfür lässt sich in dem [dag Ordner](https://github.com/SurlaRoute14/bikerenting-etl/tree/main/dag) finden. 

**5.** *Visualisierung mit Tableau*

Tableau greift auf Redshift zu und ich habe ein simples Dashboard erstellt, welches die Attraktivität von Leihstationen visualisiert. 

![](https://github.com/SurlaRoute14/bikerenting-etl/blob/main/bilder/dashboard.png)

