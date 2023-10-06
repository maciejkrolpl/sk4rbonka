public with sharing class sk4_ScheduleBatch implements Database.Batchable<sObject> {
    private Boolean isTransferDay(Decimal todaysDay) {
        Date today = Date.today();
        Integer numberOfDays = Date.daysInMonth(today.year(), today.month());
        if (numberOfDays < todaysDay) {
            return today.day() == numberOfDays;
        }
        return todaysDay == today.day();
    }

    private sk4_cumulation__c createCumulation(sk4_family__c family){
        sk4_cumulation__c cumul = new sk4_cumulation__c();
        cumul.sk4_family__c = family.Id;
        cumul.sk4_cumulationDate__c = date.today();
        return cumul;
    }

    private List<sk4_transfer__c> createPocketMoneyTransfers(sk4_family__c family) {
        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>();
        for (sk4_child__c child : family.Children__r) {
            transfers.add(sk4_CreateTransferRecords.createPocketMoneyTransfer(family, child.Id));
        }
        return transfers;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        query += 'SELECT Id,  sk4_cumulationDay__c, sk4_PocketMoneyDay__c, sk4_defaultPocketMoneyAmount__c,';
        query += 'sk4_defaultParent__c, sk4_ScheduledPocketMoneyEnabled__c , sk4_CumulationEnabled__c, ';
        query += '(SELECT Id FROM Children__r) ';
        query += 'FROM sk4_family__c ';
        query += 'WHERE (sk4_ScheduledPocketMoneyEnabled__c = TRUE OR sk4_CumulationEnabled__c = TRUE)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sk4_family__c> scope) {
        List<sk4_cumulation__c> cumuls = new List<sk4_cumulation__c>();
        List<sk4_transfer__c> pocketMoneys = new List<sk4_transfer__c>();
        for (sk4_family__c family : scope) {
            if (family.sk4_ScheduledPocketMoneyEnabled__c && isTransferDay(family.sk4_PocketMoneyDay__c)) {
                pocketMoneys.addAll(createPocketMoneyTransfers(family));
            }
            if (family.sk4_CumulationEnabled__c && isTransferDay(family.sk4_cumulationDay__c)) {
                cumuls.add(createCumulation(family));
            }
        }

        insert cumuls;
        insert pocketMoneys;
    }

    public void finish(Database.BatchableContext BC) {
    }

}