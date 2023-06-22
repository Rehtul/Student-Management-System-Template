table 50034 "Course Setup"
{

    fields
    {
        field(1; CourseNo; Integer)
        {
        }
        field(2; CourseName; Text[30])
        {
        }
    }

    keys
    {
        key(Key1; CourseNo)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

