# Data retrieval:

Manifest from GDC data portal was retrieved using the following selection:

* PAAD-TCGA project
* Data Category: clinical
* Data Format: bcr xml

Data was downloaded to data/raw/clinFiles/ using gdc-tool:

`gdc-client download -m ../gdc_manifest.2026-04-01.232418.txt`