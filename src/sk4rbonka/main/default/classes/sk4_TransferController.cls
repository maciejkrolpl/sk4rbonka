public with sharing class sk4_TransferController {
    @AuraEnabled
    public static List<Wrapper> getTransfersByChildren(Id childId) {
        List<Wrapper> result = new List<Wrapper>();

        List<sk4_transfer__c> transfers = (List<sk4_transfer__c>) SOQL_Transfer.query()
            .byChildId(childId)
            .byTypes(sk4_Const.transfersToQuery)
            .fromNewest()
            .with(
                new List<SObjectField>{
                    sk4_transfer__c.sk4_dateTime__c,
                    sk4_transfer__c.sk4_description__c,
                    sk4_transfer__c.sk4_type__c,
                    sk4_transfer__c.sk4_transferAmount__c
                }
            )
            .mockId('sk4_TransferController')
            .toList();

        List<Wrapper> wrappers = new List<Wrapper>();
        Integer l = transfers.size();

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
        public DateTime dt;
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
            this.dt = transfer.sk4_dateTime__c;
            this.description = transfer.sk4_description__c;
            this.amount = transfer.sk4_transferAmount__c;
            this.type = transfer.sk4_type__c;

            this.total = total + this.amount;
        }
    }
}
