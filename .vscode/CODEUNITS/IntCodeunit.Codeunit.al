codeunit 50067 IntCodeunit
{
    trigger OnRun()
    begin

    end;

    [IntegrationEvent(false, false)]
    procedure OnSendSAforApproval(var StudentApplication: Record "Student Application")
    begin

    end;

    procedure isSAEnabled(var StudentApplication: Record "Student Application"): Boolean
    var
        WFMngt: Codeunit "Workflow Management";
        WFCode: Codeunit WFCode;

    begin
        exit(WFMngt.CanExecuteWorkflow(StudentApplication, WFCode.RunWorkflowOnSendSAForApprovalCode()))
    end;

    local procedure CheckWorkflowEnabled(): Boolean
    var
        StudentApplication: Record "Student Application";
        NoWorkflowEnb: TextConst ENU = 'No workflow Enabled for this record type', ENG = 'No workflow Enabled for this Record type';
    begin
        if not isSAEnabled(StudentApplication) then
            Error(NoWorkflowEnb);
    end;

    var
        myInt: Integer;
}