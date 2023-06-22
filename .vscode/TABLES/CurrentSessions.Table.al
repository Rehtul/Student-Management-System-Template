table 50062 "Current Sessions"
{

    fields
    {
        field(1; No; Integer)
        {

            trigger OnValidate()
            begin
                //Start dates for the semesters
                SpringSemStart := DMY2DATE(12, 1, 2023);
                SummerSemStart := DMY2DATE(15, 4, 2023);
                FallSemStart := DMY2DATE(10, 8, 2023);

                //End dates for the semesters
                SpringSemEnd := DMY2DATE(25, 3, 2023);
                SummerSemEnd := DMY2DATE(28, 7, 2023);
                FallSemEnd := DMY2DATE(12, 12, 2023);


                //Checking for Spring Semester
                IF (TODAY > SpringSemStart) OR (TODAY < SpringSemEnd) THEN
                    "Current Semester" := "Current Semester"::"Spring Semester";

                //Checking for Summer Semester
                IF (TODAY > SummerSemStart) OR (TODAY < SummerSemEnd) THEN
                    "Current Semester" := "Current Semester"::"Summer Semester";


                //Checking for Fall Semester
                IF (TODAY > FallSemStart) OR (TODAY < FallSemEnd) THEN
                    "Current Semester" := "Current Semester"::"Fall Semester";

                "Current Sessions" := ActiveLessons.COUNT;
            end;
        }
        field(2; "Code"; Code[10])
        {
        }
        field(3; "Current Semester"; Option)
        {
            OptionMembers = "Summer Semester","Spring Semester","Fall Semester";
        }
        field(4; "Current Sessions"; Integer)
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
        SpringSemStart: Date;
        SummerSemStart: Date;
        FallSemStart: Date;
        SpringSemEnd: Date;
        SummerSemEnd: Date;
        FallSemEnd: Date;
        ActiveLessons: Record "Staff Assignment";
        StudentApplication: Record "Student Application";
}

