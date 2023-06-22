table 50036 "Semester Setup"
{

    fields
    {
        field(1; Semester; Text[30])
        {

            trigger OnValidate()
            begin
                ActiveSem;
            end;
        }
        field(2; PrimaryKey; Integer)
        {
        }
        field(3; "SemesterNo."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; Semester)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        VarDate: Date;

    local procedure ActiveSem()
    begin
        VarDate := DMY2DATE(30, 1, 2023);
    end;
}

