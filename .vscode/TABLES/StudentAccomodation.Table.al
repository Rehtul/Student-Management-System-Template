table 50040 "Student Accomodation"
{

    fields
    {
        field(1; No; Integer)
        {
        }
        field(2; Hall; Option)
        {
            OptionMembers = "None","Aberdare Hall","Chiromo Hall";
        }
        field(3; Room; Integer)
        {
        }
        field(4; Availability; Option)
        {
            OptionMembers = "N/A",Yes,No;
        }
        field(5; SlotNo; Option)
        {
            OptionMembers = "0","1","2","3","4";
        }
        field(6; Price; Integer)
        {
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

