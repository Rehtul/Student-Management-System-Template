page 50064 "Student Grade Page"
{
    PageType = Card;
    SourceTable = "Student Grade";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; Rec.No)
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
                field(Year; Rec.Year)
                {
                }
                field(Semester; Rec.Semester)
                {
                }
                field(Course; Rec.Course)
                {
                }
                field(Units; Rec.Units)
                {
                    Caption = 'Unit';
                    Editable = true;
                    TableRelation = "Unit Code Setup"."Unit Name";
                }
                field("Unit Code"; Rec."Unit Code")
                {
                }
                field(CAT1; Rec.CAT1)
                {
                }
                field(CAT2; Rec.CAT2)
                {
                }
                field(Final; Rec.Final)
                {
                }
                field(Overall; Rec.Overall)
                {
                }
                field(Grade; Rec.Grade)
                {
                }
                field(Condition; Rec.Condition)
                {
                }
                field(Supplementary; Rec.Supplementary)
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Printable Transcript")
            {
                RunObject = Report "Student Transcript";
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        StudentGrad.RESET;
        StudentGrad.SETRANGE(PK, 1, 10000);
        IF StudentGrad.FINDLAST THEN BEGIN
            Rec.PK := StudentGrad.PK + 1;
        END;
    end;

    var
        StudentGrad: Record "Student Grade";
}

