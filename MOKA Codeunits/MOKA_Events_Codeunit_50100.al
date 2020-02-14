codeunit 50003 "MOKA Events"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterPost', '', false, false)]
    procedure AddSalesPriceEntry(VAR AssemblyHeader: Record "Assembly Header")
    var
        SalesPrice: Record "Sales Price";
        RecItem: Record Item;
        RetailSetup: Record "Retail Setup";
    begin
        RecItem.SetCurrentKey("No.");
        Clear(RecItem);
        if RecItem.Get(AssemblyHeader."Item No.") then begin
            if RecItem.Blocked = true then begin
                RecItem.Blocked := false;
                RecItem."Block Reason" := '';
                RecItem.Modify();
            end;
        end;
        Clear(SalesPrice);
        SalesPrice.SetRange("Item No.", AssemblyHeader."Item No.");
        if SalesPrice.FindSet() then
            SalesPrice.DeleteAll();
        Clear(SalesPrice);
        SalesPrice.SetRange("Item No.", AssemblyHeader."Item No.");
        SalesPrice.SetRange("Variant Code", AssemblyHeader."Variant Code");
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
        SalesPrice.SetRange("Unit of Measure Code", AssemblyHeader."Unit of Measure Code");
        SalesPrice.SetRange("Sales Code", 'ALL');
        If SalesPrice.FindFirst() then begin
            SalesPrice.Validate("Unit Price", AssemblyHeader."Unit Price");
            if RetailSetup."Def. Price Includes VAT" then
                SalesPrice."Price Includes VAT" := TRUE;
            SalesPrice.Validate("VAT Bus. Posting Gr. (Price)", RetailSetup."Def. VAT Bus. Post Gr. (Price)");
            SalesPrice.Modify();
        end else begin
            SalesPrice.Init();
            SalesPrice.Validate("Item No.", AssemblyHeader."Item No.");
            SalesPrice."Variant Code" := AssemblyHeader."Variant Code";
            SalesPrice."Sales Type" := SalesPrice."Sales Type"::"Customer Price Group";
            SalesPrice."Sales Code" := 'ALL';
            SalesPrice."Unit of Measure Code" := AssemblyHeader."Unit of Measure Code";
            SalesPrice.Validate("Unit Price", AssemblyHeader."Unit Price");
            if RetailSetup."Def. Price Includes VAT" then
                SalesPrice."Price Includes VAT" := TRUE;
            SalesPrice.Validate("VAT Bus. Posting Gr. (Price)", RetailSetup."Def. VAT Bus. Post Gr. (Price)");
            SalesPrice.Insert(true);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterUndoPost', '', false, false)]
    procedure BlockTheItem(VAR PostedAssemblyHeader: Record "Posted Assembly Header")
    var
        RecItem: Record Item;
    begin
        Clear(RecItem);
        RecItem.SetCurrentKey("No.");
        If RecItem.GET(PostedAssemblyHeader."Item No.") Then begin
            RecItem.Blocked := true;
            RecItem."Block Reason" := 'Undo from Posted Assembly Order';
            RecItem.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Post Utility", 'OnAfterPostTransaction', '', false, false)]
    procedure UpdateCustomerLimit(VAR TransactionHeader_p: Record "Transaction Header")
    var
        RecCust: Record Customer;
        LocalAmount: Decimal;
    begin
        Clear(RecCust);

        LocalAmount := 0;
        LocalAmount := ((TransactionHeader_p."Gross Amount" - TransactionHeader_p."Discount Amount") * -1);
        RecCust.SetCurrentKey("No.");
        if RecCust.GET(TransactionHeader_p."Customer No.") then begin
            if RecCust."Customer Posting Group" = 'EMPLOYEE' then begin
                if RecCust."Maximum Monthly Limit" = 0 then
                    Error('Maximum Monthly Limit is not defined');
                if NOT (LocalAmount <= RecCust."Remaining Amount") then
                    Error('Sales Amount is greater than Remaining Amount.');
                //RecCust.Validate("Monthly Sales Value", (RecCust."Monthly Sales Value" + LocalAmount));
                RecCust."Monthly Sales Value" := RecCust."Monthly Sales Value" + LocalAmount;
                RecCust."Remaining Amount" := RecCust."Maximum Monthly Limit" - RecCust."Monthly Sales Value";
                RecCust.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnAfterSelectCustomer', '', false, false)]
    procedure OnAfterSelectCustomer(VAR POSTransaction: Record "POS Transaction"; VAR POSTransLine: Record "POS Trans. Line"; VAR CurrInput: Text)
    Var
        RecCust: Record Customer;
        Text0001: Label 'Maximum Monthly Limit is not defined for this customer.';
        Text0002: Label 'Remaining Amount is Zero for this customer.';
    begin
        Clear(RecCust);
        RecCust.SetCurrentKey("No.");
        If RecCust.GET(POSTransaction."Customer No.") then begin
            If (RecCust."Customer Posting Group" = 'EMPLOYEE') AND (RecCust."Maximum Monthly Limit" <= 0) then begin
                POSTransaction."Customer No." := '';
                POSTransaction.Modify();
                CurrInput := '';
                Error(Text0001);
            end
            else
                if (RecCust."Customer Posting Group" = 'EMPLOYEE') AND (RecCust."Remaining Amount" <= 0) then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.Modify();
                    CurrInput := '';
                    Error(Text0002);
                end;

        end;
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnAfterTenderKeyPressed', '', false, false)]
    procedure CheckLimitBeforeposting(VAR POSTransaction: Record "POS Transaction"; VAR POSTransLine: Record "POS Trans. Line"; VAR CurrInput: Text; VAR TenderTypeCode: Code[10])
    var
        RecCust: Record Customer;
        LocalAmount: Decimal;
    begin
        Clear(RecCust);
        LocalAmount := 0;
        LocalAmount := POSTransaction."Gross Amount";//- POSTransaction."Total Discount");
        RecCust.SetCurrentKey("No.");
        if RecCust.GET(POSTransaction."Customer No.") then begin
            if RecCust."Customer Posting Group" = 'EMPLOYEE' then begin
                if RecCust."Maximum Monthly Limit" = 0 then
                    Error('Maximum Monthly Limit is not defined.');
                if NOT (LocalAmount <= RecCust."Remaining Amount") then begin
                    Error('Sales Amount is greater than Remaining Amount.');
                    CurrInput := '';
                end;
            end;
        end;
        if POSTransLine."System Generated OTP" <> POSTransLine."Manually Entered OTP" then
            Error('Approval is required for this transaction.');
        CurrInput := '';
    end;



}