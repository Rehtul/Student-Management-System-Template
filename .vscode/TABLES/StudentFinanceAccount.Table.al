table 50058 "Student Finance Account"
{

    fields
    {
        field(1; No; Code[30])
        {
            Editable = true;
            TableRelation = "Student Application".No;
        }
        field(2; FirstName; Text[50])
        {
            TableRelation = "Student Application".No;

            trigger OnValidate()
            begin
                StudentApp.RESET;
                StudentApp.SETRANGE(No, FirstName);
                IF StudentApp.FINDFIRST THEN BEGIN
                    No := StudentApp.No;
                    FirstName := StudentApp.FirstName;
                    MiddleName := StudentApp.MiddleName;
                    SurName := StudentApp.SurName;
                    FullName := StudentApp.FullName;
                    Year := StudentApp."Academic Year";
                    Course := StudentApp.Course;
                    Units := StudentApp.Units;
                    AmountDue := StudentApp.TutionCharge;

                END;

                //StudentAcc.RESET;
                //StudentAcc.SETRANGE(PK,1,10000);
                //IF StudentAcc.FINDLAST THEN BEGIN
                //  PK := StudentAcc.PK + 1;
                //  END;

                //PK := PK + 1;
            end;
        }
        field(3; MiddleName; Text[50])
        {
            Editable = false;
        }
        field(4; SurName; Text[50])
        {
            Editable = false;
        }
        field(5; FullName; Text[100])
        {
            Editable = false;
        }
        field(6; Year; Integer)
        {
            Editable = false;
        }
        field(7; Course; Integer)
        {
            Editable = false;
        }
        field(8; Units; Text[130])
        {
            Editable = false;
        }
        field(9; AmountDue; Integer)
        {
            Editable = false;
        }
        field(10; AmountPaid; Integer)
        {

            trigger OnValidate()
            begin
                StudentApp.SETRANGE(FirstName, FirstName);

                IF StudentApp.FINDFIRST THEN BEGIN
                    Balance := AmountDue - AmountPaid;
                    StudentApp.TutionCharge := Balance;
                    StudentApp.PaidTution := AmountPaid;
                    StudentApp.MODIFY;

                    Date := TODAY;
                END
            end;
        }
        field(11; PaymentMethod; Option)
        {
            OptionMembers = "Wire Transfer","Bank Deposit","Online Payment","Mobile Transfer",Cheque;
        }
        field(12; Balance; Integer)
        {

            trigger OnValidate()
            begin
                Balance := AmountDue - AmountPaid;
            end;
        }
        field(13; Authorizer; Option)
        {
            OptionMembers = "MD. Chris Omwenga","Ass. MD. Vivian Nyamae","Acc. Valentine Musyoka","Acc. Kimberly Von";
        }
        field(14; Date; Date)
        {
        }
        field(15; PK; Integer)
        {
            AutoIncrement = true;
        }
        field(16; TuitionCharges; Integer)
        {
        }
        field(17; ActivityCharges; Integer)
        {
        }
        field(18; LibraryCharges; Integer)
        {
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        StudentApp: Record "Student Application";
        StudentAcc: Record "Student Finance Account";
}

