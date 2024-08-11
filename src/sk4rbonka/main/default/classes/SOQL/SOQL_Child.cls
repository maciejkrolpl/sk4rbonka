public with sharing class SOQL_Child extends SOQL implements SOQL.Selector {
    public static SOQL_Child query() {
        return new SOQL_Child();
    }

    private SOQL_Child() {
        super(sk4_child__c.SObjectType);
        with(new List<SObjectField>{ sk4_child__c.Id, sk4_child__c.Name, sk4_child__c.sk4_balance2__c, sk4_child__c.sk4_fullName__c });
        with('sk4_family__r', sk4_family__c.sk4_defaultParent__c);
        systemMode();
        withSharing();
    }

    public SOQL_Child byFamilyIds(Set<Id> familyIds) {
        whereAre(Filter.with(sk4_child__c.sk4_family__c).isIn(familyIds));
        return this;
    }

}
