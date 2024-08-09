public with sharing class sk4_CreateTransfers {
    private static Id getDefaultParentId(Id childId) {
        sk4_child__c child = (sk4_child__c) SOQL_Child.query().byId(childId).preview().toObject();
        return child.sk4_family__r.sk4_defaultParent__c;

    }

    private static String getRecordTypeId(String type) {
        return sk4_Const.TYPE_TO_RT_ID.get(type);
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

        sk4_Transfer__c transfer = new sk4_transfer__c();
        transfer.sk4_child__c = childId;
        transfer.sk4_description__c = description;
        transfer.sk4_family__c = parent.sk4_family__c;
        transfer.sk4_parent__c = parentId;
        transfer.sk4_transferAmount__c = sk4_Const.MINUS_TRANSFERS.contains(type) ? amount * -1 : amount ;
        transfer.sk4_type__c = type;
        transfer.RecordTypeId = getRecordTypeId(type);

        insert transfer;

    }
}
