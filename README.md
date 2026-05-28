# 🏥 Faith Specialist Hospital — Patient Data Analysis (PostgreSQL)

Author: Annabel Uliyemi | Health Data Analyst & Registered Nurse  
Tool: PostgreSQL  
Viz:Tableau  
Read the full write-up: [Medium Article](https://medium.com/@annabeluliyemi/faith-hospital-analysis-using-sql-7c50e9aedd78)  
View the Dashboard: [Tableau Public](https://public.tableau.com/views/FaithHospital/DemographicsDashboard)


## 📌 Project Overview

This project analyses patient data from Faith Specialist Hospital using PostgreSQL to uncover trends in patient demographics, chronic illness prevalence, lifestyle risk factors, discharge against medical advice (DAMA), and doctor performance.

The goal was to translate raw clinical records into actionable insights that hospital management could use to improve patient retention, care quality, and resource allocation.


## 🗂️ Dataset

The dataset contains four related tables:

| Table | Description |
|---|---|
| `patients` | Demographics — age, sex, occupation, education, marital status |
| `admissions` | Clinical data — duration, chronic illness, DAMA, mortality |
| `doctors` | Doctor profiles — specialisation, gender |
| `risk_factors` | Lifestyle data — alcohol, tobacco, NSAID use per patient |


## 🔍 Key Questions Answered

- What does the typical Faith Hospital patient look like demographically?
- Which chronic illnesses are most prevalent in the patient population?
- How do lifestyle risk factors (alcohol, tobacco, NSAIDs) relate to chronic disease rates?
- Why are patients leaving against medical advice — and who is most at risk of DAMA?
- Which doctors and specialisations carry the highest patient volume and mortality load?


## 📊 Key Findings

- **Middle-aged patients (41–64)** made up the largest patient group
- **Chronic Kidney Disease (CKD)** was the most prevalent chronic illness
- Patients who used **tobacco had significantly higher rates** of stroke, diabetes, and CKD
- **Financial constraint** was the leading reason for DAMA — pointing to a systemic access-to-care problem
- DAMA patients had high rates of serious chronic illness, making early discharge a critical safety concern
- **Internal Medicine** carried the highest patient volume and mortality burden


## 🧰 SQL Techniques Used

- Table creation with primary and foreign key constraints
- Data cleaning: NULL handling, type conversion, value standardisation
- `CASE WHEN` logic for categorisation (age groups, admission duration)
- Aggregate functions: `COUNT`, `SUM`, `ROUND`, `AVG`
- Multi-table `JOIN` queries (patients ↔ admissions ↔ doctors ↔ risk_factors)
- Percentage calculations for risk factor analysis
- `GROUP BY` and `ORDER BY` for ranking and distribution analysis


## 📁 Files in This Repository

| File | Description |
|---|---|
| `faith_hospital_analysis.sql` | Full SQL script — table creation, cleaning, and all analysis queries |
| `README.md` | Project documentation (this file) |


## 📈 Dashboard

The findings were visualised in Tableau, covering patient demographics, chronic illness distribution, DAMA breakdown, and doctor performance metrics.

👉 [View the Tableau Dashboard](https://public.tableau.com/views/FaithHospital/DemographicsDashboard)


## 👩🏽‍💻 About Me

I'm a Health Data Analyst and Registered Nurse with hands-on experience in healthcare analytics, clinical research, and data visualisation. I specialise in healthcare datasets — maternal health, hospital operations, and public health analytics.

📧 annatanrose@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/annabel-uliyemi)  
🌐 [Portfolio](https://sites.google.com/view/annabeluliyemi/data-analysis-portfolio-and-certifications)  
✍️ [Medium](https://medium.com/@annabeluliyemi)
