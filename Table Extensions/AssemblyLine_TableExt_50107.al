tableextension 50007 AssemblyLine extends "Assembly Line"
{
    fields
    {
        // Add changes to table fields here
        field(50001; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                RecItem: Record Item;
            begin
                if Type = Type::Item then begin
                    Clear(RecItem);
                    IF RecItem.GET("No.") then
                        "Unit Price" := RecItem."Unit Price";
                end else
                    "Unit Price" := 0;
            end;
        }
    }

    var
        myInt: Integer;
}