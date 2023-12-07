public inherited sharing class SOQL_Transfer extends SOQL implements SOQL.Selector {
    public static SOQL_Transfer query() {
        return new SOQL_Transfer();
    }

    private SOQL_Transfer() {
        super(sk4_transfer__c.SObjectType);
        with(new List<SObjectField>{ sk4_transfer__c.Id }).systemMode().withoutSharing();
    }

    public SOQL_Transfer byChildId(Id childId) {
        whereAre(Filter.with(sk4_transfer__c.sk4_child__c).equal(childId));
        return this;
    }

    public SOQL_Transfer byTypes(List<String> types) {
        whereAre(Filter.with(sk4_transfer__c.sk4_type__c).isIn(types));
        return this;
    }

    public SOQL_Transfer fromNewest() {
        orderBy(sk4_transfer__c.sk4_date__c);
        return this;
    }
}
