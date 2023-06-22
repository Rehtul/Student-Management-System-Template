report 50005 "Student Transcript"
{
    DefaultLayout = RDLC;
    RDLCLayout = './StudentTranscript.rdlc';

    dataset
    {
        dataitem(DataItem1; "Student Grade")
        {
            column(FullName; FullName)
            {
            }
            column(Year; Year)
            {
            }
            column(Semester; Semester)
            {
            }
            column(Units; Units)
            {
            }
            column(CAT1; CAT1)
            {
            }
            column(CAT2; CAT2)
            {
            }
            column(Final; Final)
            {
            }
            column(Grade; Grade)
            {
            }
            column(Condition; Condition)
            {
            }
            column(Supplementary; Supplementary)
            {
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }
}

