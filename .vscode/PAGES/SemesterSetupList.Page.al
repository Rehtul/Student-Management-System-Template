page 50042 "Semester Setup List"
{
    PageType = List;
    SourceTable = "Semester Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Semester; Rec.Semester)
                {
                }
                field("SemesterNo."; Rec."SemesterNo.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

