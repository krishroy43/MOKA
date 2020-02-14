pageextension 50007 RetailsCustExt extends "Retail Customer List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Customer Posting Group")
        {
            field("Maximum Monthly Limit"; "Maximum Monthly Limit")
            {
                ApplicationArea = All;
            }
            field("Monthly Sales Value"; "Monthly Sales Value")
            {
                ApplicationArea = All;
            }
            field("Remaining Amount"; "Remaining Amount")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}