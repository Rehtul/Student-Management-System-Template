page 50068 "Unit Code Page"
{
    PageType = Card;
    SourceTable = "Unit Code Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Primary No"; Rec."Primary No")
                {
                    Editable = false;
                }
                field("Unit No"; Rec."Unit No")
                {
                }
                field("Unit Description"; Rec."Unit Description")
                {
                }
                field("Unit Index"; Rec."Unit Name")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Unit Price"; Rec."Unit Price")
                {
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                { }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                { }
                field("Sales Account"; Rec."Sales Account")
                { }
            }
        }
    }

    actions
    {
    }
}

