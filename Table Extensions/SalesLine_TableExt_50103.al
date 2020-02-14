tableextension 50003 "Sale Line" extends "Sales Line"
{
    fields
    {
        // Add changes to table fields here
    }

    trigger OnBeforeModify()
    var
        SalesHeader: Record "Sales Header";
        Sline: Record "Sales Line";
    begin
        if (Type = Type::Item) AND ("Document Type" = "Document Type"::Order) then begin
            Clear(Sline);
            Sline.init;
            Sline.Validate("Document Type", "Document Type"::Order);
            Sline.Validate("Document No.", "Document No.");
            Sline.Validate(Type, Type::Item);
            Sline.Validate("No.", "No.");
            Sline.Validate(Quantity, Quantity);

            If "Unit Price" <> xRec."Unit Price" then begin
                if "Unit Price" <> Sline."Unit Price" then begin
                    Clear(SalesHeader);
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", Rec."Document No.");
                    if SalesHeader.FindFirst() then begin
                        SalesHeader.Validate("Price Approval", True);
                        SalesHeader.Modify();
                    end;
                end;
            end;
            If "Line Discount %" <> xRec."Line Discount %" then begin
                if ("Line Discount %" <> Sline."Line Discount %") OR ("Line Discount Amount" <> Sline."Line Discount Amount") then begin
                    Clear(SalesHeader);
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", Rec."Document No.");
                    if SalesHeader.FindFirst() then begin
                        SalesHeader.Validate("Discount Approval", true);
                        SalesHeader.Modify();
                    end;
                end;
            End;
        end;

    end;

    var
        myInt: Integer;
}