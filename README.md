Spotify Azure Data Engineering Project

End-to-end Azure Data Engineering project focused on building a scalable Spotify data ingestion pipeline using a Bronze Layer architecture within Azure Data Lake Storage Gen2.

The project demonstrates modern data engineering practices including:

Incremental data loading
Dynamic parameterized pipelines
CI/CD integration
Watermarking for CDC processing
Backfilling historical data
Monitoring and alerting
Infrastructure as Code using Terraform
Architecture Overview
Technologies Used
Azure Data Factory (ADF)
Azure Data Lake Storage Gen2 (ADLS Gen2)
Azure SQL Database
Azure Logic Apps
GitHub Actions
Terraform
Project Overview

The solution ingests Spotify-related data from Azure SQL Database into the Bronze layer of Azure Data Lake Storage Gen2 using Azure Data Factory.

The project focuses on:

Building reusable ingestion pipelines
Performing incremental data extraction
Managing CDC watermarking
Supporting backfill operations
Automating deployments with CI/CD
Solution Architecture
1. Infrastructure Provisioning

All Azure resources were provisioned using Terraform.

Resources Created
Resource Group
Azure Data Factory
Azure Data Lake Storage Gen2
Azure SQL Database
Azure Logic Apps
2. Data Ingestion with Azure Data Factory

Azure Data Factory is used to orchestrate ingestion pipelines from Azure SQL Database into the Bronze layer.

Pipeline Features
Parameterized pipelines
Dynamic datasets
Incremental loading
Initial full load
Historical backfill support
Watermarking using JSON metadata
Reusable ingestion framework
Parameters Used

The ingestion pipeline accepts:

Schema name
Table name
CDC column
Optional from_date parameter for backfill

This allows a single pipeline to ingest multiple tables dynamically.

3. Incremental Loading Strategy

The project implements incremental loading using a watermarking technique.

Process
Read the last CDC value from cdc.json
Query only new or updated records from Azure SQL
Load new data into the Bronze layer
Update the watermark value
Benefits
Avoids full table reloads
Reduces compute cost
Improves performance
Supports scalable ingestion across multiple tables
Example Query
SELECT *
FROM table_name
WHERE updated_at > last_cdc_timestamp
4. Bronze Layer – ADLS Gen2

The Bronze layer stores raw ingested data as Parquet files.

Structure
/bronze/
│
├── DimArtist/
├── DimAlbum/
├── DimTrack/
├── FactStream/
└── FactPlaylist/
Metadata Files

Additional files are maintained for CDC tracking:

cdc.json → Stores latest watermark timestamp
empty.json → Used during watermark updates
5. Azure Data Factory Pipeline Flow

The ingestion pipeline performs the following steps:

Lookup activity retrieves the last CDC value
Script activity gets the latest CDC timestamp from Azure SQL
Copy activity loads incremental data into Bronze
Copy activity updates cdc.json
Delete activity removes unnecessary empty files
Activities Used
Lookup Activity
Script Activity
Copy Activity
If Condition Activity
Delete Activity
6. CI/CD Integration

GitHub was integrated with Azure Data Factory for CI/CD.

Workflow
Development branch used for pipeline changes
GitHub Actions automates deployment
ADF publish branch handles release artifacts
Benefits
Version control
Automated deployment
Easier collaboration
Consistent releases
7. Monitoring & Alerting

Azure Logic Apps were implemented for monitoring and alerting.

Monitoring Includes
Pipeline failures
Runtime monitoring
Alert notifications
Key Features
End-to-end Azure ingestion pipeline
Bronze Layer architecture
Dynamic parameterized ADF pipelines
Incremental loading using watermarking
Historical backfilling support
CI/CD with GitHub Actions
Infrastructure as Code using Terraform
Monitoring and alerting with Logic Apps
Folder Structure
Spotify-Azure-Project/
│
├── adf/
├── datasets/
├── pipelines/
├── terraform/
├── images/
└── README.md
Future Improvements
Add Silver and Gold layers
Introduce Azure Databricks transformations
Implement Delta Live Tables
Add Power BI reporting
Implement automated data quality checks
Conclusion

This project demonstrates a production-style Azure Data Engineering ingestion solution using Azure Data Factory and Azure Data Lake Storage Gen2. It showcases scalable ingestion design patterns including incremental loading, reusable pipelines, CI/CD automation, and infrastructure provisioning using Terraform.
