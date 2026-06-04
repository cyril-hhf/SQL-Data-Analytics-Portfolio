# Comprehensive E-Commerce Analytics Engine (Olist Marketplace)

## 📌 Project Overview
This repository contains a production-grade analytics engineering pipeline built entirely in **PostgreSQL**. The project transforms raw, unstructured e-commerce marketplace data from Olist (Brazil) into an optimized **Star Schema (Kimball Methodology)** and executes advanced behavioral, statistical, and operational queries to drive executive decision-making.

## 🛠️ Tech Stack & Skills
* **Database Engine:** PostgreSQL
* **Data Modeling:** Star Schema, Dimensional Modeling (Facts & Dimensions), Surrogate Keys, DDL
* **Advanced Analytics SQL:** Window Functions, Nested Aggregations, CTEs, Pearson Correlation Analytics (`CORR`), Cohort Decay Analysis, RFM Customer Segmentation

---

## 📈 Analytical Highlights & Queries

### 1. Customer Cohort Retention Analysis (`04_analytics/customers/customer_cohort_retention.sql`)
* **The Business Problem:** Measuring absolute customer loyalty and repurchasing decay across the platform.
* **The SQL Mechanics:** Utilized multi-layered CTEs to establish customer "birth months" tracking the unique master identity (`customer_unique_id`). Implemented date arithmetic to index monthly time elapsed and forced floating-point math to completely bypass integer division truncation.
* **Business Insight:** Identified a steep drop-off curve post-Month 0, showing that the marketplace behaves as a single-transaction high-consideration model, highlighting the strategic need for introducing high-frequency consumable categories.

### 2. Shipping Cost vs. Speed Correlation Engine (`04_analytics/logistics/shipping_cost_efficiency.sql`)
* **The Business Problem:** Auditing whether charging premium freight costs successfully buys faster logistics fulfillment for the consumer.
* **The SQL Mechanics:** Bypassed simple averages to run a native **Pearson Correlation Coefficient (`CORR(y, x)`)** mathematical calculation grouped by regional states.
* **Business Insight:** Quantified systemic SLA breakdowns by identifying regions with near-zero or positive correlation metrics, providing mathematical evidence to renegotiate courier service-level contracts.

### 3. RFM Customer Behavioral Segmentation (`04_analytics/customers/rfm_customer_segmentation.sql`)
* **The Business Problem:** Micro-segmenting users based on value behaviors rather than treating the user base as a monolith.
* **The SQL Mechanics:** Leveraged `NTILE(5)` over distinct recency, frequency, and monetary windows to map buyers into strategic marketing labels (e.g., *Champions*, *Can't Lose Them*, *Hibernating*).

---

## 📂 Repository Blueprint
* `/01_raw_staging`: Raw ingestion structures.
* `/02_data_modeling`: Star schema DDL definitions transforming data granularity into unified fact and dimension records.
* `/03_data_transform_etl`: The transformation engine.
* `/04_analytics`: Production-ready advanced analytical queries.
