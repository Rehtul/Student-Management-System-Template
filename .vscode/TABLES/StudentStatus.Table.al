table 50056 "Student Status"
{

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; Name; Text[50])
        {

            trigger OnValidate()
            begin
                SetDate;
            end;
        }
        field(3; FName; Text[30])
        {
        }
        field(4; CurrentStatus; Option)
        {
            OptionMembers = "Pending Approval",Approved,Rejected;

            trigger OnValidate()
            begin
                IF (CurrentStatus = CurrentStatus::Approved) THEN
                    //MESSAGE('Approval for Student %1', Name);
                    StudentApp2.RESET;
                StudentApp2.SETRANGE(SurName, Name);
                IF StudentApp2.FINDFIRST THEN BEGIN
                    StudentApp2.ApprovalStatus := StudentApp2.ApprovalStatus::"Pending Approval";
                    StudentApp2.MODIFY;

                    Customer.INIT;
                    Customer.Name := FName;
                    Customer."Name 2" := Name;
                    Customer.INSERT;
                END
            end;
        }
        field(5; Date; Date)
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        MESSAGE('Approval Request has been submitter await confirmation in your profile');
    end;

    var
        StudentApp: Record "Student Application";
        StudentApp2: Record "Student Application";
        Customer: Record "Customer";

    local procedure SetDate()
    begin
        Date := TODAY;
    end;

    local procedure UpdateRecord()
    begin
    end;
}

