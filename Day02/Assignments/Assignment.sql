
--Assignment1
SELECT
    p.FullName,
	d.Name,
    COUNT(e.EncounterId) AS EncounterCount,
    DENSE_RANK()
    OVER (
		PARTITION BY d.Name
        ORDER BY COUNT(e.EncounterId) DESC
    ) AS VolumeRank
FROM Provider p
LEFT JOIN Encounter e
    ON e.ProviderId = p.ProviderId
JOIN Department d 
	ON p.DepartmentId = d.DepartmentId
GROUP BY
    p.ProviderId,
    p.FullName,
	d.Name;
	

--Assignment 2
ALTER TABLE Insurance
ADD
    ValidFrom DATETIME2
        GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_Insurance_From
        DEFAULT SYSUTCDATETIME(),

    ValidTo DATETIME2
        GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_Insurance_To
        DEFAULT '9999-12-31 23:59:59.9999999',

    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);

	ALTER TABLE Insurance
SET (
    SYSTEM_VERSIONING = ON
    (
        HISTORY_TABLE = dbo.Insurance_History
    )
);
--select PolicyNumber,PatientId From Insurance
Update Insurance
Set PolicyNumber = 'POL-546798-0'
Where PatientId = 1

Select
	PatientId,
	InsuranceId,
	Payer,
	PolicyNumber,
	ValidFrom,
	ValidTo
From Insurance
FOR SYSTEM_TIME ALL
WHERE PatientId=1


--Assignment 3
CREATE OR ALTER PROCEDURE usp_analytics
    @WithinDays INT = 30,
	@Deparment INT = 5
AS
BEGIN

    SET NOCOUNT ON;
	--Total Patients
	Select Count(*) AS TotalActivePatients
		FROM Patient
		Where IsActive = 1;

    -- Build a patient timeline

    WITH OrderedEncounters AS (

        SELECT

            PatientId,
            EncounterId,
            AdmitDate,

            LAG(DischargeDate)
                OVER (
                    PARTITION BY PatientId
                    ORDER BY AdmitDate
                ) AS PreviousDischarge

        FROM Encounter

        WHERE EncounterType = 'Inpatient'

    )

    -- Find readmissions

    SELECT

        PatientId,
        EncounterId,
        AdmitDate,

        DATEDIFF(
            DAY,
            PreviousDischarge,
            AdmitDate
        ) AS DaysSincePreviousVisit

    FROM OrderedEncounters

    WHERE PreviousDischarge IS NOT NULL

    AND DATEDIFF(
            DAY,
            PreviousDischarge,
            AdmitDate
        ) <= @WithinDays;
		--Top 5 Departments by Encounters
		SELECT TOP (@Deparment)
			d.NAME,
			COUNT(e.EncounterId) As EncounterCount
		FROM Department d
		JOIN Encounter e
		ON d.DepartmentId = e.DepartmentId
		Group By d.Name
		Order By EncounterCount DESC
		

		
END;


EXEC usp_analytics 
@WithinDays=30, @Deparment=5

--Assignment 4
CREATE OR ALTER PROCEDURE usp_executive_dashboard
AS
BEGIN
    SET NOCOUNT ON;

    -- Total Active Patients
    SELECT COUNT(*) AS TotalActivePatients
    FROM Patient
    WHERE IsActive = 1;

    -- Top 5 Departments by Encounters
    SELECT TOP (5)
        d.Name AS DepartmentName,
        COUNT(e.EncounterId) AS EncounterCount
    FROM Department d
    JOIN Encounter e
        ON d.DepartmentId = e.DepartmentId
    GROUP BY d.Name
    ORDER BY EncounterCount DESC;

    -- Average Length of Stay (Inpatient only)
    SELECT AVG(DATEDIFF(DAY, e.AdmitDate, e.DischargeDate)) AS AvgLengthOfStay
    FROM Encounter e
    WHERE e.EncounterType = 'Inpatient';

    -- Readmissions within 30 Days
    WITH OrderedEncounters AS (
        SELECT
            PatientId,
            EncounterId,
            AdmitDate,
            LAG(DischargeDate)
                OVER (PARTITION BY PatientId ORDER BY AdmitDate) AS PreviousDischarge
        FROM Encounter
        WHERE EncounterType = 'Inpatient'
    )
    SELECT COUNT(*) AS ReadmissionsIn30Days
    FROM OrderedEncounters
    WHERE PreviousDischarge IS NOT NULL
      AND DATEDIFF(DAY, PreviousDischarge, AdmitDate) <= 30;

    -- Denied Claims
    SELECT COUNT(*) AS DeniedClaims
    FROM Claim
    WHERE Status = 'Denied';

    -- Highest Workload Providers
    SELECT TOP (5)
        p.FullName,
        COUNT(e.EncounterId) AS EncounterCount
    FROM Provider p
    JOIN Encounter e
        ON p.ProviderId = e.ProviderId
    GROUP BY p.FullName
    ORDER BY EncounterCount DESC;

    -- Patients with 3+ Admissions
    SELECT
        PatientId,
        COUNT(EncounterId) AS AdmissionCount
    FROM Encounter
    WHERE EncounterType = 'Inpatient'
    GROUP BY PatientId
    HAVING COUNT(EncounterId) >= 3;
