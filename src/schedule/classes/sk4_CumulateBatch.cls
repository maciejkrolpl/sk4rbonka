public with sharing class sk4_CumulateBatch implements Database.Batchable<sObject> {
    
    private Boolean hasCumulationToday(Decimal cumulationDay) {
        Date today = Date.today();
        Integer numberOfDays = Date.daysInMonth(today.year(), today.month());
        if (numberOfDays < cumulationDay) {
            return today.day() == numberOfDays;
        }
        return cumulationDay == today.day();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query ='SELECT Id, sk4_cumulationDay__c FROM sk4_family__c WHERE ';
        query += '(sk4_cumulationPercent__c != NULL AND sk4_cumulationDay__c != NULL)';
        return Database.getQueryLocator(query);
     }
  
     public void execute(Database.BatchableContext BC, List<sk4_family__c> scope){
        List<sk4_cumulation__c> cumuls = new List<sk4_cumulation__c>();
        for (sk4_family__c family: scope) {
            if (hasCumulationToday(family.sk4_cumulationDay__c)) {
                sk4_cumulation__c cumul = new sk4_cumulation__c();
                cumul.sk4_family__c = family.Id;
                cumul.sk4_cumulationDate__c = date.today();
                cumuls.add(cumul);

            }
        }

        insert cumuls;       

     }
  
     public void finish(Database.BatchableContext BC){
     }
}