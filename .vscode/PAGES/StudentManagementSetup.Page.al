page 50032 "Student Management Setup"
{
    PageType = Card;
    SourceTable = "Student Management Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(MinimumAge; Rec.MinimumAge)
                {
                    Editable = true;
                }
                field(MaximumAge; Rec.MaximumAge)
                {
                    Editable = true;
                }
                field(PrimaryKey; Rec.PrimaryKey)
                {
                    Editable = true;
                }
                field(CF; Rec.CF)
                {
                    Editable = true;
                }
            }
        }
    }

    actions
    {
    }
}

