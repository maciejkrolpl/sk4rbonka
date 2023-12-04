public with sharing class sk4_Wholesale {
    @AuraEnabled
    public static List<ChildWrapper> getAllChildren() {
        List<ChildWrapper> wrappers = new List<ChildWrapper>();
        for (sk4_child__c child : [
            SELECT Id, sk4_fullName__c, sk4_balance__c, sk4_family__r.sk4_defaultPocketMoneyAmount__c
            FROM sk4_child__c
        ]) {
            ChildWrapper cw = new ChildWrapper();
            cw.fullName = child.sk4_fullName__c;
            cw.balance = child.sk4_balance__c;
            cw.defaultAmount = child.sk4_family__r.sk4_defaultPocketMoneyAmount__c;
            cw.id = child.Id;
            wrappers.add(cw);
        }

        return wrappers;
    }

    @AuraEnabled
    public static void saveNewTransfers(List<ChildWrapper> children) {
        sk4_parent__c parent = [
            SELECT Id, sk4_family__c
            FROM sk4_parent__c
            WHERE sk4_user__c = :UserInfo.getUserId()
        ];

        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>();

        for (ChildWrapper child : children) {
            if (child.give != null && child.give > 0) {
                sk4_CreateTransferRecords.Parameters p = new sk4_CreateTransferRecords.Parameters();
                p.type = sk4_Const.TRANSFER_TYPE_POCKETMONEY;
                p.parentId = parent.Id;
                p.familyId = parent.sk4_family__c;
                p.childId = child.Id;
                p.transferAmount = child.give;
                transfers.add(sk4_CreateTransferRecords.createTransfer(p));
            }
        }

        sk4_CreateTransferRecords.insertRecords(transfers);
    }

    public class ChildWrapper {
        @AuraEnabled
        public Id id { get; set; }
        @AuraEnabled
        public Decimal give { get; set; }
        @AuraEnabled
        public String fullName { get; set; }
        @AuraEnabled
        public Decimal balance { get; set; }
        @AuraEnabled
        public Decimal defaultAmount { get; set; }
    }
}
