public with sharing class sk4_CreateTransfers {
    private static Id getDefaultParentId(Id childId) {
        sk4_child__c child = (sk4_child__c) SOQL_Child.query().byId(childId).preview().toObject();
        return child.sk4_family__r.sk4_defaultParent__c;
    }

    private static String getRecordTypeId(String type) {
        return sk4_Const.TYPE_TO_RT_ID.get(type);
    }

    private static String getName(String type) {
        return type + '-' + String.valueOf(Date.today());
    }

    private static Decimal getCumulationAmount(sk4_child__c child) {
        if (child.sk4_balance2__c <= 0) {
            return 0;
        }

        Decimal transferAmount = child.sk4_balance2__c * child.sk4_family__r.sk4_cumulationPercent__c / 100;
        if (child.sk4_family__r.sk4_cumulationLowerTreshold__c != null) {
            transferAmount = Math.max(transferAmount, child.sk4_family__r.sk4_cumulationLowerTreshold__c);
        }
        if (child.sk4_family__r.sk4_cumulationUpperTreshold__c != null) {
            transferAmount = Math.min(transferAmount, child.sk4_family__r.sk4_cumulationUpperTreshold__c);
        }
        return transferAmount;
    }

    public static sk4_transfer__c createPocketMoneyTransfer(sk4_family__c family, Id childId) {
        sk4_transfer__c transfer = new sk4_transfer__c();
        transfer.sk4_type__c = sk4_Const.TRANSFER_TYPE_POCKETMONEY;
        transfer.RecordTypeId = getRecordTypeId(transfer.sk4_type__c);
        transfer.sk4_child__c = childId;
        transfer.sk4_parent__c = family.sk4_defaultParent__c;
        transfer.sk4_transferAmount__c = family.sk4_defaultPocketMoneyAmount__c;
        transfer.sk4_family__c = family.Id;
        transfer.Name = getName(sk4_Const.TRANSFER_TYPE_POCKETMONEY);
        transfer.sk4_description__c = 'Pocketmoney transfer ' + DateTime.now();
        return transfer;
    }

    public static sk4_transfer__c createCumulationTransfer(sk4_child__c child) {
        sk4_transfer__c transfer = new sk4_transfer__c();
        transfer.sk4_type__c = sk4_Const.TRANSFER_RECORDTYPE_CUMULATION;
        transfer.RecordTypeId = getRecordTypeId(transfer.sk4_type__c);
        transfer.sk4_child__c = child.Id;
        transfer.sk4_family__c = child.sk4_family__c;
        transfer.sk4_transferAmount__c = getCumulationAmount(child);
        transfer.Name = getName(sk4_Const.TRANSFER_TYPE_CUMULATION);
        return transfer;
    }

    public static void addWithdraw(Id childId, Decimal amount, String type, String description) {
        Id parentId = (Id) SOQL_Parent.query().byCurrentUser().toValueOf(sk4_parent__c.Id);
        sk4_parent__c parent = (sk4_parent__c) SOQL_Parent.query().byId(parentId).toObject();
        if (parentId == null) {
            parentId = getDefaultParentId(childId);
        }

        if (parentId == null) {
            throw new TransferException('Default Parent is not set!');
        }

        Id familyId = (Id) SOQL_Child.query().byId(childId).toValueOf(sk4_child__c.sk4_family__c);

        sk4_Transfer__c transfer = new sk4_transfer__c();
        transfer.sk4_child__c = childId;
        transfer.sk4_description__c = description;
        transfer.sk4_family__c = familyId;
        transfer.sk4_parent__c = parentId;
        transfer.sk4_transferAmount__c = sk4_Const.MINUS_TRANSFERS.contains(type) ? amount * -1 : amount ;
        transfer.sk4_type__c = type;
        transfer.RecordTypeId = getRecordTypeId(type);
        transfer.Name = getName(type);
        insert transfer;

    }
}
