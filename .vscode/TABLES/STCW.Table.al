table 50039 STCW
{

    fields
    {
        field(1; No; Integer)
        {
        }
        field(2; CustomerCode; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(3; "Customer Search Name"; Text[50])
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

