codeunit 50009 "Student Appworkflow"
{

    trigger OnRun()
    begin
    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        StudentApplicationTable: Record "Student Application";
        ApprovalEntryTable: Record "Approval Entry";
        StudentNo: Code[10];
        //SMAIL: Codeunit "SMTP Mail";
        MailBody: Text;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WFStudentApplication: Codeunit "Student Appworkflow";

    //[Scope('Internal')]
    procedure RunWorkflowOnSendStuApplicationTMforApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendStuApplicationTMforApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, 50009, 'OnSendJobTMforApproval', '', false, false)]
    //[Scope('Internal')]
    procedure RunWorkflowOnSendStuApplicationTMforApproval(var StudentApplication: Record "Student Application")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendStuApplicationTMforApprovalCode, StudentApplication);
        StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::"Pending Approval";
        StudentApplication.MODIFY(TRUE);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnApproveApprovalRequest', '', false, false)]
    //[Scope('Internal')]
    procedure RunWorkflowOnApproveApprovalRequestforStuApplicationTM(var ApprovalEntry: Record "Approval Entry")
    begin
        StudentApplicationTable.RESET;
        StudentApplicationTable.SETRANGE(No, ApprovalEntry."Document No.");
        IF StudentApplicationTable.FINDFIRST THEN BEGIN
            StudentApplicationTable.ApprovalStatus := StudentApplicationTable.ApprovalStatus::Released;
            StudentApplicationTable.MODIFY(TRUE);
        END;

        WorkflowManagement.HandleEventOnKnownWorkflowInstance(RunWorkflowOnApproveApprovalRequestforStuApplicationTMCode,
          ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
    end;

    //[Scope('Internal')]
    procedure RunWorkflowOnApproveApprovalRequestforStuApplicationTMCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnApproveApprovalRequestforStuApplicationTM'));
    end;

    [EventSubscriber(ObjectType::Codeunit, 1520, 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    var
        WorkflowEventsHandling: Codeunit "Workflow Setup";
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendStuApplicationTMforApprovalCode, DATABASE::"Student Application", 'Send Application for Approval - Lut', 14, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnApproveApprovalRequestforStuApplicationTMCode, DATABASE::"Approval Entry", 'Approve Approval Request for Application - Lut', 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnRejectApprovalRequestforStuApplicationTMCode, DATABASE::"Approval Entry", 'Reject Approval Request for Application - Lut', 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnDelegateApprovalRequestForStuApplicationTMCode, DATABASE::"Approval Entry", 'Delegate Approval Request for Application - Lut', 0, FALSE);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1520, 'OnAddWorkflowTableRelationsToLibrary', '', false, false)]
    local procedure AddWorkflowTableRelationsToLibrary()
    var
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::"Student Application", 15, DATABASE::"Approval Entry", 22);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnRejectApprovalRequest', '', false, false)]
    //[Scope('Internal')]
    procedure RunWorkflowOnRejectApprovalRequestforStuApplicationTM(var ApprovalEntry: Record "Approval Entry")
    begin
        WorkflowManagement.HandleEventOnKnownWorkflowInstance(RunWorkflowOnRejectApprovalRequestforStuApplicationTMCode,
          ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
        StudentApplicationTable.RESET;
        StudentApplicationTable.SETRANGE(No, ApprovalEntry."Document No.");
        IF StudentApplicationTable.FINDFIRST THEN BEGIN
            StudentApplicationTable.ApprovalStatus := StudentApplicationTable.ApprovalStatus::Rejected;
            StudentApplicationTable.MODIFY(TRUE);
        END;
    end;

    //[Scope('Internal')]
    procedure RunWorkflowOnRejectApprovalRequestforStuApplicationTMCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnRejectApprovalRequestforStuApplicationTM'));
    end;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnDelegateApprovalRequest', '', false, false)]
    // [Scope('Internal')]
    procedure RunWorkflowOnDelegateApprovalRequestForStuApplicationTM(var ApprovalEntry: Record "Approval Entry")
    begin
        WorkflowManagement.HandleEventOnKnownWorkflowInstance(RunWorkflowOnDelegateApprovalRequestForStuApplicationTMCode,
          ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
        StudentApplicationTable.RESET;
        StudentApplicationTable.SETRANGE(No, ApprovalEntry."Document No.");
        IF StudentApplicationTable.FINDFIRST THEN BEGIN
            StudentApplicationTable.ApprovalStatus := StudentApplicationTable.ApprovalStatus::Delegated;
            StudentApplicationTable.MODIFY(TRUE);
        END;
    end;

    // [Scope('Internal')]
    procedure RunWorkflowOnDelegateApprovalRequestForStuApplicationTMCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnDelegateApprovalRequestForStuApplicationTM'));
    end;

    [IntegrationEvent(false, false)]
    //[Scope('Internal')]
    procedure OnSendJobTMforApproval(var StudentApplication: Record "Student Application")
    begin
    end;

    local procedure IsJobTMApprovalsWorkflowEnabled(StudentApplication: Record "Student Application"): Boolean
    begin
        EXIT(WorkflowManagement.CanExecuteWorkflow(StudentApplication, WFStudentApplication.RunWorkflowOnSendStuApplicationTMforApprovalCode));
    end;

    //[Scope('Internal')]
    procedure CheckJobTMApprovalsWorkflowEnabled(var StudentApplication: Record "Student Application"): Boolean
    begin
        IF NOT IsJobTMApprovalsWorkflowEnabled(StudentApplication) THEN
            ERROR('NoWorkflowEnabledErr');
        EXIT(TRUE);
    end;

    [EventSubscriber(ObjectType::Page, 50031, 'OnAfterActionEvent', 'Request Approval', false, false)]
    local procedure SendJobForApprovalFunction(var Rec: Record "Student Application")
    begin
        IF WFStudentApplication.CheckJobTMApprovalsWorkflowEnabled(Rec) THEN BEGIN
            WFStudentApplication.OnSendJobTMforApproval(Rec);
        END;
    end;
}

