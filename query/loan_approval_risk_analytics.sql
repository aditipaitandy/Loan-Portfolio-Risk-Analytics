-- Customer loan master dataset

SELECT
    c.custID,
    c.Gender,
    c.Married,
    c.Dependents,
    c.Education,
    c.Self_Employed,
    c.ApplicantIncome,
    c.CoapplicantIncome,
    c.Credit_History,
    c.Property_Area,
    l.LoanAmount,
    l.Loan_Amount_Term,
    l.Loan_Status,
    d.DepositAmt,
    h.CCBalance,
    h.Card_Type
FROM `loans_db.customers` c
LEFT JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
LEFT JOIN `loans_db.DepositCustomers` d
ON c.custID = d.CustID
LEFT JOIN `loans_db.highCreditBalanceCustomers` h
ON c.custID = h.CustID;


-- Overall loan approval rate

SELECT
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = TRUE THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100 * SUM(CASE WHEN Loan_Status = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS approval_rate
FROM `loans_db.loans`;


-- Approval rate by gender

SELECT
    c.Gender,
    COUNT(*) AS applications,
    SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END) AS approved,
    ROUND(
        100 * SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS approval_rate
FROM `loans_db.customers` c
JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
GROUP BY c.Gender
ORDER BY approval_rate DESC;


-- Approval rate by education

SELECT
    c.Education,
    COUNT(*) AS applications,
    SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END) AS approved,
    ROUND(
        100 * SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS approval_rate
FROM `loans_db.customers` c
JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
GROUP BY c.Education
ORDER BY approval_rate DESC;


-- Approval rate by property area

SELECT
    c.Property_Area,
    COUNT(*) AS applications,
    SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END) AS approved,
    ROUND(
        100 * SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS approval_rate
FROM `loans_db.customers` c
JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
GROUP BY c.Property_Area
ORDER BY approval_rate DESC;


-- Average loan amount by property area

SELECT
    c.Property_Area,
    ROUND(AVG(l.LoanAmount), 2) AS avg_loan_amount
FROM `loans_db.customers` c
JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
GROUP BY c.Property_Area
ORDER BY avg_loan_amount DESC;


-- Top 10 highest income customers

SELECT
    custID,
    ApplicantIncome + CoapplicantIncome AS total_income
FROM `loans_db.customers`
ORDER BY total_income DESC
LIMIT 10;


-- Customer income ranking

SELECT
    custID,
    ApplicantIncome + CoapplicantIncome AS total_income,
    RANK() OVER (
        ORDER BY ApplicantIncome + CoapplicantIncome DESC
    ) AS income_rank
FROM `loans_db.customers`;


-- Income segmentation using NTILE

SELECT
    custID,
    ApplicantIncome + CoapplicantIncome AS total_income,
    NTILE(5) OVER (
        ORDER BY ApplicantIncome + CoapplicantIncome
    ) AS income_group
FROM `loans_db.customers`;


-- Credit history vs loan approval

SELECT
    c.Credit_History,
    COUNT(*) AS customers,
    SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END) AS approved,
    ROUND(
        100 * SUM(CASE WHEN l.Loan_Status = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS approval_rate
FROM `loans_db.customers` c
JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
GROUP BY c.Credit_History
ORDER BY approval_rate DESC;


-- Deposit segmentation

SELECT
    CASE
        WHEN DepositAmt >= 50000 THEN 'High Deposit'
        WHEN DepositAmt >= 20000 THEN 'Medium Deposit'
        ELSE 'Low Deposit'
    END AS deposit_segment,
    COUNT(*) AS customers
FROM `loans_db.DepositCustomers`
GROUP BY deposit_segment;


-- High-income customers rejected for loans

SELECT
    c.custID,
    (c.ApplicantIncome + c.CoapplicantIncome) AS total_income,
    l.LoanAmount
FROM `loans_db.customers` c
JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
WHERE l.Loan_Status = FALSE
ORDER BY total_income DESC;


-- Customer risk segmentation

SELECT
    c.custID,
    CASE
        WHEN c.Credit_History = 0
             AND l.LoanAmount > 200
        THEN 'High Risk'

        WHEN c.Credit_History = 1
             AND d.DepositAmt > 20000
        THEN 'Low Risk'

        ELSE 'Medium Risk'
    END AS risk_segment,
    l.LoanAmount,
    d.DepositAmt,
    h.CCBalance
FROM `loans_db.customers` c
JOIN `loans_db.loans` l
ON c.Loan_ID = l.Loan_ID
LEFT JOIN `loans_db.DepositCustomers` d
ON c.custID = d.CustID
LEFT JOIN `loans_db.highCreditBalanceCustomers` h
ON c.custID = h.CustID;


-- Average income by education

SELECT
    Education,
    ROUND(
        AVG(ApplicantIncome + CoapplicantIncome),
        2
    ) AS avg_income
FROM `loans_db.customers`
GROUP BY Education
ORDER BY avg_income DESC;


-- Loan applications by month

SELECT
    EXTRACT(YEAR FROM ApplicationDate) AS year,
    EXTRACT(MONTH FROM ApplicationDate) AS month,
    COUNT(*) AS applications
FROM `loans_db.loans`
GROUP BY year, month
ORDER BY year, month;