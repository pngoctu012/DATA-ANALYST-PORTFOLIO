PROMOTION TRACKING PROJECT
-------------------------------------------------
# **1. Description**

Developed an end-to-end promotion analytics solution to monitor and evaluate the performance of Weekend, Fair, and Catalog campaigns across SKUs, stores, regions, and departments for the Fresh Food Division of Central Retail Vietnam.

The project was developed in response to management requirements to establish a consistent framework for promotion performance tracking. Collaborated with Marketing and management teams to define relevant business views, KPIs, and performance metrics, and translated these requirements into an interactive Power BI dashboard.

The solution processes 30M+ raw ERP records through a structured data pipeline, covering data ingestion, cleaning, transformation, storage, and reporting. The end-to-end workflow was built using Python (VS Code), PostgreSQL, and Power BI, enabling scalable data processing and streamlined promotion performance monitoring.

<img width="1198" height="674" alt="image" src="https://github.com/user-attachments/assets/41f291dd-507b-434d-8628-7e62c1306155" />
<img width="1200" height="675" alt="image" src="https://github.com/user-attachments/assets/33a5756d-544e-44ba-b736-2428f4afe039" />
<img width="1204" height="671" alt="image" src="https://github.com/user-attachments/assets/ef609bff-be8b-4933-9795-3d6262db994f" />

---------------------------------------------------
# **2. Business Problem**

Currently, the Fresh Food team primarily tracks promotion performance through Excel-based reports. Each campaign is maintained in a separate file, with approximately 2 Weekend campaigns, 3–4 Fair campaigns, and 1 Catalog campaign per week. This fragmented reporting structure makes it difficult to maintain a consolidated view of promotion performance and compare results across campaigns and time periods.

The existing approach also provides limited visual visibility into trends and performance, making it time-consuming to identify high- and low-performing SKUs, stores, and regions on a weekly basis.

In addition, extracting large volumes of data directly from the company's ERP system can be slow and unreliable, particularly when dealing with large datasets. Repeated manual extraction further increases the time required to prepare data for analysis.

## **Objective**

The objective of this project is to build a scalable and centralized promotion analytics workflow that enables the Commercial team to:

- Monitor promotion performance on a weekly basis.

- Compare performance across different campaigns and periods.

- Identify high- and low-performing SKUs, stores, regions, and departments.

- Reduce reliance on fragmented Excel reports and manual data preparation.

- Improve data accessibility by extracting and processing data through SQL and a structured data pipeline.

---------------------------------------------------
# **3. Data Architecture**

<img width="227" height="535" alt="image" src="https://github.com/user-attachments/assets/f4953213-fa86-467f-bef6-0d445279477f" />

---------------------------------------------------
# **4. Database Design**

<img width="1920" height="1080" alt="bronze_sales" src="https://github.com/user-attachments/assets/0bdcacca-3b7c-4a8c-b136-1d27062fda9f" />

The PostgreSQL database follows a Bronze–Silver–Gold architecture, separating raw data ingestion, data transformation, and business-ready datasets.

## Bronze Layer — Raw Data Ingestion

The Bronze layer stores data directly from ERP-exported CSV files with minimal transformation. Key tables include bronze_sales, bronze_fair, bronze_weekend, bronze_catalog, and bronze_region.

bronze_sales contains the raw sales transactions, while the campaign tables contain promotion information such as SKU, campaign, and region.

## Silver Layer — Data Transformation & Enrichment

The Silver layer transforms and enriches the raw Bronze data to create more structured datasets for analysis.

bronze_sales is transformed into item dimension and sales tables, allowing sales data to be joined more efficiently with item hierarchies and other reference data.

Campaign-related Silver tables are created by combining the Bronze campaign tables (bronze_fair, bronze_weekend, and bronze_catalog) with bronze_region. This enriches campaign data with additional business attributes such as store, business unit, format, and regional hierarchy.

## Gold Layer — Business-Ready Data

The Gold layer contains the final analytical datasets used by Power BI.

Campaign information is combined with the transformed sales data to generate daily sales performance at campaign and SKU level. These business-ready tables provide the foundation for monitoring promotion performance across campaigns, SKUs, stores, regions, and other business dimensions.

---------------------------------------------------
# **5. Data Model in Power BI**

<img width="855" height="675" alt="image" src="https://github.com/user-attachments/assets/c742fe6e-59c1-434b-a95c-1d299ab5536b" />

The Power BI data model is designed to support promotion performance analysis and year-over-year comparison across campaigns, SKUs, stores, regions, and departments.

The main KPIs include Total Sales, Total Quantity, and Total Margin, with performance compared against the corresponding period in the previous year.

Since the promotion calendar does not always align exactly by calendar date, the Last Year (LY) comparison is calculated using a 364-day offset rather than a standard calendar-year shift. DAX measures use variables and the TREATAS function to dynamically apply the relevant date, SKU, and store filters from the current promotion period to the corresponding period in the previous year.

This approach allows the dashboard to provide a consistent current-year vs. last-year comparison while maintaining the same campaign scope, SKU selection, and store coverage.

---------------------------------------------------
# **6. Conclusion**

This project demonstrates an end-to-end approach to retail promotion analytics, from processing large-scale ERP data to building a structured data warehouse and interactive Power BI dashboard.

By combining Python, SQL, PostgreSQL, and Power BI, the solution reduces manual data preparation and provides a consistent framework for monitoring promotion performance across campaigns, SKUs, stores, and regions.

More importantly, the project focuses on turning data into actionable business insights to support promotion evaluation, assortment decisions, and commercial planning.

***Python Test Script***: [Here](https://github.com/pngoctu012/PORTFOLIO-DATA-ANALYST/blob/main/Promotion%20Result%20Tracking%20Dashboard%20-%20Central%20Retail/PROMOTION%20DASHBOARD.py)

***SQL Test script***: [Here](https://github.com/pngoctu012/PORTFOLIO-DATA-ANALYST/blob/main/Promotion%20Result%20Tracking%20Dashboard%20-%20Central%20Retail/PROMOTION%20DASHBOARD.sql)
