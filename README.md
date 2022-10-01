# bikerenting-etl

## Problembeschreibung

Eine Fahrradmiet Firma sammelt Daten zu Fahrten mit ihren Rädern. Sie wollen diese nun nutzen um die attraktivsten Standorte herauszufinden.

Hierfür habe ich einen Batch-Job entwickelt, welcher den CSV in ein richtiges Format bringt, in einen S3 Bucket lädt und dann mithilfe von DBT in ein Redshift Datawarehouse im Star-Schema lädt. Auf dieses kann dann mit Tableau zugegriffen werden, um eine Analyse duhzuführen.

## Verwendete Technologien




## Architektur
![a](https://github.com/SurlaRoute14/bikerenting-etl/blob/main/bilder/ARCHITEKTUR-2.png)
