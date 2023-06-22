table 50045 "Student Finance"
{

    fields
    {
        field(1; "No."; Integer)
        {
        }
        field(2; Name; Text[100])
        {
        }
        field(3; TuitionFees; Integer)
        {
        }
        field(4; LibraryFees; Integer)
        {
        }
        field(5; ActivityFees; Integer)
        {
        }
        field(6; PaidFees; Integer)
        {
        }
        field(7; Arrears; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

