@IsTest
public with sharing class SOQL_CumulationTest {
    @TestSetup
    static void makeData() {
        sk4_family__c family = sk4_TestDataFactory.createFamilies('Doe', 1)[0];
        insert family;

        sk4_cumulation__c cumulation = sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
        insert cumulation;
    }

    @IsTest
    static void testQuery() {
        Test.startTest();
        sObject cumulation = SOQL_Cumulation.query().toObject();
        Test.stopTest();

        Assert.isNotNull(cumulation);
    }
}
