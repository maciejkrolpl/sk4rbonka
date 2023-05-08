public with sharing class sk4_TransferController {

    private static final List<String> transfersToQuery = new List<String>{
        'Savings',
        'Withdraw',
        'Cumulation',
        'Other',
        'Deduction'
    };

    @AuraEnabled
    public static List<sk4_transfer__c> getTransfersByChildren(Id childrenId) {
        List<sk4_transfer__c> transfers = [SELECT Id, sk4_date__c, sk4_description__c, sk4_type__c, sk4_transferAmount__c
                                           FROM sk4_transfer__c
                                           WHERE sk4_child__c = :childrenId
                                           AND sk4_type__c IN :transfersToQuery
                                           ORDER BY sk4_date__c ASC];

        return transfers;
    }

}