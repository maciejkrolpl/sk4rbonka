public with sharing class sk4_TransferController {
    private static final List<String> transfersToQuery = new List<String>{
        sk4_Const.TRANSFER_TYPE_POCKETMONEY,
        sk4_Const.TRANSFER_TYPE_WITHDRAW,
        sk4_Const.TRANSFER_TYPE_CUMULATION,
        sk4_Const.TRANSFER_TYPE_OTHER,
        sk4_Const.TRANSFER_TYPE_DEDUCTION
    };

    @AuraEnabled
    public static List<String> getMinusTypes() {
        return sk4_Const.MINUS_TRANSFERS;
    }

    @AuraEnabled
    public static List<Wrapper> getTransfersByChildren(Id childId) {
        List<Wrapper> result = new List<Wrapper>();

        List<sk4_transfer__c> transfers = [
            SELECT Id, sk4_date__c, sk4_description__c, sk4_type__c, sk4_transferAmount__c
            FROM sk4_transfer__c
            WHERE sk4_child__c = :childId AND sk4_type__c IN :transfersToQuery
            ORDER BY sk4_date__c ASC
        ];

        Integer l = transfers.size();
        List<Wrapper> wrappers = new List<Wrapper>();

        for (Integer i = 0; i < l; i++) {
            if (i == 0) {
                wrappers.add(new Wrapper(transfers[i], 0));
            } else {
                Decimal total = wrappers[i - 1].total;
                wrappers.add(new Wrapper(transfers[i], total));
            }
        }

        return wrappers;
    }

    public class Wrapper {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public Date dt;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Decimal total;
        public Wrapper(sk4_transfer__c transfer, Decimal total) {
            this.id = transfer.Id;
            this.dt = Date.valueOf(transfer.sk4_date__c);
            this.description = transfer.sk4_description__c;
            this.amount = transfer.sk4_transferAmount__c;
            this.type = transfer.sk4_type__c;

            if (sk4_Const.PLUS_TRANSFERS.contains(this.type)) {
                this.total = total + this.amount;
            } else if (sk4_Const.MINUS_TRANSFERS.contains(this.type)) {
                this.total = total - this.amount;
            }
        }
    }
}
