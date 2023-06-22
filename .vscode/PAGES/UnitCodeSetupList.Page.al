page 50044 "Unit Code Setup List"
{
    PageType = Card;
    SourceTable = "Unit Code Setup";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Unit No"; Rec."Unit No")
                {
                }
                field("Unit Name"; Rec."Unit Name")
                {
                }
                field("Location Code"; Rec."Location Code")
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
                {
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                }
                field("Sales Account"; Rec."Sales Account")
                {
                }
            }
        }
    }

    actions
    {
    }
}

