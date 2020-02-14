tableextension 50004 SalesHeaderExt extends "Sales Header"
{
    fields
    {
        field(50005; Both; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        modify("Discount Approval")
        {
            trigger OnAfterValidate()
            begin
                if "Discount Approval" AND "Price Approval" THEN BEGIN
                    "Discount Approval" := false;
                    "Price Approval" := false;
                    Both := true;
                END else
                    Both := false;
            end;
        }
        modify("Price Approval")
        {
            trigger OnAfterValidate()
            begin
                if "Discount Approval" AND "Price Approval" THEN BEGIN
                    "Discount Approval" := false;
                    "Price Approval" := false;
                    Both := true;
                END else
                    Both := false;
            end;
        }
        // Add changes to table fields here
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                SalesLine: Record "Sales Line";
            begin
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", "No.");
                if SalesLine.FindSet() then begin
                    "Price Approval" := true;
                    "Discount Approval" := true;
                end;
            end;
        }
        modify("Invoice Discount Value")
        {
            trigger OnBeforeValidate()
            var
                myInt: Integer;
            begin
                if ("Invoice Discount Value" <> 0) AND ("Invoice Discount Value" <> xRec."Invoice Discount Value") then begin
                    Validate("Discount Approval", true);
                end;
            end;
        }
    }

    trigger OnModify()
    var
        myInt: Integer;
    begin
        if ("Invoice Discount Value" <> 0) then begin
            Validate("Discount Approval", true);
        end;
    end;

    trigger OnBeforeDelete()
    var
        Sline: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        if "Document Type" <> "Document Type"::Order then
            exit;

        Clear(Sline);
        Sline.SetRange("Document Type", "Document Type"::Order);
        Sline.SetRange("Document No.", "No.");
        if not Sline.FindFirst() then begin
            Clear(SalesHeader);
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            SalesHeader.SetRange("No.", "No.");
            if SalesHeader.FindFirst() then begin
                SalesHeader.Validate("Price Approval", false);
                SalesHeader.Validate("Discount Approval", false);
                SalesHeader.Modify();
            end else begin
                if Sline.Count = 1 then begin
                    Clear(SalesHeader);
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", "No.");
                    if SalesHeader.FindFirst() then begin
                        SalesHeader.Validate("Price Approval", false);
                        SalesHeader.Validate("Discount Approval", false);
                        SalesHeader.Modify();
                    end;
                end;
            end;
        end;
    end;

}