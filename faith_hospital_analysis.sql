-- ============================================================
-- FAITH SPECIALIST HOSPITAL — PATIENT DATA ANALYSIS
-- Tool        : PostgreSQL
-- Author      : Annabel Uliyemi
-- Date        : 2025
-- Description : End-to-end SQL analysis of hospital patient data
--               covering demographics, chronic illness, lifestyle
--               risk factors, DAMA, mortality, and doctor performance.
-- Dashboard   : https://public.tableau.com/views/FaithHospital/DemographicsDashboard
-- Write-up    : https://medium.com/@annabeluliyemi/faith-hospital-analysis-using-sql-7c50e9aedd78
-- ============================================================


-- ============================================================
-- SECTION 1: TABLE CREATION
-- ============================================================

-- 1.1 Patients Table
CREATE TABLE patients (
    pt_id              INT PRIMARY KEY,
    pt_name            VARCHAR(50),
    age                TEXT,          -- imported as TEXT due to blank cells; cast to INT after cleaning
    sex                VARCHAR(2),
    occupation         VARCHAR(50),
    level_of_education VARCHAR(30),
    marital_status     VARCHAR(20)
);

-- 1.2 Doctors Table
-- NOTE: Duplicate entries for doctor_id D004 and D009 were removed before import
CREATE TABLE doctors (
    doctor_id      VARCHAR(10) PRIMARY KEY,
    doctor         VARCHAR(50),
    gender         VARCHAR(10),
    email          VARCHAR(50),
    specialization VARCHAR(50)
);

-- 1.3 Admissions Table
CREATE TABLE admissions (
    admission_id           INT PRIMARY KEY,
    pt_id                  INT REFERENCES patients(pt_id),
    admission_duration     INT,
    doctor_id              VARCHAR(10) REFERENCES doctors(doctor_id),
    dama                   VARCHAR(10),
    reason_for_dama        VARCHAR(50),
    dead                   VARCHAR(10),
    cause_of_death         VARCHAR(50),
    ckd                    VARCHAR(10),
    cause_of_ckd           VARCHAR(50),
    dialysis               VARCHAR(10),
    no_of_sessions         INT,
    stroke                 VARCHAR(10),
    dm                     VARCHAR(10),
    cancer                 VARCHAR(10),
    type_of_cancer         VARCHAR(50),
    pud                    VARCHAR(10)
);

-- 1.4 Risk Factors Table
CREATE TABLE risk_factors (
    pt_id        INT REFERENCES patients(pt_id),
    alcohol_use  VARCHAR(10),
    tobacco_use  VARCHAR(10),
    nsaid_use    VARCHAR(10)
);


-- ============================================================
-- SECTION 2: DATA CLEANING
-- ============================================================

-- ── 2.1 PATIENTS TABLE ───────────────────────────────────────

-- Check for NULL or blank values
SELECT *
FROM patients
WHERE pt_id IS NULL
   OR pt_name IS NULL OR pt_name = ''
   OR age IS NULL
   OR sex IS NULL OR sex = ''
   OR occupation IS NULL OR occupation = ''
   OR level_of_education IS NULL OR level_of_education = ''
   OR marital_status IS NULL OR marital_status = '';

-- Fill blanks with 'Not Stated' (25 out of 1478 records affected)
UPDATE patients
SET
    level_of_education = CASE
        WHEN level_of_education IS NULL OR TRIM(level_of_education) = '' THEN 'Not Stated'
        ELSE level_of_education
    END,
    marital_status = CASE
        WHEN marital_status IS NULL OR TRIM(marital_status) = '' THEN 'Not Stated'
        ELSE marital_status
    END,
    occupation = CASE
        WHEN occupation IS NULL OR TRIM(occupation) = '' THEN 'Not Stated'
        ELSE occupation
    END;

-- Identify non-numeric values in the age column
SELECT age
FROM patients
WHERE age !~ '^\d+$';

-- Replace blank age values with average age (54)
UPDATE patients
SET age = '54'
WHERE age = '';

-- Convert age from TEXT back to INTEGER
ALTER TABLE patients
ALTER COLUMN age TYPE INTEGER USING age::integer;

-- Create age category column
ALTER TABLE patients ADD COLUMN age_category VARCHAR;

UPDATE patients
SET age_category = CASE
    WHEN age BETWEEN 1  AND 17 THEN 'Child'
    WHEN age BETWEEN 18 AND 40 THEN 'Young Adult'
    WHEN age BETWEEN 41 AND 64 THEN 'Middle-Aged'
    ELSE 'Senior'
