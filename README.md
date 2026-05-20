Azure Data Engineering Project

End-to-end Azure Data Engineering project focused on building a scalable Spotify data ingestion pipeline using Azure services and a Bronze Layer architecture.

The project demonstrates industry-standard data engineering practices including:

- Incremental data loading
- Dynamic parameterized pipelines
- Watermarking for CDC processing
- Historical backfilling
- CI/CD integration
- Monitoring & alerting
- Infrastructure as Code (IaC) using Terraform
- Architecture Overview

Tech Stack

- Service	Purpose
- Azure Data Factory	Data ingestion & orchestration
- Azure SQL Database	Source system
- Azure Data Lake Storage Gen2	Bronze data lake storage
- Azure Logic Apps	Monitoring & alerting
- GitHub Actions	CI/CD automation
- Terraform	Infrastructure provisioning
- Project Architecture
- Data Flow
- Data is sourced from Azure SQL Database
- Azure Data Factory performs:
- Initial load
-Incremental load
- Backfill processing
- Data is stored in the Bronze layer as Parquet files
- Watermark (cdc.json) is updated after successful ingestion
- Logic Apps monitor pipelines and trigger alerts
- GitHub Actions automates deployment
-  provisions Azure resources
- Key Features
- Incremental Loading

Uses a watermarking technique with cdc.json to process only new or updated records.

Process
- Read last CDC timestamp
- Extract new records only
- Load data into Bronze layer
- Update watermark
- Benefits
- Avoids full reloads
- Reduces compute cost
- Improves pipeline performance
- Supports scalable ingestion
- Dynamic Parameterized Pipelines

ADF pipelines are reusable across multiple tables using parameters such as:

- Schema name
- Table name
- CDC column
- from_date for backfill
- Backfill Support

Historical data loads are supported using an optional from_date parameter.

If:

- from_date is empty → Incremental load runs
- from_date has a value → Backfill load runs
- CI/CD Integration

GitHub is integrated with Azure Data Factory for automated deployments.

Workflow
- Development happens in feature/dev branches
- GitHub Actions validates and deploys pipelines
- adf_publish branch stores deployment artifacts
- Monitoring & Alerting

Azure Logic Apps monitor:

- Pipeline failures
- Runtime issues
- Processing alerts

Notifications can be triggered through:

Email
Teams
SMS
Azure Resources

The following resources were provisioned using Terraform:

- Resource Group
- Azure Data Factory
- Azure Data Lake Storage Gen2
- Azure SQL Database
- Azure Logic Apps
- Bronze Layer Structure
  
/bronze/
│
├── DimArtist/
├── DimAlbum/
├── DimTrack/
├── FactStream/
└── FactPlaylist/

Metadata Structure

/metadata/

│
├── cdc.json
└── empty.json
Purpose
File	Description
cdc.json	Stores latest CDC timestamp
empty.json	Used during watermark updates
Pipeline Activities

The ADF pipeline uses:

Activity	Purpose
- Lookup: Activity Reads CDC watermark

- Script: Activity Gets max CDC value

- Copy: Activity Loads incremental data

- If Condition:	Checks if new data exists

- Delete Activity: Removes unnecessary empty files

Example Incremental Query
SELECT *
FROM table_name
WHERE updated_at > last_cdc_timestamp


Folder Structure

Spotify-Azure-Project/
│
├── adf/
│   ├── pipelines/
│   ├── datasets/
│   ├── linkedServices/
│   └── triggers/
│
├── terraform/
│
├── images/
│
└── README.md

Getting Started
Prerequisites
Azure Subscription
Azure Data Factory
Azure SQL Database
Azure Storage Account
Terraform
GitHub Account


Setup Steps
1. Clone Repository
git clone https://github.com/your-username/Spotify-Azure-Project.git
2. Deploy Infrastructure
terraform init
terraform apply
3. Configure Azure Data Factory
Create linked services
Configure datasets
Publish pipelines
4. Configure GitHub Integration
Connect ADF to GitHub
Set up GitHub Actions

Future Improvements

Add Silver & Gold layers
Introduce Azure Databricks transformations
Add Delta Lake support
Implement automated data quality checks
Add Power BI dashboards
Learning Outcomes

This project demonstrates:

Azure Data Factory orchestration
Incremental ingestion design patterns
Watermarking techniques
Dynamic pipeline development
CI/CD integration
Infrastructure automation with Terraform
Conclusion

This project showcases a production-style Azure Data Engineering ingestion pipeline using Azure Data Factory and Azure Data Lake Storage Gen2. It focuses on scalable, reusable, and cost-efficient ingestion patterns commonly used in enterprise data platforms.
