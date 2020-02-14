pageextension 50008 AsseblyOrderSubForm extends "Assembly Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Unit Cost")
        {
            field("Unit Price"; "Unit Price")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


    local procedure CalculateOnlyPrice()
    var
        UnitCost: Decimal;
        TotalCost: Decimal;
        AsmHeader: Record "Assembly Header";
    begin
        UnitCost := 0;
        TotalCost := 0;
        IF xRec.FINDSET THEN
            REPEAT
                UnitCost += xRec."Quantity per" * xRec."Unit Cost";
                TotalCost += xRec.Quantity * xRec."Unit Cost";
            UNTIL xRec.NEXT = 0;
        Clear(AsmHeader);
        AsmHeader.SetRange("Document Type", AsmHeader."Document Type"::Order);
        AsmHeader.SetRange("No.", Rec."Document No.");
        if AsmHeader.FindFirst() then begin
            AsmHeader."Unit Cost" := ROUND(UnitCost, 1, '>');
            AsmHeader."Cost Amount" := ROUND(TotalCost, 1, '>');
            AsmHeader.Modify();
        end;

    end;

    var
        myInt: Integer;

    trigger OnModifyRecord(): Boolean
    var
        myInt: Integer;
    begin
        CalculateOnlyPrice();
    end;

}