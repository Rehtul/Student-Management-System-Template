table 50035 "Academic Year Setup"
{

    fields
    {
        field(1; AcademicYear; Integer)
        {
        }
        field(2; "Academic Year Description"; Text[30])
        {
        }
    }

    keys
    {
        key(Key1; AcademicYear)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

