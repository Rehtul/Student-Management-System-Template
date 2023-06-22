page 50059 "Student Summary CardPart"
{
    PageType = CardPart;
    SourceTable = "Student Summary";

    layout
    {
        area(content)
        {
            cuegroup(General)
            {
                field(NoOfStudents; Rec.NoOfStudents)
                {
                    Caption = 'Applied Students';
                    DrillDown = true;
                    DrillDownPageID = "Student Application List";
                    Editable = false;
                    //Image = Stack;
                    TableRelation = "Student Summary".NoOfStudents;
                }
                field(NoOfSemesters; Rec.NoOfSemesters)
                {
                    Caption = 'Total Semesters';
                    DrillDown = true;
                    DrillDownPageID = "Semester Setup List";
                    TableRelation = "Student Summary".NoOfSemesters;
                }

                actions
                {
                    action("Current Students")
                    {
                        RunObject = Page 50033;
                    }
                    action("Add New Students")
                    {
                        RunObject = Page 50031;
                        RunPageMode = Create;

                        trigger OnAction()
                        begin
                            //RN.SETRANGE(No,'0');
                            //PAGE.RUNMODAL(PAGE::"Student Application",RN);
                            //PAGE.RUN(PAGE::"Student Application");
                        end;
                    }
                    action("Current Semester")
                    {
                        RunObject = Page 50036;
                    }
                    action("Add New Semester")
                    {
                        RunObject = Page 50031;
                        RunPageMode = Create;
                    }
                }
            }
            cuegroup(Academics)
            {
                field(NoOfCourses; Rec.NoOfCourses)
                {
                    DrillDown = true;
                    DrillDownPageID = "Course Setup List";
                    TableRelation = "Student Summary".NoOfCourses;
                }
                field(NoOfUnits; Rec.NoOfUnits)
                {
                    DrillDown = true;
                    //DrillDownPageID = "Unit Code Setup List";
                    TableRelation = "Student Summary".NoOfUnits;
                }

                actions
                {
                    action("Current Available Courses")
                    {
                        RunObject = Page 50034;
                    }
                    action("Add New Courses")
                    {
                        RunObject = Page 50034;
                        RunPageMode = Create;
                    }
                    action("Current Available Units")
                    {
                        RunObject = Page 50068;
                    }
                    action("Add New Units")
                    {
                        RunObject = Page 50068;
                        RunPageMode = Create;
                    }
                }
            }
        }
    }

    actions
    {
    }

    var
        RN: Record "Student Application";
}

