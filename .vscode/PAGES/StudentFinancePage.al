page 50045 "Student Finance"
{
    PageType = Card;
    SourceTable = "Student Finance";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                { }
                field(Name; Rec.Name)
                { }
                field(TuitionFees; Rec.TuitionFees)
                { }
                field(LibraryFees; Rec.LibraryFees)
                { }
                field(ActivityFees; Rec.ActivityFees)
                { }
                field(PaidFees; Rec.PaidFees)
                { }
                field(Arrears; Rec.Arrears)
                { }
            }
        }
    }
}