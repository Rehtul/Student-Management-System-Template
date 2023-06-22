page 50040 "Course Setup List"
{
    PageType = List;
    SourceTable = "Course Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(CourseNo; Rec.CourseNo)
                {
                }
                field(CourseName; Rec.CourseName)
                {
                }
            }
        }
    }

    actions
    {
    }
}