END;

-- Standardise sex values to 'M' / 'F'
UPDATE patients
SET sex = CASE
    WHEN sex = 'm' THEN 'M'
    WHEN sex = 'f' THEN 'F'
    ELSE sex
END;

-- Standardise education level labels
UPDATE patients
SET level_of_education = CASE
    WHEN level_of_education = 'Ssce'                              THEN 'Secondary School'
    WHEN level_of_education IN ('Fslc', 'Flsc')                   THEN 'Primary School'
    WHEN level_of_education IN ('Nce', 'Hnd')                     THEN 'Diploma'
    WHEN level_of_education IN ('Bsc','ba','BA','Ba','B.A','B.Ed','Undergraduate') THEN 'Bachelors'
    WHEN level_of_education = 'Msc'                               THEN 'Masters'
    ELSE level_of_education
END;

-- ── 2.2 ADMISSIONS TABLE ─────────────────────────────────────

-- Create admission duration category column
ALTER TABLE admissions ADD COLUMN admission_duration_category VARCHAR(20);

UPDATE admissions
SET admission_duration_category = CASE
    WHEN admission_duration BETWEEN 1  AND 7  THEN 'Short Stay'
    WHEN admission_duration BETWEEN 8  AND 14 THEN 'Medium Stay'
    WHEN admission_duration BETWEEN 15 AND 40 THEN 'Long Stay'
    WHEN admission_duration > 40              THEN 'Extended Stay'
END;

-- Standardise DAMA reason label
UPDATE admissions
SET reason_for_dama = REPLACE(reason_for_dama, 'Financial Incapability', 'Financial Constraint');

-- Risk Factors and Doctors tables were clean on import — no changes required.


-- ============================================================
-- SECTION 3: EXPLORATORY ANALYSIS
-- ============================================================

-- ── 3.1 PATIENT DEMOGRAPHICS ─────────────────────────────────

-- Age category distribution
SELECT age_category,
       COUNT(*) AS total_patients
FROM patients
GROUP BY age_category
ORDER BY total_patients DESC;

-- Sex distribution
SELECT TRIM(sex)        AS sex,
       COUNT(*)         AS total_patients
FROM patients
GROUP BY TRIM(sex)
ORDER BY total_patients DESC;

-- Marital status distribution
SELECT TRIM(marital_status) AS marital_status,
       COUNT(*)              AS total_patients
FROM patients
GROUP BY TRIM(marital_status)
ORDER BY total_patients DESC;

-- Occupation distribution
SELECT TRIM(occupation) AS occupation,
       COUNT(*)         AS total_patients
FROM patients
GROUP BY TRIM(occupation)
ORDER BY total_patients DESC;

-- Education level distribution
SELECT TRIM(level_of_education) AS level_of_education,
       COUNT(*)                  AS total_patients
FROM patients
GROUP BY TRIM(level_of_education)
ORDER BY total_patients DESC;


-- ── 3.2 ADMISSIONS, ILLNESS & OUTCOMES ───────────────────────

-- Average admission duration (days)
SELECT ROUND(AVG(admission_duration), 2) AS avg_admission_days
FROM admissions;

-- Mortality count (dead vs alive)
SELECT dead,
       COUNT(*) AS total_patients
FROM admissions
GROUP BY dead;

-- Top causes of death
SELECT cause_of_death,
       COUNT(*) AS total_patients
FROM admissions
WHERE dead = 'Yes'
GROUP BY cause_of_death
ORDER BY total_patients DESC;

-- Chronic illness prevalence across all patients
SELECT
    COUNT(CASE WHEN ckd    = 'Yes' THEN 1 END) AS ckd_count,
    COUNT(CASE WHEN stroke = 'Yes' THEN 1 END) AS stroke_count,
    COUNT(CASE WHEN dm     = 'Yes' THEN 1 END) AS diabetes_count,
    COUNT(CASE WHEN cancer = 'Yes' THEN 1 END) AS cancer_count,
    COUNT(CASE WHEN pud    = 'Yes' THEN 1 END) AS pud_count
FROM admissions;

-- Admission duration category distribution
SELECT admission_duration_category,
       COUNT(*) AS total_admissions
FROM admissions
GROUP BY admission_duration_category
ORDER BY total_admissions DESC;


-- ── 3.3 RISK FACTOR ANALYSIS ─────────────────────────────────

