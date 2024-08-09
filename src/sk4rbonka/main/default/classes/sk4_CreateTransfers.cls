public with sharing class sk4_CreateTransfers {
    private static Id getDefaultParentId(Id childId) {
        Id parentId = [SELECT sk4_family__r.sk4_defaultParent__c
            FROM sk4_child__c
            WHERE Id = :childId].sk4_family__r.sk4_defaultParent__c;
        return parentId;
    }

    public static void addWithdraw(Id childId, Decimal amount, String type, String description) {
        System.debug('addWithdraw');
        Id parentId = (Id) SOQL_Parent.query().byCurrentUser().toValueOf(sk4_parent__c.Id);
        System.debug(parentId);
        sk4_parent__c parent = [SELECT Id, sk4_family__c from sk4_parent__c where id = :parentId];
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
        transfer.sk4_transferAmount__c = amount;
        transfer.sk4_type__c = type;


        System.debug(transfer);

        insert transfer;

    }
}
