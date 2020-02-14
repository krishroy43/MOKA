pageextension 50000 AssemblyOrderCard extends "Assembly Order"
{
    layout
    {
        // Add changes to page layout here
        modify("Unit Cost")
        {
            Editable = false;
        }
        modify("Cost Amount")
        {
            Editable = false;
        }
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                if Rec."Item No." <> xRec."Item No." then begin
                    CalculateOnlyPrice();
                end;

            end;
        }
        addafter("Cost Amount")
        {
            field("Unit Price"; "Unit Price")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        modify("Re&lease")
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
        addafter(Release)
        {
            group("Update")
            {
                action("Update Kit Price")
                {
                    ApplicationArea = All;
                    Image = PriceAdjustment;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        CalculatePrice();
                    end;
                }
            }

        }
    }
    local procedure CalculatePrice()
    var
        UnitCost: Decimal;
        TotalCost: Decimal;
        unitPrice: Decimal;
        AsmLine: Record "Assembly Line";
        Text001: Label '';
        MokaEvents: Codeunit "MOKA Events";
    begin
        UnitCost := 0;
        TotalCost := 0;
        unitPrice := 0;
        CLEAR(AsmLine);
        AsmLine.SETRANGE("Document Type", AsmLine."Document Type"::Order);
        AsmLine.SETRANGE("Document No.", Rec."No.");
        IF AsmLine.FINDSET THEN
            REPEAT
                AsmLine.TestField(Quantity);
                AsmLine.TestField("Unit Cost");
                UnitCost += AsmLine."Quantity per" * AsmLine."Unit Cost";
                unitPrice += AsmLine."Quantity per" * AsmLine."Unit Price";
                TotalCost += AsmLine.Quantity * AsmLine."Unit Cost";
            UNTIL AsmLine.NEXT = 0;
        Rec."Unit Cost" := ROUND(UnitCost, 1, '>');
        Rec."Cost Amount" := ROUND(TotalCost, 1, '>');
        Rec."Unit Price" := Round(unitPrice, 1, '>');
        MokaEvents.AddSalesPriceEntry(Rec);
    end;

    local procedure CalculateOnlyPrice()
    var
        UnitCost: Decimal;
        TotalCost: Decimal;
        AsmLine: Record "Assembly Line";
        Text001: Label '';
        MokaEvents: Codeunit "MOKA Events";
        unitPrice: Decimal;
    begin
        UnitCost := 0;
        TotalCost := 0;
        unitPrice := 0;
        CLEAR(AsmLine);
        AsmLine.SETRANGE("Document Type", AsmLine."Document Type"::Order);
        AsmLine.SETRANGE("Document No.", Rec."No.");
        IF AsmLine.FINDSET THEN
            REPEAT
                /*If (AsmLine."Quantity per" = 0) OR (AsmLine."Unit Cost" = 0) then
                    Error(); //After validation user will not able to post with 0 price. 
                    */
                UnitCost += AsmLine."Quantity per" * AsmLine."Unit Cost";
                unitPrice += AsmLine."Quantity per" * AsmLine."Unit Price";
                TotalCost += AsmLine.Quantity * AsmLine."Unit Cost";
            UNTIL AsmLine.NEXT = 0;
        Rec."Unit Cost" := ROUND(UnitCost, 1, '>');
        Rec."Cost Amount" := ROUND(TotalCost, 1, '>');
        Rec."Unit Price" := Round(unitPrice, 1, '>');
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