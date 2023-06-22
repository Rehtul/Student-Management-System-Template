page 50063 "Academic Staff Setup Page"
{
    PageType = Card;
    SourceTable = "Academic Staff Setup";

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
                field(Title; Rec.Title)
                {
                }
                field(FirstName; Rec.FirstName)
                {
                }
                field(MiddleName; Rec.MiddleName)
                {
                }
                field(SurName; Rec.SurName)
                {
                }
                field(FullName; Rec.FullName)
                {
                }
                field(MobileContact; Rec.MobileContact)
                {
                }
                field(EmailAddress; Rec.EmailAddress)
                {
                }
                field(Residence; Rec.Residence)
                {
                }
                field(Address; Rec.Address)
                {
                }
                field(AcademicQualification; Rec.AcademicQualification)
                {
                }
                field(Rate; Rec.Rate)
                {
                }
                field(WorkingHours; Rec.WorkingHours)
                {
                }
                field(Availability; Rec.Availability)
                {
                }
                field(AvailabilityDate; Rec.AvailabilityDate)
                {
                }
                field(AvailabilityDuration; Rec.AvailabilityDuration)
                {
                }
                field(todaysdate; Rec.todaysdate)
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ASS.RESET;
        ASS.SETRANGE(No, 1, 100000);
        IF ASS.FINDLAST THEN BEGIN
            Rec.No := ASS.No + 1;
        END;
    end;

    var
        ASS: Record "Academic Staff Setup";
}

