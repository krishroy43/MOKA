pageextension 50006 RetailCustCard extends "Retail Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addafter(Shipping)
        {
            group(Configuration)
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
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}