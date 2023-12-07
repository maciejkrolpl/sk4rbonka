@IsTest
public with sharing class SOQL_ChildTest {
    @TestSetup
    static void makeData() {
        List<sk4_family__c> families = sk4_TestDataFactory.createFamilies('Nowak', 3);
        insert families;

        List<sk4_child__c> children = sk4_TestDataFactory.createChildren('Jan', 2, families[0].Id);
        children.addAll(sk4_TestDataFactory.createChildren('Maria', 2, families[1].Id));
        insert children;
    }

    @IsTest
    static void testQuery() {
        Test.startTest();
        List<SObject> children = SOQL_Child.query().toList();
        Test.stopTest();

        Assert.areEqual(4, children.size());
    }

    @IsTest
    static void testByFamilyIds() {
        Set<Id> familyIds = new Map<Id, sk4_family__c>([SELECT Id FROM sk4_family__c WHERE Name = 'Nowak1']).keyset();

        Test.startTest();
        List<sObject> children = SOQL_Child.query().byFamilyIds(familyIds).toList();
        Test.stopTest();

        Assert.areEqual(2, children.size());
    }
}
