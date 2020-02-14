pageextension 50004 UserSetup extends "User Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter(Email)
        {
            field("OTP Approver"; "OTP Approver")
            {
                ApplicationArea = All;
            }
            field("Customer Limit Privileges"; "Customer Limit Privileges")
            {
                ApplicationArea = All;
            }
            /* field("Price/Disc. Approver"; "Price/Disc. Approver")
             {
                 ApplicationArea = All;
             }*/
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}