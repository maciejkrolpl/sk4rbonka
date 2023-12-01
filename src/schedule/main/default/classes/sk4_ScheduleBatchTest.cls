@IsTest
public with sharing class sk4_ScheduleBatchTest {
    private static final Integer DEFAULT_PERCENT = 50;
    private static final Integer DEFAULT_POCKETMONEY = 50;
    private static final String USER_NAME = 'TestUser';
    private static final String FAMILY_NAME = 'TestFAMILY';
    @TestSetup
    static void makeData() {
        User u = sk4_TestDataFactory.createSk4rbonkaAdminUser(USER_NAME);

        sk4_family__c family = sk4_TestDataFactory.createFamilies(FAMILY_NAME, 1)[0];
        family.sk4_cumulationDay__c = Date.today().day();
        family.sk4_cumulationPercent__c = 50;
        family.sk4_cumulationEnabled__c = true;
        insert family;

        sk4_parent__c parent = sk4_TestDataFactory.createParent('Jane', family.Id);
        insert parent;

        family.sk4_defaultParent__c = parent.Id;
        family.sk4_ScheduledPocketMoneyEnabled__c = true;
        family.sk4_defaultPocketMoneyAmount__c = DEFAULT_POCKETMONEY;
        family.sk4_pocketMoneyDay__c = Date.today().day();

        update family;

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
    static void testInTheDay() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];
        System.runAs(testUser) {
            Test.startTest();
            Database.executeBatch(new sk4_ScheduleBatch());
            Test.stopTest();
        }
        Integer cumulationNumber = [
            SELECT COUNT()
            FROM sk4_cumulation__c
        ];
        Integer pocketMoneyNumber = [
            SELECT COUNT()
            FROM sk4_transfer__c
            WHERE sk4_type__c = 'PocketMoney'
        ];

        Assert.areEqual(1, cumulationNumber);
        Assert.areEqual(3, pocketMoneyNumber);
    }

    @IsTest
    static void testNotInTheDay() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];
        sk4_family__c family = [
            SELECT Id, sk4_cumulationDay__C
            FROM sk4_family__c
        ];
        family.sk4_cumulationDay__c = Date.today().addDays(1).day();
        family.sk4_pocketMoneyDay__c = Date.today().addDays(1).day();
        update family;

        System.runAs(testUser) {
            Test.startTest();
            Database.executeBatch(new sk4_ScheduleBatch());
            Test.stopTest();
        }
        Integer cumulationNumber = [
            SELECT COUNT()
            FROM sk4_cumulation__c
        ];
        Integer pocketMoneyNumber = [
            SELECT COUNT()
            FROM sk4_transfer__c
            WHERE sk4_type__c = 'PocketMoney'
        ];

        Assert.areEqual(0, cumulationNumber);
        Assert.areEqual(0, pocketMoneyNumber);
    }

    @IsTest
    static void testInTheDayWhenDisabled() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];
        sk4_family__c family = [
            SELECT Id, sk4_cumulationDay__C
            FROM sk4_family__c
        ];
        family.sk4_ScheduledPocketMoneyEnabled__c = false;
        family.sk4_CumulationEnabled__c = false;
        update family;

        System.runAs(testUser) {
            Test.startTest();
            Database.executeBatch(new sk4_ScheduleBatch());
            Test.stopTest();
        }
        Integer cumulationNumber = [
            SELECT COUNT()
            FROM sk4_cumulation__c
        ];
        Integer pocketMoneyNumber = [
            SELECT COUNT()
            FROM sk4_transfer__c
            WHERE sk4_type__c = 'PocketMoney'
        ];

        Assert.areEqual(0, cumulationNumber);
        Assert.areEqual(0, pocketMoneyNumber);
    }
}
