@IsTest
public with sharing class sk4_CumulateBatchTest {
    private static final Integer DEFAULT_PERCENT = 50;
    private static final String USER_NAME = 'TestUser';
    private static final String FAMILY_NAME = 'TestFAMILY';
    @TestSetup
    static void makeData() {
        User u = sk4_TestDataFactory.createSk4rbonkaAdminUser(USER_NAME);

        sk4_family__c family = sk4_TestDataFactory.createFamilies(FAMILY_NAME, 1)[0];
        family.sk4_cumulationDay__c = Date.today().day();
        family.sk4_cumulationPercent__c = 50;
        insert family;

        sk4_parent__c parent = sk4_TestDataFactory.createParent('Jane', family.Id);
        insert parent;

        List<sk4_child__c> children = new List<sk4_child__c>();
        for (Integer i = 0; i < 3; i++) {
            sk4_child__c child = new sk4_child__c();
            child.Name = 'John' + i;
            child.sk4_family__c = family.Id;
            children.add(child);
        }
        insert children;
    }

   

    @IsTest
    static void testInCumulationDay() {

        User testUser = [SELECT Id
                         FROM User
                         WHERE LastName = :USER_NAME];
        System.runAs(testUser) {
            Test.startTest();
            Database.executeBatch(new sk4_CumulateBatch());
            Test.stopTest();
        }
        Integer cumulationNumber = [SELECT Count()
                                    FROM sk4_cumulation__c];

        Assert.areEqual(1, cumulationNumber);
    }

    @IsTest
    static void testInCumulationDayWhenNoPercentSpecified() {

        User testUser = [SELECT Id
                         FROM User
                         WHERE LastName = :USER_NAME];

        sk4_family__c family = [SELECT Id FROM sk4_family__c];
        family.sk4_cumulationPercent__c = NULL;
        update family;

        System.runAs(testUser) {
            Test.startTest();
            Database.executeBatch(new sk4_CumulateBatch());
            Test.stopTest();
        }
        Integer cumulationNumber = [SELECT Count()
                                    FROM sk4_cumulation__c];

        Assert.areEqual(cumulationNumber, 0);
    }

    @IsTest
    static void testInNonCumulationDay() {
        User testUser = [SELECT Id
                         FROM User
                         WHERE LastName = :USER_NAME];
        System.runAs(testUser) {
            sk4_family__c family = [SELECT Id, sk4_cumulationDay__C
                                    from sk4_family__c];
            if (family.sk4_cumulationDay__c == 1) {
                family.sk4_cumulationDay__c = 2;
            } else {
                family.sk4_cumulationDay__c = family.sk4_cumulationDay__c - 1;
            }
            update family;
            Test.startTest();
            Database.executeBatch(new sk4_CumulateBatch());
            Test.stopTest();
        }
        Integer cumulationNumber = [SELECT Count()
                                    FROM sk4_cumulation__c];

        Assert.areEqual(cumulationNumber, 0);
    }

}