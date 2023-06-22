page 50033 "Student Application List"
{
    PageType = List;
    SourceTable = "Student Application";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field(Gender; Rec.Gender)
                {
                }
                field(DateOfBirth; Rec.DateOfBirth)
                {
                }
                field(Age; Rec.Age)
                {
                }
                field(Course; Rec.Course)
                {
                }
                field("Academic Year"; Rec."Academic Year")
                {
                }
                field(Semester; Rec.Semester)
                {
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
                field(ApprovalStatus; Rec.ApprovalStatus)
                {
                }
                field(No; Rec.No)
                {
                }
                field(No2; Rec.No2)
                {
                }
                field("No.Series"; Rec."No.Series")
                {
                }
            }
        }
    }

    actions
    {
    }
}

