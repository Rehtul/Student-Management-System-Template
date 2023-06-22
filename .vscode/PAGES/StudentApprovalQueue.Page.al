page 50075 "Student Approval Queue"
{
    PageType = Card;
    SourceTable = "Approval Entry";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("Record ID to Approve"; Rec."Record ID to Approve")
                {
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                }
                field("Approval Code"; Rec."Approval Code")
                {
                }
                field("Sender ID"; Rec."Sender ID")
                {
                }
                field("Approver ID"; Rec."Approver ID")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Date-Time Sent for Approval"; Rec."Date-Time Sent for Approval")
                {
                }
                field("Approval Type"; Rec."Approval Type")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Approve)
            {
                Image = Approval;

                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(ApprovalEntry);
                    ApprovalsMgt.ApproveApprovalRequests(ApprovalEntry);

                    // StudentApplication.RESET;
                    // StudentApplication.GET(Rec."Document No.");
                    // StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::Approved;
                    // StudentApplication.MODIFY(TRUE);

                    // customer.INIT;
                    // customer."No." := StudentApplication.No;
                    // customer.Name := StudentApplication.FullName;
                    // customer."Name 2" := StudentApplication.FirstName;
                    // customer."Search Name" := StudentApplication.FullName;
                    // customer."Gen. Bus. Posting Group" := StudentApplication.Originality;
                    // customer."Customer Posting Group" := StudentApplication.Originality;
                    // customer."Payment Terms Code" := StudentApplication."Payment Terms Code";
                    // customer.INSERT;
                end;
            }
            action(Delegate)
            {
                Image = Delegate;

                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(ApprovalEntry);
                    ApprovalsMgt.DelegateApprovalRequests(ApprovalEntry);

                    StudentApplication.RESET;
                    StudentApplication.GET(Rec."Document No.");
                    StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::Delegated;
                    StudentApplication.MODIFY(TRUE);
                end;
            }
            action(Reject)
            {
                Image = Reject;

                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(ApprovalEntry);
                    ApprovalsMgt.RejectApprovalRequests(ApprovalEntry);

                    StudentApplication.RESET;
                    StudentApplication.GET(Rec."Document No.");
                    StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::Rejected;
                    StudentApplication.MODIFY(TRUE);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //FILTERGROUP(2);
        // SETRANGE(Rec."Approver ID", USERID);
        //FILTERGROUP(0);
        //SETRANGE(Rec.Status, Rec.Status::Open);
    end;

    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgt: Codeunit "Approvals Mgmt.";
        StudentApplication: Record "Student Application";
        customer: Record "Customer";
}

