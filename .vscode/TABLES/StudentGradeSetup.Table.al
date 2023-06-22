table 50063 "Student Grade Setup"
{

    fields
    {
        field(1; No; Integer)
        {
        }
        field(2; Marks; Integer)
        {
        }
        field(3; Grade; Option)
        {
            OptionMembers = A,"A-","B+",B,"B-","C+",C,"C-",F;
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
}

