codeunit 50066 StudentApprovalWorkflow
{

    trigger OnRun()
    begin

    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        StudentApplication: Record "Student Application";
        ApprovalEntryTable: Record "Approval Entry";
        StudentNo: Code[30];
        //SMAIL: Codeunit "400";
        MailBody: Text;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        StudentApprovalCodeunit: Codeunit StudentApprovalWorkflow;

    //[Scope('Internal')]
    procedure RunWorkflowOnSendSAforApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendSAforApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::StudentApprovalWorkflow, 'OnSendSAforApproval', '', true, true)]
    //[Scope('Internal')]
    procedure RunWorkflowOnSendSAforApproval(var StudentApplication: Record "Student Application")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendSAforApprovalCode, StudentApplication);
        StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::"Pending Approval";
        StudentApplication.MODIFY(TRUE);
        //MESSAGE('RunWorkflowOnSendSAforApproval is working');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', true, true)]
    //[Scope('Internal')]
    procedure RunWorkflowOnApproveApprovalRequestforSA(var ApprovalEntry: Record "Approval Entry")
    begin
        StudentApplication.RESET;
        StudentApplication.SETRANGE(No, ApprovalEntry."Document No.");
        IF StudentApplication.FINDFIRST THEN BEGIN
            StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::Approved;
            StudentApplication.MODIFY(TRUE);
        END;

        WorkflowManagement.HandleEventOnKnownWorkflowInstance(RunWorkflowOnApproveApprovalRequestforSACode,
          ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
        //MESSAGE('RunWorkflowOnApproveApprovalRequest is working');
    end;

    //[Scope('Internal')]
    procedure RunWorkflowOnApproveApprovalRequestforSACode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnApproveApprovalRequestforSA'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure AddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendSAforApprovalCode, DATABASE::"Student Application", 'Send Student Application for Approval', 15, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnApproveApprovalRequestforSACode, DATABASE::"Approval Entry", 'Approve Approval Request for Student Application', 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnRejectApprovalRequestforSACode, DATABASE::"Approval Entry", 'Reject Approval Request for Student Application', 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnDelegateApprovalRequestForSACode, DATABASE::"Approval Entry", 'Delegate Approval Request for Student Application', 0, FALSE);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', true, true)]
    local procedure AddWorkflowTableRelationsToLibrary()
    var
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::"Student Application", 15, DATABASE::"Approval Entry", 22);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', true, true)]
    //[Scope('Internal')]
    procedure RunWorkflowOnRejectApprovalRequestforSA(var ApprovalEntry: Record "Approval Entry")
    begin
        WorkflowManagement.HandleEventOnKnownWorkflowInstance(RunWorkflowOnRejectApprovalRequestforSACode,
          ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
        StudentApplication.RESET;
        StudentApplication.SETRANGE(No, ApprovalEntry."Document No.");
        IF StudentApplication.FINDFIRST THEN BEGIN
            StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::Rejected;
            StudentApplication.MODIFY(TRUE);
        END;
    end;

    //[Scope('Internal')]
    procedure RunWorkflowOnRejectApprovalRequestforSACode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnRejectApprovalRequestforSA'));
    end;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnDelegateApprovalRequest', '', true, true)]
    //[Scope('Internal')]
    procedure RunWorkflowOnDelegateApprovalRequestForSA(var ApprovalEntry: Record "Approval Entry")
    begin
        WorkflowManagement.HandleEventOnKnownWorkflowInstance(RunWorkflowOnDelegateApprovalRequestForSACode,
          ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
        StudentApplication.RESET;
        StudentApplication.SETRANGE(No, ApprovalEntry."Document No.");
        IF StudentApplication.FINDFIRST THEN BEGIN
            StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::Delegated;
            StudentApplication.MODIFY(TRUE);
        END;
    end;

    //[Scope('Internal')]
    procedure RunWorkflowOnDelegateApprovalRequestForSACode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnDelegateApprovalRequestForSA'));
    end;

    [IntegrationEvent(false, false)]
    //[Scope('Internal')]
    procedure OnSendSAforApproval(var StudentApplication: Record "Student Application")
    begin
    end;

    //[Scope('Internal')]
    procedure IsSAApprovalWorkflowEnabled(StudentApplication: Record "Student Application"): Boolean
    begin
        EXIT(WorkflowManagement.CanExecuteWorkflow(StudentApplication, StudentApprovalCodeunit.RunWorkflowOnSendSAforApprovalCode));
    end;

    //[Scope('OnPrem')]
    procedure CheckSAApprovalsWorkflowEnabled(var StudentApplication: Record "Student Application"): Boolean
    begin
        IF NOT IsSAApprovalWorkflowEnabled(StudentApplication) THEN
            ERROR('No workflow is enabled');
        EXIT(TRUE);
    end;

    [EventSubscriber(ObjectType::Page, DATABASE::"Student Application", 'OnAfterActionEvent', '<Action46>', true, true)]
    local procedure SendSAForApprovalFunction(var Rec: Record "Student Application")
    begin
        IF StudentApprovalCodeunit.CheckSAApprovalsWorkflowEnabled(StudentApplication) THEN BEGIN
            StudentApprovalCodeunit.OnSendSAforApproval(StudentApplication);
            MESSAGE('SendSAforApprovalFUnctionworking');
        END;
    end;
}

