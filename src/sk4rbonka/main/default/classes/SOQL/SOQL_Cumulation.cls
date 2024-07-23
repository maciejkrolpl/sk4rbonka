public with sharing class SOQL_Cumulation extends SOQL implements SOQL.Selector {
    public static SOQL_Cumulation query() {
        return new SOQL_Cumulation();
    }

    private SOQL_Cumulation() {
        super(sk4_cumulation__c.SObjectType);
        with(
                new List<SObjectField>{
                    sk4_cumulation__c.Id,
                    sk4_cumulation__c.sk4_family__c,
                    sk4_cumulation__c.sk4_cumulationMonth__c,
                    sk4_cumulation__c.sk4_cumulationYear__c
                }
            )
            .systemMode()
            .withSharing();
    }
}
