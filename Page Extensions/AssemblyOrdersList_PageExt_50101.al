pageextension 50001 "Assembly Order List" extends "Assembly Orders"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        modify(Release)
        {
            trigger OnBeforeAction()
            begin
                CalculatePrice();
            end;
        }
        modify("P&ost")
        {
            trigger OnBeforeAction()
            begin
                CalculatePrice();
            end;
        }
    }
    local procedure CalculatePrice()
    var
        UnitCost: Decimal;
        TotalCost: Decimal;
        AsmLine: Record "Assembly Line";
        MokaEvents: Codeunit "MOKA Events";
    begin
        UnitCost := 0;
        TotalCost := 0;
        CLEAR(AsmLine);
        AsmLine.SETRANGE("Document Type", AsmLine."Document Type"::Order);
        AsmLine.SETRANGE("Document No.", Rec."No.");
        IF AsmLine.FINDSET THEN
            REPEAT
                /*If (AsmLine."Quantity per" = 0) OR (AsmLine."Unit Cost" = 0) then
                    Error(); //After validation user will not able to post with 0 price. 
                    */
                UnitCost += AsmLine."Quantity per" * AsmLine."Unit Cost";
                TotalCost += AsmLine.Quantity * AsmLine."Unit Cost";
            UNTIL AsmLine.NEXT = 0;
        Rec."Unit Cost" := ROUND(UnitCost, 1, '>');
        Rec."Cost Amount" := ROUND(TotalCost, 1, '>');
        MokaEvents.AddSalesPriceEntry(Rec);
    end;

    var
        myInt: Integer;
}