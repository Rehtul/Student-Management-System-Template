table 50038 "Unit Code Setup"
{
    Caption = 'Units Code';

    fields
    {
        field(1; "Primary No"; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Unit No"; Integer)
        {
            TableRelation = "Course Setup".CourseNo;
        }
        field(3; "Unit Name"; Text[50])
        {
        }
        field(4; "Location Code"; Option)
        {
            OptionMembers = Chiromo,Kabete,Njiru,Ruiru,Limuru,"Moi Av.";
        }
        field(5; Quantity; Integer)
        {
        }
        field(6; "Unit Price"; Integer)
        {
        }
        field(7; "VAT Bus. Posting Group"; Code[50])
        {
            TableRelation = "VAT Business Posting Group";
        }
        field(8; "VAT Prod. Posting Group"; Code[50])
        {
            TableRelation = "VAT Product Posting Group";
        }
        field(9; "Gen. Bus. Posting Group"; Code[50])
        {
            TableRelation = "Gen. Business Posting Group";
        }
        field(10; "Gen. Prod. Posting Group"; Code[50])
        {
            TableRelation = "Gen. Product Posting Group";
        }
        field(11; "Sales Account"; Code[10])
        {
            TableRelation = "G/L Account";
        }
        field(12; "Unit Description"; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Unit Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