-- Overall risk factor prevalence
SELECT
    COUNT(CASE WHEN alcohol_use = 'Yes' THEN 1 END) AS alcohol_users,
    COUNT(CASE WHEN alcohol_use = 'No'  THEN 1 END) AS non_alcohol_users,
    COUNT(CASE WHEN tobacco_use = 'Yes' THEN 1 END) AS tobacco_users,
    COUNT(CASE WHEN tobacco_use = 'No'  THEN 1 END) AS non_tobacco_users,
    COUNT(CASE WHEN nsaid_use   = 'Yes' THEN 1 END) AS nsaid_users,
    COUNT(CASE WHEN nsaid_use   = 'No'  THEN 1 END) AS non_nsaid_users
FROM risk_factors;

-- Impact of ALCOHOL use on chronic disease rates
SELECT
    COUNT(DISTINCT rf.pt_id)                                                               AS total_alcohol_users,
    SUM(CASE WHEN a.stroke = 'Yes' THEN 1 ELSE 0 END)                                     AS stroke_cases,
    ROUND(100.0 * SUM(CASE WHEN a.stroke = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS stroke_pct,
    SUM(CASE WHEN a.dm     = 'Yes' THEN 1 ELSE 0 END)                                     AS diabetes_cases,
    ROUND(100.0 * SUM(CASE WHEN a.dm     = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS diabetes_pct,
    SUM(CASE WHEN a.ckd    = 'Yes' THEN 1 ELSE 0 END)                                     AS ckd_cases,
    ROUND(100.0 * SUM(CASE WHEN a.ckd    = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS ckd_pct,
    SUM(CASE WHEN a.cancer = 'Yes' THEN 1 ELSE 0 END)                                     AS cancer_cases,
    ROUND(100.0 * SUM(CASE WHEN a.cancer = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS cancer_pct,
    SUM(CASE WHEN a.pud    = 'Yes' THEN 1 ELSE 0 END)                                     AS pud_cases,
    ROUND(100.0 * SUM(CASE WHEN a.pud    = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS pud_pct
FROM risk_factors rf
JOIN admissions a ON rf.pt_id = a.pt_id
WHERE rf.alcohol_use = 'Yes';

-- Impact of TOBACCO use on chronic disease rates
SELECT
    COUNT(DISTINCT rf.pt_id)                                                               AS total_tobacco_users,
    SUM(CASE WHEN a.stroke = 'Yes' THEN 1 ELSE 0 END)                                     AS stroke_cases,
    ROUND(100.0 * SUM(CASE WHEN a.stroke = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS stroke_pct,
    SUM(CASE WHEN a.dm     = 'Yes' THEN 1 ELSE 0 END)                                     AS diabetes_cases,
    ROUND(100.0 * SUM(CASE WHEN a.dm     = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS diabetes_pct,
    SUM(CASE WHEN a.ckd    = 'Yes' THEN 1 ELSE 0 END)                                     AS ckd_cases,
    ROUND(100.0 * SUM(CASE WHEN a.ckd    = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS ckd_pct,
    SUM(CASE WHEN a.cancer = 'Yes' THEN 1 ELSE 0 END)                                     AS cancer_cases,
    ROUND(100.0 * SUM(CASE WHEN a.cancer = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS cancer_pct,
    SUM(CASE WHEN a.pud    = 'Yes' THEN 1 ELSE 0 END)                                     AS pud_cases,
    ROUND(100.0 * SUM(CASE WHEN a.pud    = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS pud_pct
FROM risk_factors rf
JOIN admissions a ON rf.pt_id = a.pt_id
WHERE rf.tobacco_use = 'Yes';

-- Impact of NSAID use on chronic disease rates
SELECT
    COUNT(DISTINCT rf.pt_id)                                                               AS total_nsaid_users,
    SUM(CASE WHEN a.stroke = 'Yes' THEN 1 ELSE 0 END)                                     AS stroke_cases,
    ROUND(100.0 * SUM(CASE WHEN a.stroke = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS stroke_pct,
    SUM(CASE WHEN a.dm     = 'Yes' THEN 1 ELSE 0 END)                                     AS diabetes_cases,
    ROUND(100.0 * SUM(CASE WHEN a.dm     = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS diabetes_pct,
    SUM(CASE WHEN a.ckd    = 'Yes' THEN 1 ELSE 0 END)                                     AS ckd_cases,
    ROUND(100.0 * SUM(CASE WHEN a.ckd    = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS ckd_pct,
    SUM(CASE WHEN a.cancer = 'Yes' THEN 1 ELSE 0 END)                                     AS cancer_cases,
    ROUND(100.0 * SUM(CASE WHEN a.cancer = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS cancer_pct,
    SUM(CASE WHEN a.pud    = 'Yes' THEN 1 ELSE 0 END)                                     AS pud_cases,
    ROUND(100.0 * SUM(CASE WHEN a.pud    = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT rf.pt_id), 2) AS pud_pct
FROM risk_factors rf
JOIN admissions a ON rf.pt_id = a.pt_id
WHERE rf.nsaid_use = 'Yes';


-- ── 3.4 DISCHARGE AGAINST MEDICAL ADVICE (DAMA) ──────────────

-- Overall DAMA distribution
SELECT dama,
       COUNT(*) AS total_patients
FROM admissions
GROUP BY dama;

-- Reasons for DAMA
SELECT reason_for_dama,
       COUNT(*) AS total_patients
FROM admissions
WHERE dama = 'Yes'
GROUP BY reason_for_dama
ORDER BY total_patients DESC;

-- Chronic illness burden among DAMA patients
SELECT
    COUNT(CASE WHEN ckd      = 'Yes' THEN 1 END) AS ckd_count,
    COUNT(CASE WHEN stroke   = 'Yes' THEN 1 END) AS stroke_count,
    COUNT(CASE WHEN dm       = 'Yes' THEN 1 END) AS diabetes_count,
    COUNT(CASE WHEN pud      = 'Yes' THEN 1 END) AS pud_count,
    COUNT(CASE WHEN dialysis = 'Yes' THEN 1 END) AS dialysis_count,
    COUNT(CASE WHEN cancer   = 'Yes' THEN 1 END) AS cancer_count
FROM admissions
WHERE dama = 'Yes';

-- Mortality among DAMA patients
SELECT
    COUNT(CASE WHEN dead = 'Yes' THEN 1 END) AS died_after_dama,
    COUNT(CASE WHEN dead = 'No'  THEN 1 END) AS survived_after_dama
FROM admissions
WHERE dama = 'Yes';

-- Occupation breakdown of DAMA patients
SELECT p.occupation,
       COUNT(*) AS patient_count
FROM admissions a
JOIN patients p ON a.pt_id = p.pt_id
WHERE a.dama = 'Yes'
GROUP BY p.occupation
ORDER BY patient_count DESC;

-- Education level breakdown of DAMA patients
SELECT p.level_of_education,
       COUNT(*) AS patient_count
FROM admissions a
JOIN patients p ON a.pt_id = p.pt_id
WHERE a.dama = 'Yes'
GROUP BY p.level_of_education
ORDER BY patient_count DESC;

-- Age category breakdown of DAMA patients
SELECT p.age_category,
       COUNT(*) AS patient_count
FROM admissions a
JOIN patients p ON a.pt_id = p.pt_id
WHERE a.dama = 'Yes'
GROUP BY p.age_category
ORDER BY patient_count DESC;


-- ── 3.5 DOCTOR PERFORMANCE ANALYSIS ──────────────────────────

-- Gender distribution of doctors
SELECT gender,
       COUNT(*) AS total_doctors
FROM doctors
GROUP BY gender;

-- Number of doctors per specialization
SELECT specialization,
       COUNT(*) AS total_doctors
FROM doctors
GROUP BY specialization
ORDER BY total_doctors DESC;

-- Patient volume per specialization (workload by department)
SELECT d.specialization,
       COUNT(a.pt_id) AS patient_count
FROM admissions a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.specialization
ORDER BY patient_count DESC;

-- Patient volume per individual doctor
SELECT d.doctor,
       d.specialization,
       COUNT(a.pt_id) AS patient_count
FROM admissions a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor, d.specialization
ORDER BY patient_count DESC;

-- Top 5 doctors by number of patient deaths
SELECT d.doctor,
       d.specialization,
       COUNT(*) AS total_deaths
FROM admissions a
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.dead = 'Yes'
GROUP BY d.doctor, d.specialization
ORDER BY total_deaths DESC
LIMIT 5;

-- Deaths by specialization
SELECT d.specialization,
       COUNT(*) AS total_deaths
FROM admissions a
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.dead = 'Yes'
GROUP BY d.specialization
ORDER BY total_deaths DESC;

-- Top 5 doctors with the most DAMA patients
SELECT d.doctor,
       d.specialization,
       COUNT(*) AS total_dama
FROM admissions a
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.dama = 'Yes'
GROUP BY d.doctor, d.specialization
ORDER BY total_dama DESC
LIMIT 5;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================
