table 50059 "Staff Assignment"
{

    fields
    {
        field(1; No; Integer)
        {
        }
        field(2; "Code"; Code[10])
        {
        }
        field(3; Staff; Text[250])
        {
            TableRelation = "Academic Staff Setup".FullName;

            trigger OnValidate()
            begin
                AcademicStaffSetup.RESET;
                AcademicStaffSetup.SETRANGE(FullName, Staff);
                IF AcademicStaffSetup.FINDFIRST THEN BEGIN
                    //Staff := AcademicStaffSetup.FullName;
                    IF (AcademicStaffSetup.Availability = AcademicStaffSetup.Availability::Yes) THEN
                        Staff := AcademicStaffSetup.FullName;
                    IF (AcademicStaffSetup.Availability = AcademicStaffSetup.Availability::No) THEN
                        ERROR('The staff you are attempting to assign is currently not available');
                END
            end;
        }
        field(4; StartDate; Date)
        {
        }
        field(5; EndDate; Date)
        {
        }
        field(6; Semester; Option)
        {
            OptionMembers = Spring,Summer,Fall;

            trigger OnValidate()
            begin
                SpringSem := DMY2DATE(12, 1, 2023);
                SummerSem := DMY2DATE(15, 4, 2023);
                FallSem := DMY2DATE(10, 8, 2023);

                //Checking for Spring Semester
                IF (Semester = Semester::Spring) THEN
                    IF (TODAY > SpringSem) THEN
                        ERROR('Past Application for Spring Semester Availability Registration. Contact School Dean for Info.');


                //Checking for Summer Semester
                IF (Semester = Semester::Summer) THEN
                    IF (TODAY > SummerSem) THEN
                        ERROR('Past Application for Summer Semester Availability Registration. Contact School Dean for Info.');


                //Checking for Fall Semester
                IF (Semester = Semester::Fall) THEN
                    IF (TODAY > FallSem) THEN
                        ERROR('Past Application for Fall Semester Availability Registration. Contact School Dean for Info.');
            end;
        }
        field(7; Year; Option)
        {
            OptionMembers = "2023","2024","2025","2026","2027","2028","2029","2030","2031","2032","2033","2034","2035","2036";
        }
        field(8; "Unit Code"; Integer)
        {
            TableRelation = "Unit Code Setup"."Unit No";

            trigger OnValidate()
            begin
                UnitSetup.GET("Unit Code");
                "Unit Name" := UnitSetup."Unit Name";
            end;
        }
        field(9; "Unit Name"; Text[250])
        {
        }
        field(10; Venue; Option)
        {
            OptionMembers = "Kabete Rm101","Kabete Rm102","Kabete Rm103","Kabete Rm104","Kabete Rm105","Chiromo Lt1","Chiromo Lt2","Chiromo Lt3","Chiromo Lt4";
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
        AcademicStaffSetup: Record "Academic Staff Setup";
        UnitSetup: Record "Unit Code Setup";
        SpringSem: Date;
        SummerSem: Date;
        FallSem: Date;
}

