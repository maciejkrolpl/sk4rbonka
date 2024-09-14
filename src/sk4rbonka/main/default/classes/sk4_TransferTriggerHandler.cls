public with sharing class sk4_TransferTriggerHandler {
    public static void beforeInsert(List<sk4_transfer__c> transfers) {
        setNames(transfers);
    }

    private static void setNames(List<sk4_transfer__c> transfers) {
        for (sk4_transfer__c transfer : transfers) {
            transfer.Name = transfer.sk4_type__c + '-' + String.valueOf(Date.today());
        }
    }

}
