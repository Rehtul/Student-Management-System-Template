table 50037 "Unit Setup"
{

    fields
    {
        field(1; "Unit No."; Integer)
        {
        }
        field(2; "Unit Name"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Unit No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

