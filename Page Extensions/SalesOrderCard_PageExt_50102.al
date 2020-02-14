pageextension 50002 salesOrderCard extends "Sales Order"
{
    layout
    {
        addafter("Discount Approval")
        {
            field(Both; Both)
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        // Add changes to page layout here
        modify("Price Approval")
        {
            Editable = false;
        }
        modify("Discount Approval")
        {
            Editable = false;
        }
    }

    actions
    {
        // Add changes to page actions here
        addbefore("F&unctions")
        {

        }







    }

    var
        UserSetup: record "User Setup";

}