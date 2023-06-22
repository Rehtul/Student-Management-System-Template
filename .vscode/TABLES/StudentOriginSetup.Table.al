table 50033 "Student Origin Setup"
{

    fields
    {
        field(1; No; Integer)
        {
        }
        field(2; Originality; Code[50])
        {
        }
    }

    keys
    {
        key(Key1; Originality)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

