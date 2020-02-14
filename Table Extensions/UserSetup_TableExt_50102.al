tableextension 50002 "User Setup" extends "User Setup"
{
    fields
    {
        // Add changes to table fields here
        // field(50000; "OTP Approver"; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(50001; "Customer Limit Privileges"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Can Edit Emp Monthly Limit';
        }
        /* field(50002; "Price/Disc. Approver"; Boolean)
         {
             DataClassification = ToBeClassified;
         }*/
    }
    trigger OnBeforeModify()
    var
        myInt: Integer;
    begin
        if Rec."OTP Approver" then begin
            If xRec.FindSet() then begin
                repeat
                    if (xRec."User ID" <> Rec."User ID") and (xRec."OTP Approver" = true) then
                        Error('User ID : ' + xRec."User ID" + ' is already an OTP Approver.');
                until xRec.Next() = 0;
            end;
            TestField("E-Mail");
        end;
    end;

    var
        myInt: Integer;
}