END;

EXEC usp_executive_dashboard;


--Assignment 5

CREATE OR ALTER PROCEDURE usp_clinical_operations
AS
BEGIN
    SET NOCOUNT ON;

    -- 30-Day Readmissions
    WITH OrderedEncounters AS (
        SELECT
            PatientId,
            EncounterId,
            AdmitDate,
            LAG(DischargeDate)
                OVER (PARTITION BY PatientId ORDER BY AdmitDate) AS PreviousDischarge
        FROM Encounter
        WHERE EncounterType = 'Inpatient'
    )
    SELECT
        PatientId,
        EncounterId,
        AdmitDate,
        DATEDIFF(DAY, PreviousDischarge, AdmitDate) AS DaysSincePreviousVisit
    FROM OrderedEncounters
    WHERE PreviousDischarge IS NOT NULL
      AND DATEDIFF(DAY, PreviousDischarge, AdmitDate) <= 30;

    -- High-Risk Patients (Age ≥ 65)
    SELECT
        PatientId,
        FullName,
        DateOfBirth,
        DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age
    FROM Patient
    WHERE DATEDIFF(YEAR, DateOfBirth, GETDATE()) >= 65
    ORDER BY Age DESC;

    -- Provider Workload
    SELECT
        p.FullName,
        d.Name AS DepartmentName,
        COUNT(e.EncounterId) AS EncounterCount
    FROM Provider p
    JOIN Department d
        ON p.DepartmentId = d.DepartmentId
    LEFT JOIN Encounter e
        ON e.ProviderId = p.ProviderId
    GROUP BY p.FullName, d.Name
    ORDER BY EncounterCount DESC;

    -- Revenue Analysis
    SELECT
        Status AS ClaimStatus,
        COUNT(*) AS TotalClaims,
        SUM(BilledAmount) AS TotalBilledAmount,
        SUM(ISNULL(ReimbursedAmt, 0)) AS TotalReimbursedAmount,
        SUM(BilledAmount - ISNULL(ReimbursedAmt, 0)) AS OutstandingAmount,
        RANK() OVER (ORDER BY SUM(BilledAmount - ISNULL(ReimbursedAmt, 0)) DESC) AS LossRank
    FROM Claim
    GROUP BY Status;
END;
GO

EXEC usp_clinical_operations;
GO

--Assignment 6

CREATE OR ALTER PROCEDURE usp_access_portal
    @Role NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- Clinical Team Access
    IF @Role = 'Clinical'
    BEGIN
        SELECT
            p.PatientId,
            p.FullName,
            e.EncounterId,
            e.EncounterType,
            e.AdmitDate,
            e.DischargeDate,
            d.IcdCode,
            d.Description AS DiagnosisDescription
        FROM Patient p
        JOIN Encounter e
            ON p.PatientId = e.PatientId
        LEFT JOIN Diagnosis d
            ON e.EncounterId = d.EncounterId;
    END;

    -- Billing Team Access
    IF @Role = 'Billing'
    BEGIN
        SELECT
            c.ClaimId,
            c.EncounterId,
            c.InsuranceId,
            i.Payer,
            i.PolicyNumber,
            c.BilledAmount,
            c.ReimbursedAmt,
            c.Status
        FROM Claim c
        JOIN Insurance i
            ON c.InsuranceId = i.InsuranceId;
    END;

    -- Analytics Team Access (De-identified)
    IF @Role = 'Analytics'
    BEGIN
        SELECT
            CASE
                WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) < 18 THEN '0-17'
                WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 18 AND 35 THEN '18-35'
                WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 36 AND 55 THEN '36-55'
                WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 56 AND 75 THEN '56-75'
                ELSE '76+'
            END AS AgeBand,
            e.EncounterType,
            e.DepartmentId
        FROM Patient p
        JOIN Encounter e
            ON p.PatientId = e.PatientId;
    END;
END;
GO

EXEC usp_access_portal @Role = 'Clinical';
EXEC usp_access_portal @Role = 'Billing';
EXEC usp_access_portal @Role = 'Analytics';
GO
