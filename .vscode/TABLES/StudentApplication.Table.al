table 50031 "Student Application"
{

    fields
    {
        field(1; FirstName; Text[30])
        {

            trigger OnValidate()
            begin
                GetFullName;
                //SendCust;
            end;
        }
        field(2; MiddleName; Text[30])
        {

            trigger OnValidate()
            begin
                GetFullName;
            end;
        }
        field(3; SurName; Text[30])
        {

            trigger OnValidate()
            begin
                GetFullName;
            end;
        }
        field(4; FullName; Text[50])
        {

            trigger OnValidate()
            begin
                GetFullName();
                //SendCust();
            end;
        }
        field(5; Gender; Option)
        {
            OptionMembers = Male," Female"," Other";
        }
        field(6; DateOfBirth; Date)
        {

            trigger OnValidate()
            begin
                GetAge;
            end;
        }
        field(7; Age; Integer)
        {

            trigger OnValidate()
            begin
                GetAge;
            end;
        }
        field(8; Course; Integer)
        {
            TableRelation = "Course Setup".CourseNo;

            trigger OnValidate()
            begin

                unitcode.RESET;
                unitcode.SETRANGE("Unit No", Course);
                IF unitcode.FIND('-') THEN BEGIN
                    REPEAT
                        IF allunits = '' THEN
                            allunits := unitcode."Unit Description"
                        ELSE
                            allunits += ',' + unitcode."Unit Description";
                    UNTIL unitcode.NEXT = 0;
                END;
                Units := allunits;
                SendCust;
            end;
        }
        field(9; "Academic Year"; Integer)
        {
            TableRelation = "Academic Year Setup".AcademicYear;
        }
        field(10; Semester; Text[30])
        {
            TableRelation = "Semester Setup".Semester;

            trigger OnValidate()
            begin
                GetSem;
                MESSAGE('Student ID is %1', No2);
            end;
        }
        field(11; Units; Text[250])
        {
            Editable = false;
            TableRelation = "Unit Setup"."Unit No.";
        }
        field(12; TutionCharge; Integer)
        {
            Editable = false;
            TableRelation = "Student Finance".Arrears;

            trigger OnValidate()
            begin
                //SendName;
                //PopulateStatus;
            end;
        }
        field(13; PaidTution; Integer)
        {
            Editable = false;
            TableRelation = "Student Finance".PaidFees;
        }
        field(14; ApprovalStatus; Option)
        {
            Editable = false;
            Enabled = true;
            OptionMembers = Open,"Pending Approval",Released,Rejected,Delegated,Approved;
        }
        field(15; No; Code[30])
        {

            trigger OnValidate()
            begin
                IF No <> xRec.No THEN BEGIN
                    StudentMgt.GET;
                    NoSeriesMgt.TestManual(StudentMgt.CF);
                    "No.Series" := '';
                    NoSeriesMgt.SetSeries(No);
                END;
                //SendCust();
            end;
        }
        field(16; No2; Integer)
        {
            AutoIncrement = true;
        }
        field(17; "No.Series"; Code[30])
        {
            TableRelation = "No. Series";
        }
        field(18; Originality; Code[50])
        {
            TableRelation = "Student Origin Setup".Originality;
        }
        field(19; "Payment Terms Code"; Code[50])
        {
            TableRelation = "Payment Terms";
        }
    }

    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        SendName();
        SendFName();
        IF No = '' THEN BEGIN
            StudentMgt.GET;
            NoSeriesMgt.InitSeries(StudentMgt.CF, xRec."No.Series", 0D, No, "No.Series");
            //SendCust;
        END;
    end;

    var
        SpringSem: Date;
        SummerSem: Date;
        FallSem: Date;
        //units4sem: Record "Unit Setup";
        Stufinance: Record "Student Finance";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        StudentMgt: Record "Student Management Setup";
        Stufinanceacc: Record "Student Finance Account";
        unitcode: Record "Unit Code Setup";
        allunits: Text;
        customer: Record "Customer";
        STCW: Record "STCW";

    local procedure GetFullName()
    begin
        FullName := FirstName + ' ' + MiddleName + ' ' + SurName;
    end;

    local procedure GetAge()
    var
        StudentManagementSetup: Record "Student Management Setup";
        Difference: Integer;
        MinimumAge: Integer;
        MaximumAge: Integer;
    begin
        StudentManagementSetup.GET;
        Difference := (TODAY) - (DateOfBirth);
        Age := ROUND((Difference / 365), 1, '>');
        MinimumAge := StudentManagementSetup.MinimumAge;
        MaximumAge := StudentManagementSetup.MaximumAge;
        IF (Age > MaximumAge) OR (Age < MinimumAge) THEN
            ERROR('The entered age does not qualify for application');
    end;

    local procedure GetSem()
    var
        SemesterGlobalFunction: Record "Semester Setup";
    begin
        SpringSem := DMY2DATE(12, 1, 2023);
        SummerSem := DMY2DATE(15, 4, 2023);
        FallSem := DMY2DATE(10, 8, 2023);

        //Checking for Spring Semester
        IF (Semester = 'Spring Semester') THEN
            IF (TODAY > SpringSem) THEN
                ERROR('Past Spring Semester registration deadline');


        //Checking for Summer Semester
        IF (Semester = 'Summer Semester') THEN
            IF (TODAY > SummerSem) THEN
                ERROR('Past Summer Semester registration deadline');


        //Checking for Fall Semester
        IF (Semester = 'Fall Semester') THEN
            IF (TODAY > FallSem) THEN
                ERROR('Past Fall Semester registration deadline');

        IF (ApprovalStatus = ApprovalStatus::Open) THEN
            MESSAGE('Go to the Actions Tab and click on Request Approval to submit your application');
    end;

    local procedure SendName()
    var
        Getfinance: Record "Student Finance";
        Getfinance2: Record "Student Finance";
    begin
        Getfinance2.RESET;
        Getfinance2.FINDLAST;

        Getfinance2.INIT;
        Getfinance."No." := Getfinance2."No." + 1;
        Getfinance.Name := SurName;
        Getfinance.TuitionFees := 130000;
        Getfinance.ActivityFees := 5000;
        Getfinance.LibraryFees := 5000;
        Getfinance.PaidFees := 0;
        Getfinance.Arrears := Getfinance.TuitionFees + Getfinance.ActivityFees + Getfinance.LibraryFees - Getfinance.PaidFees;
        Getfinance.INSERT;

        TutionCharge := Getfinance.Arrears;
        PaidTution := Getfinance.PaidFees;
    end;

    local procedure SendFName()
    var
        StudentAcc: Record "Student Finance Account";
        StudentAcc2: Record "Student Finance Account";
    begin
        StudentAcc2.RESET;
        StudentAcc2.FINDLAST;

        StudentAcc2.INIT;
        StudentAcc.PK := 10000;
        StudentAcc.FirstName := FirstName;
        StudentAcc.MiddleName := MiddleName;
        StudentAcc.SurName := SurName;
        StudentAcc.FullName := FullName;
        StudentAcc.Year := "Academic Year";
        StudentAcc.AmountDue := 140000;
        StudentAcc.Balance := StudentAcc.AmountDue;
        StudentAcc.Authorizer := StudentAcc.Authorizer::"Acc. Kimberly Von";
        StudentAcc.Date := TODAY;
        StudentAcc.PK := No2;
        StudentAcc.INSERT;
    end;

    local procedure SendCust()
    var
        SFCW: Record "Unit Code Setup";
    begin
    end;
}
