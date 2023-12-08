public with sharing class SOQL_Parent extends SOQL implements SOQL.Selector {
    public static SOQL_Parent query() {
        return new SOQL_Parent();
    }

    private SOQL_Parent() {
        super(sk4_parent__c.SObjectType);
        with(new List<SObjectField>{ sk4_parent__c.Id, sk4_parent__c.sk4_family__c }).systemMode().withoutSharing();
    }

    public SOQL_Parent byCurrentUser() {
        whereAre(Filter.with(sk4_parent__c.sk4_user__c).equal(UserInfo.getUserId()));
        return this;
    }
}
