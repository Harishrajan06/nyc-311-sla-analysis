# NYC 311 Service Requests – SLA Performance Analysis

## Overview

This project analyses Service Level Agreement (SLA) performance and resolution efficiency across New York City agencies using public NYC 311 service request data.

The analysis focuses on measuring operational performance, identifying SLA breaches, and highlighting service areas and agencies that contribute to delays. The workflow mirrors a real-world data analytics process, from raw data ingestion to KPI reporting and dashboard delivery.

---

## Objective

- Measure SLA compliance over time  
- Evaluate agency-level performance  
- Identify complaint types with long resolution times  
- Support operational decision-making through KPI-driven analysis  

---

## Tools & Technologies

- **DuckDB** – Analytical SQL processing  
- **SQL** – Data cleaning, transformations, KPI aggregation  
- **Power BI** – Dashboarding and visual analysis  
- **NYC Open Data** – 311 Service Requests dataset  

---

## Data Processing

### Data Ingestion
- Loaded raw NYC 311 service request data into DuckDB
- Handled real-world data quality issues including:
  - Invalid timestamps
  - Missing values
  - Inconsistent formatting

### Data Cleaning & Feature Engineering
- Parsed request creation and closure timestamps
- Calculated resolution duration in hours
- Removed records with invalid or negative resolution times
- Created derived fields for time-based analysis
- Implemented SLA breach logic based on resolution thresholds

Final cleaned dataset:


---

## KPI Tables

### Monthly SLA Performance
`kpi_monthly_sla`
- Total requests
- SLA breach count
- SLA breach rate
- Month-over-month trends

### Agency Performance
`kpi_agency_performance`
- Request volume by agency
- Median resolution time
- SLA breach rate

### Complaint Type Analysis
`kpi_problem_resolution`
- Requests by complaint type
- Median resolution time
- Identification of operational bottlenecks

---

## Power BI Dashboard

### Page 1 – Executive Overview
- Total requests
- Total SLA breaches
- SLA breach rate
- Median resolution time

Purpose: Monitor overall SLA performance and trends.

---

### Page 2 – Agency Performance
- SLA breach rate by agency
- Median resolution time by agency
- Detailed performance table
- Filters by month and agency

Purpose: Identify underperforming agencies and prioritise intervention.

---

### Page 3 – Complaint Analysis
- Median resolution time by complaint type
- Volume vs resolution time scatter analysis
- Summary table for bottleneck identification

Purpose: Support root-cause analysis and process optimisation.

---

## Key Findings

- High-volume complaint types such as Snow or Ice and Heat/Hot Water exhibit longer median resolution times, indicating systemic operational challenges.
- Certain agencies show consistently higher SLA breach rates, suggesting capacity or workflow constraints.
- Combining volume and resolution time highlights issues with the greatest operational impact.

---




