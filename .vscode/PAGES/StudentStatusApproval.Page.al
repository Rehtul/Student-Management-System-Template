page 50060 "Student Status Approval"
{
    PageType = Card;
    SourceTable = "Student Status";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                }
                field(Name; Rec.Name)
                {
                    Caption = 'SurName';
                }
                field(FName; Rec.FName)
                {
                    Caption = 'FirstName';
                }
                field(CurrentStatus; Rec.CurrentStatus)
                {
                }
                field(Date; Rec.Date)
                {
                }
            }
        }
    }

    actions
    {
    }
}

