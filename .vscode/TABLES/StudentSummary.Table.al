table 50055 "Student Summary"
{

    fields
    {
        field(1; No; Integer)
        {

            trigger OnValidate()
            begin
                InTheBegiinning;
            end;
        }
        field(2; NoOfStudents; Integer)
        {
            Editable = false;
        }
        field(3; NoOfSemesters; Integer)
        {
        }
        field(4; CurrentSemester; Text[30])
        {
        }
        field(5; NoOfCourses; Integer)
        {
        }
        field(6; NoOfUnits; Integer)
        {
        }
    }

    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        StudentsApplication2: Record "Student Application";
        TotalStudents: Integer;
        Courses: Record "Course Setup";
        Semesters: Record "Semester Setup";
        Units: Record "Unit Code Setup";

    local procedure InTheBegiinning()
    begin
        TotalStudents := StudentsApplication2.COUNT;
        NoOfStudents := TotalStudents;
        NoOfCourses := Courses.COUNT;
        NoOfUnits := Units.COUNT;
        NoOfSemesters := Semesters.COUNT;
        //IF (TODAY > DMY2DATE(12,1,2023)) THEN
        //  MESSAGE('The semester is %1',Semesters."SemesterNo.");
        IF (TODAY > DMY2DATE(12, 1, 2023)) AND (TODAY < DMY2DATE(12, 4, 2023)) THEN
            CurrentSemester := 'Spring Semester';
        IF (TODAY > DMY2DATE(12, 5, 2023)) AND (TODAY < DMY2DATE(12, 8, 2023)) THEN
            CurrentSemester := 'Summer Semester';
        IF (TODAY > DMY2DATE(12, 9, 2023)) AND (TODAY < DMY2DATE(12, 12, 2023)) THEN
            CurrentSemester := 'Fall Semester';
    end;
}

