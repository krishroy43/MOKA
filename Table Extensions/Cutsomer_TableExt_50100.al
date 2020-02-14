tableextension 50000 CustomerExt extends Customer
{
    fields
    {
        // Add changes to table fields here
        field(50001; "Maximum Monthly Limit"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
                Clear(UserSetup);
                UserSetup.GET(UserId);
                if not UserSetup."Customer Limit Privileges" then
                    Error('You do not have permission to edit the Monthly Limit');
                "Remaining Amount" := ("Maximum Monthly Limit" - "Monthly Sales Value");
            end;
        }
        field(50002; "Monthly Sales Value"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
                Clear(UserSetup);
                UserSetup.GET(UserId);
                if not UserSetup."Customer Limit Privileges" then
                    Error('You do not have permission to edit the Monthly Limit');
                "Remaining Amount" := ("Maximum Monthly Limit" - "Monthly Sales Value");
            end;
        }
        field(50003; "Remaining Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

    }

    var
        myInt: Integer;
}