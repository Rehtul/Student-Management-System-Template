table 50057 "Student Grade"
{

    fields
    {
        field(1; No; Code[30])
        {
            Editable = false;
            TableRelation = "Student Application".No;

            trigger OnValidate()
            begin
                StudentApp.RESET;
                StudentApp.SETRANGE(No, FirstName);
                IF StudentApp.FINDFIRST THEN BEGIN
                    No := StudentApp.No;
                    FirstName := StudentApp.FirstName;
                    MiddleName := StudentApp.MiddleName;
                    SurName := StudentApp.SurName;
                    FullName := FirstName + ' ' + MiddleName + ' ' + SurName;
                    Year := StudentApp."Academic Year";
                    Course := StudentApp.Course;
                    "Unit Code" := Course;
                    //Units := StudentApp.Units;
                END
            end;
        }
        field(2; FirstName; Text[50])
        {
            Editable = true;
            TableRelation = "Student Application".No;

            trigger OnValidate()
            begin
                StudentApp.RESET;
                StudentApp.SETRANGE(No, FirstName);
                IF StudentApp.FINDFIRST THEN BEGIN
                    No := StudentApp.No;
                    FirstName := StudentApp.FirstName;
                    MiddleName := StudentApp.MiddleName;
                    SurName := StudentApp.SurName;
                    FullName := FirstName + ' ' + MiddleName + ' ' + SurName;
                    Year := StudentApp."Academic Year";
                    Course := StudentApp.Course;
                    "Unit Code" := Course;
                    Semester := StudentApp.Semester;
                    //Units := StudentApp.Units;
                END;

                UnitCode.RESET;
                UnitCode.SETFILTER("Unit Name", 'Intro');
                IF (Course = UnitCode."Unit No") THEN BEGIN
                    "Unit Code" := UnitCode."Unit No";
                END;

                StudentGrad.RESET;
                StudentGrad.SETRANGE(PK, 0, 10000);
                IF StudentGrad.FINDLAST THEN BEGIN
                    PK := StudentGrad.PK + 1;
                END;
            end;
        }
        field(3; MiddleName; Text[50])
        {
            Editable = false;
        }
        field(4; SurName; Text[250])
        {
            Editable = false;
        }
        field(5; FullName; Text[250])
        {
            Editable = false;
        }
        field(6; Year; Integer)
        {
            Editable = false;
        }
        field(7; Course; Integer)
        {
            Editable = false;
        }
        field(8; Units; Text[250])
        {
            Editable = true;
            TableRelation = "Unit Code Setup"."Unit Name" WHERE("Unit No" = FIELD(Course));
        }
        field(9; CAT1; Integer)
        {

            trigger OnValidate()
            begin
                IF (CAT1 < 0) OR (CAT1 > 20) THEN
                    ERROR('Please enter a valid Mark out of 20. Please dont enter a student' +
                            'with irregularities or pending issues');
            end;
        }
        field(10; CAT2; Integer)
        {

            trigger OnValidate()
            begin
                IF (CAT2 < 0) OR (CAT2 > 20) THEN
                    ERROR('Please enter a valid Mark out of 20. Please dont enter a student' +
                            'with irregularities or pending issues');
            end;
        }
        field(11; Final; Integer)
        {

            trigger OnValidate()
            begin
                Cats := CAT1 + CAT2;
                Totals := Cats + Final;
                IF (Final < 0) OR (Final > 60) THEN
                    ERROR('Please enter a valid Mark out of 40. Please dont enter a student' +
                            'with irregularities or pending issues');
                //Overall := ROUND((Totals/25),0.01);
                //MESSAGE('%1',Overall);

                //IF (GPA >= 3.8) OR (GPA < 4.0) THEN
                //  Grade := 'A';
                //  Condition := Condition::Passed;
                //  Supplementary := Supplementary::No;



                //IF (GPA >= 3.5) OR (GPA < 3.8) THEN
                //  Grade := 'B';
                //  Condition := Condition::Passed;
                //  Supplementary := Supplementary::No;

                //IF (GPA >= 2.7) OR (GPA < 3.5) THEN
                //  Grade := 'C';
                //  Condition := Condition::Passed;
                //  Supplementary := Supplementary::No;

                //IF (GPA >= 2.4) OR (GPA < 2.7) THEN
                //  Grade := 'D';
                //  Condition := Condition::Failed;
                //  Supplementary := Supplementary::Yes;

                //IF (GPA < 2.4) THEN
                //Grade := 'F';
                //  Condition := Condition::Failed;
                //  Supplementary := Supplementary::Yes;

                IF (Totals >= 90) AND (Totals < 100) THEN BEGIN
                    Grade := Grade::A;
                    Condition := Condition::Passed;
                    Supplementary := Supplementary::No;
                    Overall := Totals;
                    EntryDate := TODAY;
                END;

                IF (Totals >= 80) AND (Totals < 90) THEN BEGIN
                    Grade := Grade::B;
                    Condition := Condition::Passed;
                    Supplementary := Supplementary::No;
                    Overall := Totals;
                    PK := PK + 1;
                    EntryDate := TODAY;

                END;

                IF (Totals >= 70) AND (Totals < 80) THEN BEGIN
                    Grade := Grade::C;
                    Condition := Condition::Passed;
                    Supplementary := Supplementary::No;
                    Overall := Totals;
                    EntryDate := TODAY;
                END;
                IF (Totals >= 60) AND (Totals < 70) THEN BEGIN
                    Grade := Grade::"C-";
                    Condition := Condition::Failed;
                    Supplementary := Supplementary::Yes;
                    Overall := Totals;
                    EntryDate := TODAY;
                END;
                IF (Totals < 60) THEN BEGIN
                    Grade := Grade::F;
                    Condition := Condition::Failed;
                    Supplementary := Supplementary::Yes;
                    Overall := Totals;
                    EntryDate := TODAY;
                END;
            end;
        }
        field(12; Overall; Integer)
        {
            Editable = false;
        }
        field(13; Grade; Option)
        {
            Editable = false;
            OptionMembers = A,"A-","B+",B,"B-","C+",C,"C-",F;
        }
        field(14; Condition; Option)
        {
            Editable = false;
            OptionMembers = Pending,Passed,Failed;
        }
        field(15; Supplementary; Option)
        {
            Editable = false;
            OptionMembers = Yes,No;
        }
        field(16; PK; Integer)
        {
        }
        field(17; EntryDate; Date)
        {
        }
        field(18; "Unit Code"; Integer)
        {
            Editable = false;
        }
        field(19; Semester; Text[30])
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        StudentApp: Record "Student Application";
        Cats: Integer;
        Totals: Integer;
        StuGraSe: Record "Student Grade Setup";
        StudentGrad: Record "Student Grade";
        UnitCode: Record "Unit Code Setup";
}

