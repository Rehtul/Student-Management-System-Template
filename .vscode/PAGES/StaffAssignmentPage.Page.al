page 50062 "Staff Assignment Page"
{
    PageType = Card;
    SourceTable = "Staff Assignment";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; Rec.No)
                {
                }
                field(Code; Rec.Code)
                {
                }
                field(Staff; Rec.Staff)
                {
                }
                field(StartDate; Rec.StartDate)
                {
                }
                field(EndDate; Rec.EndDate)
                {
                }
                field(Semester; Rec.Semester)
                {
                }
                field(Year; Rec.Year)
                {
                }
                field("Unit Code"; Rec."Unit Code")
                {
                }
                field("Unit Name"; Rec."Unit Name")
                {
                    Editable = false;
                }
                field(Venue; Rec.Venue)
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        StaffAss.RESET;
        StaffAss.SETRANGE(No, 1, 100000);
        IF StaffAss.FINDLAST THEN BEGIN
            Rec.No := StaffAss.No + 1;
        END;
    end;

    var
        StaffAss: Record "Staff Assignment";
}

