page 50031 "Student Application"
{
    PageType = Card;
    SourceTable = "Student Application";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(FirstName; Rec.FirstName)
                {
                }
                field(MiddleName; Rec.MiddleName)
                {
                    Editable = true;
                }
                field(SurName; Rec.SurName)
                {
                }
                field(FullName; Rec.FullName)
                {
                    Editable = false;
                }
                field(Gender; Rec.Gender)
                {
                }
                field(DateOfBirth; Rec.DateOfBirth)
                {
                }
                field(Originality; Rec.Originality)
                {
                    Caption = 'Residency';
                }
                field("Academic Year"; Rec."Academic Year")
                {
                }
                field(Semester; Rec.Semester)
                {
                }
                field(Course; Rec.Course)
                {
                    LookupPageID = "Course Setup List";
                }
                field(Units; Rec.Units)
                {
                }
                field(TutionCharge; Rec.TutionCharge)
                {
                }
                field(PaidTution; Rec.PaidTution)
                {
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                }
                field(ApprovalStatus; Rec.ApprovalStatus)
                {
                    Visible = true;
                }
                field(No; Rec.No)
                {
                }
                field(No2; Rec.No2)
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Request Approval")
            {
                Image = PostApplication;
                RunObject = Page 50060;

                trigger OnAction()
                begin
                    //MESSAGE('Approval Request Has been sent');
                end;
            }
            action("<Action46>")
            {
                Caption = 'New Application Approval';

                trigger OnAction()
                begin
                    StudentApprovalsCodeunit.OnSendSAforApproval(Rec);
                end;
            }
            action("Send for Approval")
            {
                Caption = 'Send for Approval';
                trigger OnAction()
                begin
                    IntCodeunit.OnSendSAforApproval(Rec);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //StudentApplication.RESET;
        StudentFinAcc.RESET;
        StudentFinAcc.SETRANGE(PK, 1, 1000000);
        IF StudentFinAcc.FINDLAST THEN BEGIN
            StudentFinAcc.PK := StudentFinAcc.PK + 1;
        END;
    end;

    trigger OnOpenPage()
    begin
        //MESSAGE('Enter the student ID in The USID field. Eg STU0100 USID= 0100');
    end;

    var
        StudentApprovalsCodeunit: Codeunit "StudentApprovalWorkflow";
        StudentApplication: Record "Student Application";
        StudentFinAcc: Record "Student Finance Account";
        IntCodeunit: Codeunit IntCodeunit;
}

