CREATE VIEW vw_DropoutRisk AS
SELECT
    s.StudentID,
    s.FullName,
    p.Term,
    s.Gender,
    s.Age,
    s.ClassLevel,
    s.ParentEngagement,
    s.EnrollmentStatus,
    p.AttendanceRate,
    p.AverageScore,
    p.BehaviorScore,
    f.TotalFees,
    f.AmountPaid,
    f.Balance,
    f.PaymentDate,

    -- Dropout Risk Indicators
    CASE WHEN p.AttendanceRate < 60 THEN 1 ELSE 0 END AS PoorAttendanceFlag,
    CASE WHEN p.AverageScore < 50 THEN 1 ELSE 0 END AS LowGradesFlag,
    CASE WHEN f.Balance > 0 THEN 1 ELSE 0 END AS UnpaidFeesFlag,
    CASE WHEN p.BehaviorScore < 40 THEN 1 ELSE 0 END AS PoorBehaviorFlag,
    CASE 
        WHEN s.ParentEngagement = 'Low' THEN 1
        ELSE 0
    END AS LowParentalInvolvementFlag,

    -- Risk Score (Sum of Flags)
    (
        CASE WHEN p.AttendanceRate < 60 THEN 1 ELSE 0 END +
        CASE WHEN p.AverageScore < 50 THEN 1 ELSE 0 END +
        CASE WHEN f.Balance > 0 THEN 1 ELSE 0 END +
        CASE WHEN p.BehaviorScore < 40 THEN 1 ELSE 0 END +
        CASE 
            WHEN s.ParentEngagement = 'Low' THEN 1
            ELSE 0
        END
    ) AS DropoutRiskScore,

    -- Risk Level
    CASE
        WHEN (
            CASE WHEN p.AttendanceRate < 60 THEN 1 ELSE 0 END +
            CASE WHEN p.AverageScore < 50 THEN 1 ELSE 0 END +
            CASE WHEN f.Balance > 0 THEN 1 ELSE 0 END +
            CASE WHEN p.BehaviorScore < 40 THEN 1 ELSE 0 END +
            CASE 
                WHEN s.ParentEngagement = 'Low' THEN 1
                ELSE 0
            END
        ) >= 4 THEN 'High'
        WHEN (
            CASE WHEN p.AttendanceRate < 60 THEN 1 ELSE 0 END +
            CASE WHEN p.AverageScore < 50 THEN 1 ELSE 0 END +
            CASE WHEN f.Balance > 0 THEN 1 ELSE 0 END +
            CASE WHEN p.BehaviorScore < 40 THEN 1 ELSE 0 END +
            CASE 
                WHEN s.ParentEngagement = 'Low' THEN 1
                ELSE 0
            END
        ) BETWEEN 2 AND 3 THEN 'Medium'
        ELSE 'Low'
    END AS DropoutRiskLevel

FROM student s
LEFT JOIN performance p ON s.StudentID = p.StudentID
LEFT JOIN fees f ON s.StudentID = f.StudentID AND p.Term = f.Term;
