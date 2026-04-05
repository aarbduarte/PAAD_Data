# TCGA-PAAD

Extract and parse TCGA-PAAD data from GDC data-portal into a a TSV available in 

## Structure

├── data
│   ├── processed
│   │   └── parsed_data.tsv
│   └── raw
│       ├── cliFiles
│       ├── gdc_manifest.2026-04-01.232418.txt
│       ├── metadata.repository.2026-04-01.json
│       └── README.md
├── docs
├── output
│   ├── figures
│   └── tables
├── PAAD_Data.Rproj
└── scripts
    └── ParseData.R