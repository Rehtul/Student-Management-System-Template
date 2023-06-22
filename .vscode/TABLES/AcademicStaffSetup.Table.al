table 50060 "Academic Staff Setup"
{

    fields
    {
        field(1; No; Integer)
        {
            AutoIncrement = true;
            Editable = true;
        }
        field(2; "Code"; Code[10])
        {
        }
        field(3; Title; Option)
        {
            OptionMembers = "Dr.","Mr.","Ms.","Mrs.","Sir.","Madam.";
        }
        field(4; FirstName; Text[50])
        {
        }
        field(5; MiddleName; Text[50])
        {
        }
        field(6; SurName; Text[50])
        {

            trigger OnValidate()
            begin
                FullName := FirstName + ' ' + MiddleName + ' ' + SurName;
            end;
        }
        field(7; FullName; Text[250])
        {
            Editable = false;
        }
        field(8; MobileContact; BigInteger)
        {
        }
        field(9; EmailAddress; Text[50])
        {
        }
        field(10; Residence; Text[50])
        {
        }
        field(11; Address; BigInteger)
        {
        }
        field(12; AcademicQualification; Option)
        {
            OptionMembers = Certificate,Diploma,Degree,Masters,Doctoral;
        }
        field(13; Rate; BigInteger)
        {
            Caption = 'Rate in Ksh Per Hour';
        }
        field(14; WorkingHours; Integer)
        {
        }
        field(15; Availability; Option)
        {
            OptionMembers = Yes,No;
        }
        field(16; AvailabilityDate; Date)
        {

            trigger OnValidate()
            begin
                todaysdate := TODAY;
                IF (todaysdate > AvailabilityDate) THEN
                    ERROR('Starting date cannot be earlier than todays date. Please select another later date');
                Availability := Availability::No;
            end;
        }
        field(17; AvailabilityDuration; Option)
        {
            OptionMembers = "1 Week","2 Weeks","3 Weeks","A Month","A Month and Change","A Year",Years;
        }
        field(18; todaysdate; Date)
        {
        }
    }

    keys
    {
        key(Key1; FullName)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

