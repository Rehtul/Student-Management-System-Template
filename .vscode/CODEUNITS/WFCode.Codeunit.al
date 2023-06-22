codeunit 50068 WFCode
{
    trigger OnRun()
    begin

    end;

    var
        WFMngt: Codeunit "Workflow Management";
        AppMgmt: Codeunit "Approvals Mgmt.";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        SendSAReq: TextConst ENU = 'Approval Request for SA is requested', ENG = 'Approval Request for SA is requested';
        AppReqSA: TextConst ENU = 'Approval Request for SA is Approved', ENG = 'Approval Request for SA is Approved';
        RejReqSA: TextConst ENU = 'Approval Request for SA is rejected', ENG = 'Approval Request for SA is Rejected';
        DelReqSA: TextConst ENU = 'Approval Request for SA is Delegated', ENG = 'Approval Request for SA is Delegated';
        SendForPendAppTxt: TextConst ENU = 'Status of SA changed to Pending Approval', ENG = 'Status of SA changed to Pending Approval';
        ReleaseSATxt: TextConst ENU = 'Release SA', ENG = 'Release SA';
        ReOpenSATxt: TextConst ENU = 'ReOpen SA', ENG = 'ReOpen SA';

    //RunWorkflowOnSendStuApplicationTMForApproval
    //RunWorkflowOnSendSAForApproval

    procedure RunWorkflowOnSendSAForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendSAForApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntCodeunit, 'OnSendSAforApproval', '', false, false)]
    procedure RunWorkflowOnSendSAForApproval(var StudentApplication: Record "Student Application")
    begin
        WFMngt.HandleEvent(RunWorkflowOnSendSAForApprovalCode(), StudentApplication);
        StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::"Pending Approval";
        StudentApplication.Modify(True);
    end;

    procedure RunWorkflowOnApproveSAApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnApproveSAApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', false, false)]
    procedure RunWorkflowOnApproveSAApproval(var ApprovalEntry: Record "Approval Entry")
    var
        StudentApplication: Record "Student Application";
        customer: Record Customer;
    begin
        StudentApplication.Reset();
        StudentApplication.Get(ApprovalEntry."Record ID to Approve");
        StudentApplication.ApprovalStatus := StudentApplication.ApprovalStatus::Approved;
        StudentApplication.Modify();

        // Add as Customer
        customer.INIT;
        customer."No." := StudentApplication.No;
        customer.Name := StudentApplication.FullName;
        customer."Name 2" := StudentApplication.FirstName;
        customer."Search Name" := StudentApplication.FullName;
        customer."Gen. Bus. Posting Group" := StudentApplication.Originality;
        //customer."Gen. Bus. Posting Group" := 'DOMESTIC';
        customer."VAT Bus. Posting Group" := StudentApplication.Originality;
        customer."Customer Posting Group" := StudentApplication.Originality;
        //customer."Customer Posting Group" := 'DOMESTIC';
        customer."Payment Terms Code" := StudentApplication."Payment Terms Code";
        customer.INSERT;

        WFMngt.HandleEventOnKnownWorkflowInstance(RunWorkflowOnApproveSAApprovalCode(), ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
    end;

    procedure RunWorkflowOnRejectSAApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnRejectSAApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    procedure RunWorkflowOnRejectSAApproval(var ApprovalEntry: Record "Approval Entry")
    begin
        WFMngt.HandleEventOnKnownWorkflowInstance(RunWorkflowOnRejectSAApprovalCode(), ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
    end;

    procedure RunWorkflowOnDelegateSAApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnDelegateSAApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnDelegateApprovalRequest', '', false, false)]
    procedure RunWorkflowOnDelegateSAApproval(var ApprovalEntry: Record "Approval Entry")
    begin
        WFMngt.HandleEventOnKnownWorkflowInstance(RunWorkflowOnDelegateSAApprovalCode(), ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
    end;

    procedure SetStatusToPendingApprovalCodeSA(): Code[128]
    begin
        exit(UpperCase('SetStatusToPendingApprovalSA'));
    end;

    procedure SetStatusToPendingApprovalSA(var Variant: Variant)
    var
        RecRef: RecordRef;
        StudentApplication: Record "Student Application";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number() of
            DATABASE::"Student Application":
                begin
                    RecRef.SetTable(StudentApplication);
                    StudentApplication.Validate(ApprovalStatus, StudentApplication.ApprovalStatus::"Pending Approval");
                    StudentApplication.Modify();
                    Variant := StudentApplication;
                end;
        end;
    end;

    procedure ReleaseSACode(): Code[128]
    begin
        exit(UpperCase('ReleaseSA'));
    end;

    procedure ReleaseSA(var Variant: Variant)
    var
        RecRef: RecordRef;
        TargetRecRef: RecordRef;
        ApprovalEntry: Record "Approval Entry";
        StudentApplication: Record "Student Application";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number() of
            DATABASE::"Approval Entry":
                begin
                    ApprovalEntry := Variant;
                    TargetRecRef.Get(ApprovalEntry."Record ID to Approve");
                    Variant := TargetRecRef;
                    ReleaseSA(Variant);
                end;
            DATABASE::"Student Application":
                begin
                    RecRef.SetTable(StudentApplication);
                    StudentApplication.Validate(ApprovalStatus, StudentApplication.ApprovalStatus::Released);
                    StudentApplication.Modify();
                    Variant := StudentApplication;
                end;
        end;
    end;

    procedure ReOpenSACode(): Code[128]
    begin
        exit(UpperCase('ReOpenSA'));
    end;

    procedure ReOpenSA(var Variant: Variant)
    var
        RecRef: RecordRef;
        TargetRecRef: RecordRef;
        ApprovalEntry: Record "Approval Entry";
        StudentApplication: Record "Student Application";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number() of
            DATABASE::"Approval Entry":
                begin
                    ApprovalEntry := Variant;
                    TargetRecRef.Get(ApprovalEntry."Record ID to Approve");
                    Variant := TargetRecRef;
                    ReOpenSA(Variant);
                end;
            DATABASE::"Student Application":
                begin
                    RecRef.SetTable(StudentApplication);
                    StudentApplication.Validate(ApprovalStatus, StudentApplication.ApprovalStatus::Open);
                    StudentApplication.Modify();
                    Variant := StudentApplication;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure AddSAEventToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendSAForApprovalCode(), Database::"Student Application", SendSAReq, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnApproveSAApprovalCode(), Database::"Approval Entry", AppReqSA, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnRejectSAApprovalCode(), Database::"Approval Entry", RejReqSA, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnDelegateSAApprovalCode(), Database::"Approval Entry", DelReqSA, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', false, false)]
    procedure AddSARespToLibrary()
    begin
        WorkflowResponseHandling.AddResponseToLibrary(SetStatusToPendingApprovalCodeSA(), 0, SendForPendAppTxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(ReleaseSACode(), 0, ReleaseSATxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(ReOpenSACode(), 0, ReOpenSATxt, 'GROUP 0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', false, false)]
    procedure ExeRespForSA(var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        if WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name") then
            case WorkflowResponse."Function Name" of
                SetStatusToPendingApprovalCodeSA():
                    begin
                        SetStatusToPendingApprovalCodeSA();
                        ResponseExecuted := true;
                    end;
                ReleaseSACode():
                    begin
                        ReleaseSA(Variant);
                        ResponseExecuted := true;
                    end;
                ReOpenSACode():
                    begin
                        ReOpenSACode();
                        ResponseExecuted := true
                    end;
            end;
    end;
}