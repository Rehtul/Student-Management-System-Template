table 50032 "Student Management Setup"
{

    fields
    {
        field(1; MinimumAge; Integer)
        {

            trigger OnValidate()
            begin
                MinimumAge := 18;
            end;
        }
        field(2; MaximumAge; Integer)
        {

            trigger OnValidate()
            begin
                MaximumAge := 30;
            end;
        }
        field(3; PrimaryKey; Integer)
        {
            TableRelation = "Student Application";
        }
        field(4; CF; Code[20])
        {
            TableRelation = "No. Series".Code;
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

