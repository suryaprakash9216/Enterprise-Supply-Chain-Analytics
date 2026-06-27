Enterprise Supply Chain Analytics

"SQL" (https://img.shields.io/badge/SQL-MySQL-blue)
"Python" (https://img.shields.io/badge/Python-3.12-yellow)
"Power BI" (https://img.shields.io/badge/PowerBI-Dashboard-F2C811)
"Microsoft Fabric" (https://img.shields.io/badge/Microsoft-Fabric-7B3FF2)
"Azure" (https://img.shields.io/badge/Azure-DataFactory-0078D4)
"License" (https://img.shields.io/badge/License-MIT-green)

«End-to-End Supply Chain Analytics Project using SQL, Python, Power BI, Microsoft Fabric, and Microsoft Azure.»

---

Project Overview

This project demonstrates the complete lifecycle of a modern data analytics solution, starting from raw business data and ending with cloud-based reporting and monitoring.

The solution covers business understanding, data preparation, exploratory data analysis, data warehousing, SQL analytics, forecasting, interactive dashboards, Microsoft Fabric implementation, and Microsoft Azure cloud integration.

The primary objective was to transform raw supply chain data into actionable business insights for executive decision-making.

---

Business Objectives

- Analyze sales, profit, customers, products, inventory, shipping, and regional performance.
- Design a scalable Star Schema data warehouse.
- Develop SQL-based KPI reporting and business analytics.
- Build interactive Power BI dashboards.
- Implement Microsoft Fabric analytics workflows.
- Deploy data to Microsoft Azure and automate cloud ETL pipelines.

---

Project Workflow

Business Understanding
        │
        ▼
Data Understanding
        │
        ▼
Data Cleaning & Transformation (Python)
        │
        ▼
Exploratory Data Analysis (EDA)
        │
        ▼
Data Warehouse (Star Schema)
        │
        ▼
SQL Analysis & KPI Development
        │
        ▼
Statistical Analysis
        │
        ▼
Forecasting & Predictive Analytics
        │
        ▼
Power BI Dashboard
        │
        ▼
Microsoft Fabric
(Lakehouse • Warehouse • PySpark)
        │
        ▼
Microsoft Azure
(Blob Storage • Data Factory • Cloud ETL • Pipeline Monitoring)

---

Technologies Used

Programming

- SQL
- Python

Python Libraries

- Pandas
- NumPy
- Matplotlib
- Seaborn
- Scikit-learn

Business Intelligence

- Microsoft Power BI
- Power Query
- DAX

Database

- MySQL

Microsoft Fabric

- Lakehouse
- Warehouse
- PySpark Notebook
- SQL Endpoint
- Semantic Model

Microsoft Azure

- Azure Blob Storage
- Azure Data Factory
- Cloud ETL Pipeline
- Pipeline Monitoring

---

Project Architecture

CSV Files
      │
      ▼
Python Data Cleaning
      │
      ▼
MySQL Data Warehouse
      │
      ▼
Star Schema
(Fact + Dimension Tables)
      │
      ▼
SQL Analytics
      │
      ▼
Power BI Dashboard
      │
      ├────────► Microsoft Fabric
      │          • Lakehouse
      │          • Warehouse
      │          • PySpark
      │
      ▼
Microsoft Azure
• Blob Storage
• Azure Data Factory
• ETL Pipeline
• Pipeline Monitoring

---

Data Warehouse

Implemented a Star Schema consisting of:

- Fact Orders
- Dim Customer
- Dim Product
- Dim Date
- Dim Location
- Dim Shipping

---

SQL Analytics

Implemented:

- Data Exploration
- KPI Development
- Advanced SQL Analysis
- Window Functions
- Common Table Expressions (CTEs)
- Business Performance Reporting

---

Statistical Analysis & Forecasting

Performed:

- Descriptive Statistics
- Correlation Analysis
- Regression Analysis
- Time Series Forecasting
- Predictive Analytics

---

Power BI Dashboard

Developed an interactive dashboard with six analytical pages:

- Executive Overview
- Supply Chain Overview
- Inventory Overview
- Logistics Overview
- Customer Overview
- Operations Overview

Dashboard features include:

- KPI Cards
- Revenue & Profit Analysis
- Customer Segmentation
- Product Performance
- Inventory Analysis
- Logistics Performance
- Interactive Filters
- Geographic Visualisations
- Trend Analysis

---

Microsoft Fabric

Implemented an enterprise analytics workflow using Microsoft Fabric:

- Imported datasets into Lakehouse
- Created Warehouse tables
- Executed SQL Queries
- Performed PySpark analysis
- Built Semantic Models
- Connected Power BI to Fabric

---

Microsoft Azure

Implemented cloud data engineering using Microsoft Azure:

- Uploaded datasets to Azure Blob Storage
- Created Azure Storage Containers
- Configured Azure Data Factory
- Built Cloud ETL Copy Pipeline
- Successfully executed Pipeline Runs
- Monitored Pipeline Execution

---

Business Insights

Some key insights generated from the project include:

- Revenue exceeded 36.78M
- Total Profit reached 3.97M
- Total Orders exceeded 66K
- Consumer segment generated the highest revenue
- Fishing category contributed the highest sales
- Standard Class was the most frequently used shipping mode
- Regional analysis highlighted top-performing markets and delivery performance

---

Repository Structure

enterprise-supply-chain-analytics/

│
├── data/
│   ├── dim_customer.csv
│   ├── dim_date.csv
│   ├── dim_location.csv
│   ├── dim_product.csv
│   ├── dim_shipping.csv
│   └── fact_orders.csv
│
├── sql/
│
├── notebooks/
│
├── powerbi/
│
├── microsoft-fabric/
│
├── azure/
│
├── images/
│
├── README.md
│
└── LICENSE

---

Project Screenshots

Star Schema

(Add Star Schema Image)

Power BI Dashboard

- Executive Overview
- Supply Chain Overview
- Inventory Overview
- Logistics Overview
- Customer Overview
- Operations Overview

(Add Dashboard Screenshots)

Microsoft Fabric

- Lakehouse
- Warehouse
- PySpark Notebook
- SQL Endpoint

(Add Fabric Screenshots)

Microsoft Azure

- Blob Storage
- Azure Data Factory
- Successful Pipeline Execution

(Add Azure Screenshots)

---

Skills Demonstrated

- SQL
- Python
- Data Cleaning
- Data Transformation
- Exploratory Data Analysis (EDA)
- Data Warehousing
- Star Schema Design
- KPI Development
- Business Intelligence
- Dashboard Development
- DAX
- Statistical Analysis
- Forecasting
- Predictive Analytics
- Microsoft Power BI
- Microsoft Fabric
- Microsoft Azure
- Cloud ETL Pipelines
- Data Visualization

---

Key Outcomes

- Designed an end-to-end analytics solution for supply chain data.
- Built a scalable Star Schema data warehouse.
- Developed SQL-based business reporting and KPI analytics.
- Created interactive Power BI dashboards for executive reporting.
- Implemented Microsoft Fabric Lakehouse, Warehouse, and PySpark workflows.
- Automated cloud data ingestion using Azure Blob Storage and Azure Data Factory.
- Successfully executed and monitored Azure Data Factory ETL pipelines.

---

Future Enhancements

- Incremental data loading
- Real-time streaming analytics
- Automated scheduled pipeline execution
- Azure Synapse Analytics integration
- Azure Key Vault for secure credential management
- Azure Monitor alerts for pipeline failures

---

License

This project is licensed under the MIT License.
