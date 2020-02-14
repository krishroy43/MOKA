tableextension 50006 AssemblyHeader extends "Assembly Header"
{
    fields
    {
        // Add changes to table fields here
        field(50001; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}