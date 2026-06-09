--STEP 1 - VERIFY CURRENT ROW COUNTS
SELECT COUNT(*) AS Patients
FROM Patient;
SELECT COUNT(*) AS Encounters
FROM Encounter;
SELECT COUNT(*) AS Diagnoses
FROM Diagnosis;
SELECT COUNT(*) AS Claims
FROM Claim;

--STEP 2 - CREATE A PERFORMANCE TEST PATIENT
INSERT INTO Patient
(
Mrn,
FullName,
DateOfBirth,
Gender,
City,
IsActive
)
VALUES
(
'MRN999999',
'Rahul Verma',
'1985-06-15',
'M',
'Hyderabad',
1
);

--STEP 3 - VERIFY PATIENT ID
SELECT *
FROM Patient
WHERE Mrn = 'MRN999999';

--STEP 4 - CREATE 500 ENCOUNTERS
INSERT INTO Encounter
(
PatientId,
ProviderId,
DepartmentId,
AdmitDate,
DischargeDate,
EncounterType
)
SELECT
1003,
1,
1,
DATEADD(DAY,-v.number,GETDATE()),
GETDATE(),
'Outpatient'
FROM master..spt_values v
WHERE v.type = 'P'
AND v.number < 500;

--STEP 5 - VERIFY ENCOUNTERS
SELECT COUNT(*) AS EncounterCount
FROM Encounter
WHERE PatientId = 1003;

--STEP 6 - CREATE DIAGNOSES
INSERT INTO Diagnosis
(
EncounterId,
IcdCode,
Description,
DiagnosedOn
)
SELECT
EncounterId,
'I10',
'Hypertension',
GETDATE()
FROM Encounter
WHERE PatientId = 1003;

--STEP 7 - VERIFY DIAGNOSES
SELECT COUNT(*) AS DiagnosisCount
FROM Diagnosis d
INNER JOIN Encounter e
ON d.EncounterId = e.EncounterId
WHERE e.PatientId = 1003;

--STEP 8 - CREATE CLAIMS
INSERT INTO Claim
(
EncounterId,
InsuranceId,
BilledAmount,
ReimbursedAmt,
Status
)
SELECT
EncounterId,
1,
15000,
12000,
'Paid'
FROM Encounter
WHERE PatientId = 1003;

--STEP 9 - VERIFY CLAIMS
SELECT COUNT(*) AS ClaimCount
FROM Claim c
INNER JOIN Encounter e
ON c.EncounterId = e.EncounterId
WHERE e.PatientId = 1003;

--STEP 10 - CREATE EVEN MORE DATA
INSERT INTO Encounter
(
PatientId,
ProviderId,
DepartmentId,
AdmitDate,
DischargeDate,
EncounterType
)
SELECT
p.PatientId,
1,
1,
DATEADD(DAY,-ABS(CHECKSUM(NEWID())) % 365,GETDATE()),
GETDATE(),
'Outpatient'
FROM Patient p
CROSS JOIN
(
SELECT TOP 20
ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS N
FROM sys.objects
) x;

--STEP 11 - CREATE DIAGNOSES FOR NEW ENCOUNTERS
INSERT INTO Diagnosis
(
EncounterId,
IcdCode,
Description,
DiagnosedOn
)
SELECT
EncounterId,
'I10',
'Hypertension',
GETDATE()
FROM Encounter
WHERE EncounterId NOT IN
(
SELECT DISTINCT EncounterId
FROM Diagnosis
);

--STEP 12 - CREATE CLAIMS FOR NEW ENCOUNTERS
INSERT INTO Claim
(
EncounterId,
InsuranceId,
BilledAmount,
ReimbursedAmt,
Status
)
SELECT
EncounterId,
1,
15000,
12000,
'Paid'
FROM Encounter
WHERE EncounterId NOT IN
(
SELECT DISTINCT EncounterId
FROM Claim
);

--FINAL VERIFICATION
SELECT COUNT(*) AS Patients
FROM Patient;
SELECT COUNT(*) AS Encounters
FROM Encounter;
SELECT COUNT(*) AS Diagnoses
FROM Diagnosis;
SELECT COUNT(*) AS Claims
FROM Claim;




