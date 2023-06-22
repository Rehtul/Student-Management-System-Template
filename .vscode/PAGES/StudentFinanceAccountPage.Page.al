page 50061 "Student Finance Account Page"
{
    PageType = Card;
    SourceTable = "Student Finance Account";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PK; Rec.PK)
                {
                    Caption = 'USID';
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
                field(Course; Rec.Course)
                {
                }
                field(Units; Rec.Units)
                {
                }
                field(AmountDue; Rec.AmountDue)
                {
                }
                field(AmountPaid; Rec.AmountPaid)
                {
                }
                field(Balance; Rec.Balance)
                {
                }
                field(PaymentMethod; Rec.PaymentMethod)
                {
                }
                field(Authorizer; Rec.Authorizer)
                {
                }
                field(Date; Rec.Date)
                {
                    Editable = true;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(ReviewReciept)
            {
                Caption = 'Review Reciept';
                Image = "Report";
                RunObject = Report "Student Transcript";
                RunPageOnRec = false;

                trigger OnAction()
                var
                    FinanceReport: Report "Student Transcript";
                begin
                    //REPORT.RUNMODAL(50002,TRUE,TRUE,Rec);
                    //REPORT.RUN(50002,TRUE,TRUE,Rec);
                    //MESSAGE('%1', Rec.No);
                    FinanceReport.SETTABLEVIEW(Rec);
                    FinanceReport.RUN;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        IF StudentAcc.FINDLAST THEN BEGIN
            Rec.PK := StudentAcc.PK + 1;
        END
        ELSE BEGIN
            Rec.PK := 10000;
        END;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        StudentAcc.RESET;
        StudentAcc.SETRANGE(PK, 1, 10000);
        IF StudentAcc.FINDLAST THEN BEGIN
            Rec.PK := StudentAcc.PK + 1;
        END;
    end;

    trigger OnOpenPage()
    begin
        //MESSAGE('Enter the student ID in The USID field. Eg STU0100 USID= 0100');
    end;

    var
        StudentAcc: Record "Student Finance Account";
}

