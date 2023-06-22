tableextension 50064 SalesLineExt extends "Sales Line"
{
    fields
    {
        modify("No.")
        {
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account"),
            "System-Created Entry" = CONST(false)) "G/L Account" WHERE("Direct Posting" = CONST(true), "Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE
            IF (Type = CONST("G/L Account"), "System-Created Entry" = CONST(true)) "G/L Account"
            ELSE
            IF (Type = CONST(Resource)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge"
            ELSE
            IF (Type = CONST(Item), "Document Type" = FILTER(<> "Credit Memo" & <> "Return Order")) Item WHERE(Blocked = CONST(false), "Sales Blocked" = CONST(false))
            ELSE
            IF (Type = CONST(Item), "Document Type" = FILTER("Credit Memo" | "Return Order")) Item WHERE(Blocked = CONST(false))
            else
            if (Type = CONST(Units)) "Unit Code Setup";
            trigger OnAfterValidate()
            var
                TempSalesLine: Record "Sales Line" temporary;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateNo(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                GetSalesSetup();

                "No." := FindOrCreateRecordByNo("No.");

                TestJobPlanningLine();
                TestStatusOpen();
                CheckItemAvailable(FieldNo("No."));

                if (xRec."No." <> "No.") and (Quantity <> 0) then begin
                    TestField("Qty. to Asm. to Order (Base)", 0);
                    CalcFields("Reserved Qty. (Base)");
                    TestField("Reserved Qty. (Base)", 0);
                    if Type = Type::Item then
                        WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                    OnValidateNoOnAfterVerifyChange(Rec, xRec);
                end;

                TestField("Qty. Shipped Not Invoiced", 0);
                TestField("Quantity Shipped", 0);
                TestField("Shipment No.", '');

                TestField("Prepmt. Amt. Inv.", 0);

                TestField("Return Qty. Rcd. Not Invd.", 0);
                TestField("Return Qty. Received", 0);
                TestField("Return Receipt No.", '');

                if "No." = '' then
                    ATOLink.DeleteAsmFromSalesLine(Rec);
                CheckAssocPurchOrder(FieldCaption("No."));
                AddOnIntegrMgt.CheckReceiptOrderStatus(Rec);

                OnValidateNoOnBeforeInitRec(Rec, xRec, CurrFieldNo);
                TempSalesLine := Rec;
                Init();
                SystemId := TempSalesLine.SystemId;
                if xRec."Line Amount" <> 0 then
                    "Recalculate Invoice Disc." := true;
                Type := TempSalesLine.Type;
                "No." := TempSalesLine."No.";
                OnValidateNoOnCopyFromTempSalesLine(Rec, TempSalesLine, xRec);
                if "No." = '' then
                    exit;

                if HasTypeToFillMandatoryFields() then
                    Quantity := TempSalesLine.Quantity;

                "System-Created Entry" := TempSalesLine."System-Created Entry";
                GetSalesHeader();
                OnValidateNoOnBeforeInitHeaderDefaults(SalesHeader, Rec);
                InitHeaderDefaults(SalesHeader);
                OnValidateNoOnAfterInitHeaderDefaults(SalesHeader, TempSalesLine);

                CalcFields("Substitution Available");

                "Promised Delivery Date" := SalesHeader."Promised Delivery Date";
                "Requested Delivery Date" := SalesHeader."Requested Delivery Date";

                IsHandled := false;
                OnValidateNoOnBeforeCalcShipmentDateForLocation(IsHandled, Rec);
                if not IsHandled then
                    CalcShipmentDateForLocation();

                IsHandled := false;
                OnValidateNoOnBeforeUpdateDates(Rec, xRec, SalesHeader, CurrFieldNo, IsHandled, TempSalesLine);
                if not IsHandled then
                    UpdateDates();

                OnAfterAssignHeaderValues(Rec, SalesHeader);

                case Type of
                    Type::" ":
                        CopyFromStandardText();
                    Type::"G/L Account":
                        CopyFromGLAccount();
                    Type::Item:
                        CopyFromItem();
                    Type::Resource:
                        CopyFromResource();
                    Type::"Fixed Asset":
                        CopyFromFixedAsset();
                    Type::"Charge (Item)":
                        CopyFromItemCharge();
                    Type::Units:
                        CopyFromUnitCode();
                end;

                OnAfterAssignFieldsForNo(Rec, xRec, SalesHeader);

                if Type <> Type::" " then begin
                    PostingSetupMgt.CheckGenPostingSetupSalesAccount("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                    PostingSetupMgt.CheckGenPostingSetupCOGSAccount("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                    PostingSetupMgt.CheckVATPostingSetupSalesAccount("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                end;

                if HasTypeToFillMandatoryFields() and (Type <> Type::"Fixed Asset") then
                    ValidateVATProdPostingGroup();

                UpdatePrepmtSetupFields();

                if HasTypeToFillMandatoryFields() then begin
                    PlanPriceCalcByField(FieldNo("No."));
                    ValidateUnitOfMeasureCodeFromNo();
                    if Quantity <> 0 then begin
                        InitOutstanding();
                        if IsCreditDocType() then
                            InitQtyToReceive()
                        else
                            InitQtyToShip();
                        InitQtyToAsm();
                        UpdateWithWarehouseShip();
                    end;
                end;

                CreateDimFromDefaultDim(Rec.FieldNo("No."));

                if "No." <> xRec."No." then begin
                    if Type = Type::Item then
                        if (Quantity <> 0) and ItemExists(xRec."No.") then begin
                            VerifyChangeForSalesLineReserve(FieldNo("No."));
                            WhseValidateSourceLine.SalesLineVerifyChange(Rec, xRec);
                        end;
                    GetDefaultBin();
                    AutoAsmToOrder();
                    DeleteItemChargeAssignment("Document Type", "Document No.", "Line No.");
                    if Type = Type::"Charge (Item)" then
                        DeleteChargeChargeAssgnt("Document Type", "Document No.", "Line No.");
                end;

                UpdateItemReference();

                UpdateUnitPriceByField(FieldNo("No."));

                OnValidateNoOnAfterUpdateUnitPrice(Rec, xRec, TempSalesLine);
            end;
        }
    }

    var

        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        ATOLink: Record "Assemble-to-Order Link";
        AddOnIntegrMgt: Codeunit AddOnIntegrManagement;
        SalesHeader: Record "Sales Header";
        PostingSetupMgt: Codeunit PostingSetupManagement;
        SalesSetupRead: Boolean;
        SalesSetup: Record "Sales & Receivables Setup";
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
        Text031: Label 'You must either specify %1 or %2.';
        GLAcc: Record "G/L Account";
        Res: Record Resource;
        BlockedItemNotificationMsg: Label 'Item %1 is blocked, but it is allowed on this type of document.', Comment = '%1 is Item No.';
        SalesBlockedErr: Label 'You cannot sell this item because the Sales Blocked check box is selected on the item card.';
        PriceType: Enum "Price Type";
        ItemCharge: Record "Item Charge";
        ItemReferenceMgt: Codeunit "Item Reference Management";
        Location: Record Location;
        DimMgt: Codeunit DimensionManagement;
        UnitPriceChangedMsg: Label 'The unit price for %1 %2 that was copied from the posted document has been changed.', Comment = '%1 = Type caption %2 = No.';
        TempErrorMessage: Record "Error Message" temporary;





    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateNo(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterVerifyChange(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnBeforeInitRec(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnCopyFromTempSalesLine(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnBeforeInitHeaderDefaults(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterInitHeaderDefaults(var SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateNoOnBeforeCalcShipmentDateForLocation(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnBeforeUpdateDates(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CallingFieldNo: Integer; var IsHandled: Boolean; var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignHeaderValues(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFieldsForNo(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNoOnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFAPostingGroup(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetGetFAPostingGroupOnBeforeExit(var SalesLine: Record "Sales Line"; var ShouldExit: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesSetup(var SalesLine: Record "Sales Line"; var SalesSetup: Record "Sales & Receivables Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetFAPostingGroup(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestJobPlanningLine(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitHeaderLocactionCode(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced with OnValidateLocationCodeOnAfterCheckAssocPurchOrder and OnBeforeInitHeaderLocactionCode', '20.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateLocationCode(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitHeaderDefaults(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; xSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignStdTxtValues(var SalesLine: Record "Sales Line"; StandardText: Record "Standard Text"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignGLAccountValues(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyFromItem(var SalesLine: Record "Sales Line"; Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromItem(var SalesLine: Record "Sales Line"; Item: Record Item; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemValues(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetDefaultItemQuantity(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromItemOnAfterCheck(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyFromResourceOnBeforeTestBlocked(var Resoiurce: Record Resource; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignResourceValues(var SalesLine: Record "Sales Line"; Resource: Record Resource; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignFixedAssetValues(var SalesLine: Record "Sales Line"; FixedAsset: Record "Fixed Asset"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignUnitCodeValues(var SalesLine: Record "Sales Line"; UnitCodeSetup: Record "Unit Code Setup"; SalesHeader: Record "Sales Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignItemChargeValues(var SalesLine: Record "Sales Line"; ItemCharge: Record "Item Charge"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateVATProdPostingGroup(var IsHandled: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateUnitOfMeasureCodeFromNo(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteChargeChargeAssgnt(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateItemReference(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDefaultBin(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDefaultBin(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var SalesLine: Record "Sales Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitPriceOnBeforeFindPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitPriceByFieldOnAfterFindPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowUnitPriceChangedMsg(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;


    local procedure GetSalesSetup()
    begin
        if not SalesSetupRead then
            SalesSetup.Get();
        SalesSetupRead := true;

        OnAfterGetSalesSetup(Rec, SalesSetup);
    end;

    local procedure GetFAPostingGroup()
    var
        LocalGLAcc: Record "G/L Account";
        FASetup: Record "FA Setup";
        FAPostingGr: Record "FA Posting Group";
        FADeprBook: Record "FA Depreciation Book";
        ShouldExit: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetFAPostingGroup(Rec, IsHandled);
        if IsHandled then
            exit;

        if (Type <> Type::"Fixed Asset") or ("No." = '') then
            exit;

        if "Depreciation Book Code" = '' then begin
            FASetup.Get();
            "Depreciation Book Code" := FASetup."Default Depr. Book";
            if not FADeprBook.Get("No.", "Depreciation Book Code") then
                "Depreciation Book Code" := '';

            ShouldExit := "Depreciation Book Code" = '';
            OnGetGetFAPostingGroupOnBeforeExit(Rec, ShouldExit);
            if ShouldExit then
                exit;
        end;

        FADeprBook.Get("No.", "Depreciation Book Code");
        FADeprBook.TestField("FA Posting Group");
        FAPostingGr.GetPostingGroup(FADeprBook."FA Posting Group", FADeprBook."Depreciation Book Code");
        LocalGLAcc.Get(FAPostingGr.GetAcquisitionCostAccountOnDisposal);
        LocalGLAcc.CheckGLAcc();
        if not ApplicationAreaMgmt.IsSalesTaxEnabled then
            LocalGLAcc.TestField("Gen. Prod. Posting Group");
        "Posting Group" := FADeprBook."FA Posting Group";
        "Gen. Prod. Posting Group" := LocalGLAcc."Gen. Prod. Posting Group";
        "Tax Group Code" := LocalGLAcc."Tax Group Code";
        Validate("VAT Prod. Posting Group", LocalGLAcc."VAT Prod. Posting Group");

        OnAfterGetFAPostingGroup(Rec, LocalGLAcc);
    end;

    local procedure TestJobPlanningLine()
    var
        JobPostLine: Codeunit "Job Post-Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestJobPlanningLine(Rec, IsHandled, CurrFieldNo);
        if IsHandled then
            exit;

        if "Job Contract Entry No." = 0 then
            exit;

        JobPostLine.TestSalesLine(Rec);
    end;

    local procedure InitHeaderDefaults(SalesHeader: Record "Sales Header")
    begin

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
            CheckQuoteCustomerTemplateCode(SalesHeader)
        else
            SalesHeader.TestField("Sell-to Customer No.");

        "Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        "Currency Code" := SalesHeader."Currency Code";
        InitHeaderLocactionCode(SalesHeader);
        "Customer Price Group" := SalesHeader."Customer Price Group";
        "Customer Disc. Group" := SalesHeader."Customer Disc. Group";
        "Allow Line Disc." := SalesHeader."Allow Line Disc.";
        "Transaction Type" := SalesHeader."Transaction Type";
        "Transport Method" := SalesHeader."Transport Method";
        "Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        "Price Calculation Method" := SalesHeader."Price Calculation Method";
        "Gen. Bus. Posting Group" := SalesHeader."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
        "Exit Point" := SalesHeader."Exit Point";
        Area := SalesHeader.Area;
        "Transaction Specification" := SalesHeader."Transaction Specification";
        "Tax Area Code" := SalesHeader."Tax Area Code";
        "Tax Liable" := SalesHeader."Tax Liable";
        if not "System-Created Entry" and ("Document Type" = "Document Type"::Order) and HasTypeToFillMandatoryFields() or
           IsServiceChargeLine()
        then
            "Prepayment %" := SalesHeader."Prepayment %";
        "Prepayment Tax Area Code" := SalesHeader."Tax Area Code";
        "Prepayment Tax Liable" := SalesHeader."Tax Liable";
        "Responsibility Center" := SalesHeader."Responsibility Center";

        "Shipping Agent Code" := SalesHeader."Shipping Agent Code";
        "Shipping Agent Service Code" := SalesHeader."Shipping Agent Service Code";
        "Outbound Whse. Handling Time" := SalesHeader."Outbound Whse. Handling Time";
        "Shipping Time" := SalesHeader."Shipping Time";

        OnAfterInitHeaderDefaults(Rec, SalesHeader, xRec);
    end;

    local procedure CheckQuoteCustomerTemplateCode(SalesHeader: Record "Sales Header")
    var
        StudentApplication: Record "Student Application";
        UnitCodeSetup: Record "Unit Code Setup";
    //val: Code;
    begin
        if (SalesHeader."Sell-to Customer No." = '') and
           (SalesHeader."Sell-to Customer Templ. Code" = '')
        then
            //Error(
            //  Text031,
            //  SalesHeader.FieldCaption("Sell-to Customer No."),
            //  SalesHeader.FieldCaption("Sell-to Customer Templ. Code"));
            SalesHeader."Sell-to Customer No." := StudentApplication."No.Series";
        if (SalesHeader."Bill-to Customer No." = '') and
           (SalesHeader."Bill-to Customer Templ. Code" = '')
        then
            //Error(
            //  Text031,
            //  SalesHeader.FieldCaption("Bill-to Customer No."),
            //  SalesHeader.FieldCaption("Bill-to Customer Templ. Code"));
            //SalesHeader."Bill-to Customer No." := Evaluate((UnitCodeSetup."Unit No"),val);
            SalesHeader."Bill-to Customer No." := StudentApplication.No;
    end;

    local procedure InitHeaderLocactionCode(SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitHeaderLocactionCode(Rec, IsHandled);
        if IsHandled then
            exit;
#if not CLEAN20
        IsHandled := false;
        OnBeforeUpdateLocationCode(Rec, IsHandled);
        if not IsHandled then
#endif
        "Location Code" := SalesHeader."Location Code";
    end;

    local procedure CopyFromStandardText()
    var
        StandardText: Record "Standard Text";
    begin
        "Tax Area Code" := '';
        "Tax Liable" := false;
        StandardText.Get("No.");
        Description := StandardText.Description;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignStdTxtValues(Rec, StandardText, SalesHeader);
    end;

    local procedure CopyFromGLAccount()
    begin
        GLAcc.Get("No.");
        GLAcc.CheckGLAcc;
        if not "System-Created Entry" then
            GLAcc.TestField("Direct Posting", true);
        Description := GLAcc.Name;
        "Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := GLAcc."VAT Prod. Posting Group";
        "Tax Group Code" := GLAcc."Tax Group Code";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        InitDeferralCode();
        OnAfterAssignGLAccountValues(Rec, GLAcc, SalesHeader);
    end;

    local procedure InitDeferralCode()
    var
        Item: Record Item;
    begin
        if "Document Type" in
           ["Document Type"::Order, "Document Type"::Invoice, "Document Type"::"Credit Memo", "Document Type"::"Return Order"]
        then
            case Type of
                Type::"G/L Account":
                    Validate("Deferral Code", GLAcc."Default Deferral Template Code");
                Type::Item:
                    begin
                        GetItem(Item);
                        Validate("Deferral Code", Item."Default Deferral Template Code");
                    end;
                Type::Resource:
                    Validate("Deferral Code", Res."Default Deferral Template Code");
            end;
    end;

    local procedure CopyFromItem()
    var
        Item: Record Item;
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        IsHandled: Boolean;
    begin
        GetItem(Item);
        IsHandled := false;
        OnBeforeCopyFromItem(Rec, Item, IsHandled);
        if not IsHandled then begin
            Item.TestField(Blocked, false);
            Item.TestField("Gen. Prod. Posting Group");
            if Item."Sales Blocked" then
                if IsCreditDocType() then
                    SendBlockedItemNotification()
                else
                    Error(SalesBlockedErr);
            if Item.Type = Item.Type::Inventory then begin
                Item.TestField("Inventory Posting Group");
                "Posting Group" := Item."Inventory Posting Group";
            end;
        end;

        OnCopyFromItemOnAfterCheck(Rec, Item);

        Description := Item.Description;
        "Description 2" := Item."Description 2";
        GetUnitCost();
        "Allow Invoice Disc." := Item."Allow Invoice Disc.";
        "Units per Parcel" := Item."Units per Parcel";
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Tax Group Code" := Item."Tax Group Code";
        "Item Category Code" := Item."Item Category Code";
        Nonstock := Item."Created From Nonstock Item";
        "Profit %" := Item."Profit %";
        "Allow Item Charge Assignment" := true;
        PrepaymentMgt.SetSalesPrepaymentPct(Rec, SalesHeader."Posting Date");
        if IsInventoriableItem() then
            PostingSetupMgt.CheckInvtPostingSetupInventoryAccount("Location Code", "Posting Group");

        if SalesHeader."Language Code" <> '' then
            GetItemTranslation();

        if Item.Reserve = Item.Reserve::Optional then
            Reserve := SalesHeader.Reserve
        else
            Reserve := Item.Reserve;

        if Item."Sales Unit of Measure" <> '' then
            "Unit of Measure Code" := Item."Sales Unit of Measure"
        else
            "Unit of Measure Code" := Item."Base Unit of Measure";

        if "Document Type" in ["Document Type"::Quote, "Document Type"::Order] then
            Validate("Purchasing Code", Item."Purchasing Code");
        OnAfterCopyFromItem(Rec, Item, CurrFieldNo);

        InitDeferralCode();
        SetDefaultItemQuantity();
        OnAfterAssignItemValues(Rec, Item);
    end;

    local procedure SendBlockedItemNotification()
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        NotificationToSend: Notification;
    begin
        NotificationToSend.Id := GetBlockedItemNotificationID();
        NotificationToSend.Recall();
        NotificationToSend.Message := StrSubstNo(BlockedItemNotificationMsg, "No.");
        NotificationLifecycleMgt.SendNotification(NotificationToSend, RecordId);
    end;

    local procedure GetBlockedItemNotificationID(): Guid
    begin
        exit('963A9FD3-11E8-4CAA-BE3A-7F8CEC9EF8EC');
    end;

    local procedure SetDefaultItemQuantity()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetDefaultItemQuantity(Rec, IsHandled);
        if IsHandled then
            exit;

        GetSalesSetup();
        if SalesSetup."Default Item Quantity" then begin
            Validate(Quantity, 1);
            CheckItemAvailable(CurrFieldNo);
        end;
    end;

    local procedure CopyFromResource()
    var
        IsHandled: Boolean;
    begin
        Res.Get("No.");
        Res.CheckResourcePrivacyBlocked(false);
        IsHandled := false;
        OnCopyFromResourceOnBeforeTestBlocked(Res, IsHandled);
        if not IsHandled then
            Res.TestField(Blocked, false);
        Res.TestField("Gen. Prod. Posting Group");
        Description := Res.Name;
        "Description 2" := Res."Name 2";
        "Unit of Measure Code" := Res."Base Unit of Measure";
        "Unit Cost (LCY)" := Res."Unit Cost";
        "Gen. Prod. Posting Group" := Res."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Res."VAT Prod. Posting Group";
        "Tax Group Code" := Res."Tax Group Code";
        "Allow Item Charge Assignment" := false;
        ApplyResUnitCost(FieldNo("No."));
        InitDeferralCode();
        OnAfterAssignResourceValues(Rec, Res, SalesHeader);
    end;

    local procedure ApplyResUnitCost(CalledByFieldNo: Integer)
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        GetPriceCalculationHandler(PriceType::Purchase, SalesHeader, PriceCalculation);
        PriceCalculation.ApplyPrice(CalledByFieldNo);
        GetLineWithCalculatedPrice(PriceCalculation);
        Validate("Unit Cost (LCY)");
    end;

    local procedure GetLineWithCalculatedPrice(var PriceCalculation: Interface "Price Calculation")
    var
        Line: Variant;
    begin
        PriceCalculation.GetLine(Line);
        Rec := Line;
    end;

    local procedure CopyFromFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get("No.");
        FixedAsset.TestField(Inactive, false);
        FixedAsset.TestField(Blocked, false);
        GetFAPostingGroup();
        Description := FixedAsset.Description;
        "Description 2" := FixedAsset."Description 2";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignFixedAssetValues(Rec, FixedAsset, SalesHeader);
    end;

    local procedure CopyFromUnitCode()
    var
        UnitCodeSetup: Record "Unit Code Setup";
    begin
        UnitCodeSetup.GET("No.");
        "No." := FORMAT(UnitCodeSetup."Unit No");
        Description := UnitCodeSetup."Unit Description";
        "Description 2" := UnitCodeSetup."Unit Description";
        //MESSAGE('This part is working');
        "Unit Cost" := UnitCodeSetup."Unit Price";
        "VAT Prod. Posting Group" := UnitCodeSetup."VAT Prod. Posting Group";
        "VAT Bus. Posting Group" := UnitCodeSetup."VAT Bus. Posting Group";
        "Gen. Bus. Posting Group" := UnitCodeSetup."Gen. Bus. Posting Group";
        "Gen. Prod. Posting Group" := UnitCodeSetup."Gen. Prod. Posting Group";
        Quantity := UnitCodeSetup.Quantity;
        "Unit Price" := UnitCodeSetup."Unit Price";
        "Allow Invoice Disc." := FALSE;
        OnAfterAssignUnitCodeValues(Rec, UnitCodeSetup, SalesHeader);
    end;

    local procedure CopyFromItemCharge()
    begin
        ItemCharge.Get("No.");
        Description := ItemCharge.Description;
        "Gen. Prod. Posting Group" := ItemCharge."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := ItemCharge."VAT Prod. Posting Group";
        "Tax Group Code" := ItemCharge."Tax Group Code";
        "Allow Invoice Disc." := false;
        "Allow Item Charge Assignment" := false;
        OnAfterAssignItemChargeValues(Rec, ItemCharge, SalesHeader);
    end;

    local procedure ValidateVATProdPostingGroup()
    var
        IsHandled: boolean;
    begin
        IsHandled := false;
        OnBeforeValidateVATProdPostingGroup(IsHandled, Rec);
        if IsHandled then
            exit;

        Validate("VAT Prod. Posting Group");
    end;

    local procedure ValidateUnitOfMeasureCodeFromNo()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateUnitOfMeasureCodeFromNo(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        Validate("Unit of Measure Code");
    end;

    local procedure DeleteChargeChargeAssgnt(DocType: Enum "Sales Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        if DocType <> "Document Type"::"Blanket Order" then
            if "Quantity Invoiced" <> 0 then begin
                CalcFields("Qty. Assigned");
                TestField("Qty. Assigned", "Quantity Invoiced");
            end;

        ItemChargeAssgntSales.Reset();
        ItemChargeAssgntSales.SetRange("Document Type", DocType);
        ItemChargeAssgntSales.SetRange("Document No.", DocNo);
        ItemChargeAssgntSales.SetRange("Document Line No.", DocLineNo);
        if not ItemChargeAssgntSales.IsEmpty() then
            ItemChargeAssgntSales.DeleteAll();

        OnAfterDeleteChargeChargeAssgnt(Rec, xRec, CurrFieldNo);
    end;

    local procedure UpdateItemReference()
    begin
        ItemReferenceMgt.EnterSalesItemReference(Rec);
        UpdateICPartner();

        OnAfterUpdateItemReference(Rec);
    end;

    procedure GetDefaultBin()
    var
        WMSManagement: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDefaultBin(Rec, IsHandled);
        if IsHandled then
            exit;

        if (Type <> Type::Item) or IsNonInventoriableItem() then
            exit;

        "Bin Code" := '';
        if "Drop Shipment" then
            exit;

        if ("Location Code" <> '') and ("No." <> '') then begin
            GetLocation("Location Code");
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then begin
                if ("Qty. to Assemble to Order" > 0) or IsAsmToOrderRequired then
                    if GetATOBin(Location, "Bin Code") then
                        exit;

                if not IsShipmentBinOverridesDefaultBin(Location) then begin
                    WMSManagement.GetDefaultBin("No.", "Variant Code", "Location Code", "Bin Code");
                    HandleDedicatedBin(false);
                end;
            end;
        end;

        OnAfterGetDefaultBin(Rec);
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure IsShipmentBinOverridesDefaultBin(Location: Record Location): Boolean
    var
        Bin: Record Bin;
        ShipmentBinAvailable: Boolean;
    begin
        ShipmentBinAvailable := Bin.Get(Location.Code, Location."Shipment Bin Code");
        exit(Location."Require Shipment" and ShipmentBinAvailable);
    end;

    procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure HandleDedicatedBin(IssueWarning: Boolean)
    var
        WhseIntegrationMgt: Codeunit "Whse. Integration Management";
    begin
        if IsInbound() or ("Quantity (Base)" = 0) or ("Document Type" = "Document Type"::"Blanket Order") then
            exit;

        WhseIntegrationMgt.CheckIfBinDedicatedOnSrcDoc("Location Code", "Bin Code", IssueWarning);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        DimMgt.AddDimSource(DefaultDimSource, DimMgt.SalesLineTypeToTableID(Type), Rec."No.", FieldNo = Rec.FieldNo("No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", Rec."Responsibility Center", FieldNo = Rec.FieldNo("Responsibility Center"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Job, Rec."Job No.", FieldNo = Rec.FieldNo("Job No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, Rec."Location Code", FieldNo = Rec.FieldNo("Location Code"));

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource);
    end;

    local procedure UpdateUnitPriceByField(CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
        PriceCalculation: Interface "Price Calculation";
    begin
        if not IsPriceCalcCalledByField(CalledByFieldNo) then
            exit;

        IsHandled := false;
        OnBeforeUpdateUnitPrice(Rec, xRec, CalledByFieldNo, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        GetSalesHeader();
        TestField("Qty. per Unit of Measure");

        case Type of
            Type::"G/L Account",
            Type::Item,
            Type::Resource:
                begin
                    IsHandled := false;
                    OnUpdateUnitPriceOnBeforeFindPrice(SalesHeader, Rec, CalledByFieldNo, CurrFieldNo, IsHandled);
                    if not IsHandled then begin
                        GetPriceCalculationHandler(PriceType::Sale, SalesHeader, PriceCalculation);
                        if not ("Copied From Posted Doc." and IsCreditDocType()) then begin
                            PriceCalculation.ApplyDiscount();
                            ApplyPrice(CalledByFieldNo, PriceCalculation);
                        end;
                    end;
                    OnUpdateUnitPriceByFieldOnAfterFindPrice(SalesHeader, Rec, CalledByFieldNo, CurrFieldNo);
                end;
        end;

        ShowUnitPriceChangedMsg();

        Validate("Unit Price");

        ClearFieldCausedPriceCalculation();
        OnAfterUpdateUnitPrice(Rec, xRec, CalledByFieldNo, CurrFieldNo);
    end;

    local procedure ShowUnitPriceChangedMsg()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowUnitPriceChangedMsg(Rec, xRec, IsHandled);
        if IsHandled then
            exit;
        if "Copied From Posted Doc." and IsCreditDocType() and ("Appl.-from Item Entry" <> 0) then
            if xRec."Unit Price" <> "Unit Price" then
                if GuiAllowed then
                    ShowMessageOnce(StrSubstNo(UnitPriceChangedMsg, Type, "No."));
    end;

    local procedure ShowMessageOnce(MessageText: Text)
    begin
        TempErrorMessage.SetContext(Rec);
        if TempErrorMessage.FindRecord(RecordId, 0, TempErrorMessage."Message Type"::Warning, MessageText) = 0 then begin
            TempErrorMessage.LogMessage(Rec, 0, TempErrorMessage."Message Type"::Warning, MessageText);
            Message(MessageText);
        end;
    end;


}