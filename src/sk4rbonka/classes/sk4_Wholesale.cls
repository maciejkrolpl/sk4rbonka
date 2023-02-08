public with sharing class sk4_Wholesale {
    @AuraEnabled
    public static List<sk4_child__c> getAllChildren() {
        List<sk4_child__c> children = [
            SELECT Id, sk4_fullName__c, sk4_balance__c, sk4_family__r.sk4_defaultPocketMoneyAmount__c
            FROM sk4_child__c
        ];

        return children;
    }

    @AuraEnabled
    public static void saveNewTransfers(List<ChildWrapper> children) {
        sk4_parent__c parent = [SELECT Id
                                FROM sk4_parent__c
                                WHERE sk4_user__c = :UserInfo.getUserId()];

        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>();

        for (ChildWrapper child : children) {
            if (child.give != NULL && child.give > 0) {
                sk4_CreateTransferRecords.Parameters p = new sk4_CreateTransferRecords.Parameters();
                p.type = sk4_Const.TRANSFER_TYPE_POCKETMONEY;
                p.parentId = parent.Id;
                p.childId = child.Id;
                p.transferAmount = child.give;
                transfers.add(sk4_CreateTransferRecords.createTransfer(p));
            }
            if (child.save != NULL && child.save > 0) {
                sk4_CreateTransferRecords.Parameters p = new sk4_CreateTransferRecords.Parameters();
                p.type = sk4_Const.TRANSFER_TYPE_SAVINGS;
                p.parentId = parent.Id;
                p.childId = child.Id;
                p.transferAmount = child.save;
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
        public Decimal save { get; set; }

    }

}