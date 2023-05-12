@IsTest
public with sharing class sk4_CumulateTriggerHandlerTest {
    
    private static final String USER_NAME = 'TestUser';
    private static final String FAMILY_NAME = 'TestFamily';
    private static final Decimal CUMULATION_PERCENT = 50;
    private static final String SAVINGS_TRANSFER_TYPE = 'Savings';
    private static Id CUMULATION_TRANSFER_RT_ID = Schema.SObjectType.sk4_transfer__c.getRecordTypeInfosByName()
        .get('Cumulation').getRecordTypeId();
    
    
    @TestSetup
    static void makeData() {

        User user = sk4_TestDataFactory.createSk4rbonkaAdminUser(USER_NAME);

        List<sk4_family__c> families = sk4_TestDataFactory.createFamilies(FAMILY_NAME, 2);
        families[0].sk4_cumulationPercent__c = CUMULATION_PERCENT;
        insert families;

        sk4_parent__c parent = sk4_TestDataFactory.createParent('Oneone', families[0].Id);
        insert parent;

        List<sk4_child__c> children = sk4_TestDataFactory.createChildren('One', 2, families[0].Id);
        insert children;

    }

    @IsTest
    static void testCreateCumulationTransfersWithTresholds() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        sk4_family__c family = [SELECT Id FROM sk4_family__c WHERE sk4_cumulationPercent__c != NULL];
        family.sk4_cumulationLowerTreshold__c = 10;
        family.sk4_cumulationUpperTreshold__c = 20;
        update family;

        sk4_parent__c parent = [SELECT Id FROM sk4_parent__c WHERE sk4_family__c = :family.Id];
        List<sk4_child__c> children = [SELECT Id FROM sk4_child__c];

        sk4_transfer__c t1 = sk4_TestDataFactory.createStandardTransfer(
            SAVINGS_TRANSFER_TYPE, 
            20, 
            children[0].Id,
            parent.Id
        );

        sk4_transfer__c t2 = sk4_TestDataFactory.createStandardTransfer(
            SAVINGS_TRANSFER_TYPE, 
            40, 
            children[0].Id,
            parent.Id
        );

        sk4_transfer__c t3 = sk4_TestDataFactory.createStandardTransfer(
            SAVINGS_TRANSFER_TYPE, 
            15, 
            children[1].Id,
            parent.Id
        );

        insert new List<sk4_transfer__c>{t1,t2,t3};

        System.runAs(user) {
            Test.startTest();
            insert sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
            Test.stopTest();

            List<sk4_transfer__c> transfers0 = [
                SELECT Id, sk4_transferAmount__c
                FROM sk4_transfer__c
                WHERE RecordTypeId = :CUMULATION_TRANSFER_RT_ID
                AND sk4_child__c = :children[0].Id
            ];

            List<sk4_transfer__c> transfers1 = [
                SELECT Id, sk4_transferAmount__c
                FROM sk4_transfer__c
                WHERE RecordTypeId = :CUMULATION_TRANSFER_RT_ID
                AND sk4_child__c = :children[1].Id
            ];

            Assert.areEqual(1, transfers0.size());
            Assert.areEqual(20, transfers0[0].sk4_transferAmount__c);
            Assert.areEqual(1, transfers1.size());
            Assert.areEqual(10, transfers1[0].sk4_transferAmount__c);
        }
    }

    @IsTest
    static void testCumulationZeroWhenBalanceNegative() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        sk4_family__c family = [SELECT Id FROM sk4_family__c WHERE sk4_cumulationPercent__c != NULL];
        sk4_parent__c parent = [SELECT Id FROM sk4_parent__c WHERE sk4_family__c = :family.Id];
        sk4_child__c child = [SELECT Id FROM sk4_child__c LIMIT 1];

        sk4_transfer__c t1 = sk4_TestDataFactory.createStandardTransfer(
            sk4_Const.TRANSFER_TYPE_WITHDRAW, 
            20, 
            child.Id,
            parent.Id
        );

        insert t1;

        System.runAs(user) {
            Test.startTest();
            insert sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
            Test.stopTest();

            sk4_transfer__c transfer = [
                SELECT Id, sk4_transferAmount__c
                FROM sk4_transfer__c
                WHERE RecordTypeId = :CUMULATION_TRANSFER_RT_ID
                AND sk4_child__c = :child.Id
            ];

            Assert.areEqual(0, transfer.sk4_transferAmount__c);
        }
    }

    @IsTest
    static void testCreateCumulationTransfers() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        sk4_family__c family = [SELECT Id FROM sk4_family__c WHERE sk4_cumulationPercent__c != NULL];
        sk4_parent__c parent = [SELECT Id FROM sk4_parent__c WHERE sk4_family__c = :family.Id];
        List<sk4_child__c> children = [SELECT Id FROM sk4_child__c];

        sk4_transfer__c t1 = sk4_TestDataFactory.createStandardTransfer(
            SAVINGS_TRANSFER_TYPE, 
            20, 
            children[0].Id,
            parent.Id
        );

        sk4_transfer__c t2 = sk4_TestDataFactory.createStandardTransfer(
            SAVINGS_TRANSFER_TYPE, 
            40, 
            children[0].Id,
            parent.Id
        );

        sk4_transfer__c t3 = sk4_TestDataFactory.createStandardTransfer(
            SAVINGS_TRANSFER_TYPE, 
            15, 
            children[1].Id,
            parent.Id
        );

        insert new List<sk4_transfer__c>{t1,t2,t3};

        System.runAs(user) {
            Test.startTest();
            insert sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
            Test.stopTest();

            List<sk4_transfer__c> transfers0 = [
                SELECT Id, sk4_transferAmount__c
                FROM sk4_transfer__c
                WHERE RecordTypeId = :CUMULATION_TRANSFER_RT_ID
                AND sk4_child__c = :children[0].Id
            ];

            List<sk4_transfer__c> transfers1 = [
                SELECT Id, sk4_transferAmount__c
                FROM sk4_transfer__c
                WHERE RecordTypeId = :CUMULATION_TRANSFER_RT_ID
                AND sk4_child__c = :children[1].Id
            ];

            Assert.areEqual(1, transfers0.size());
            Assert.areEqual(30, transfers0[0].sk4_transferAmount__c);
            Assert.areEqual(1, transfers1.size());
            Assert.areEqual(7.5, transfers1[0].sk4_transferAmount__c);
        }
    }

    @IsTest
    static void testCantAddSecondCumulationInMonth() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        sk4_family__c family = [SELECT Id FROM sk4_family__c LIMIT 1];

        System.runAs(user) {
            insert sk4_TestDataFactory.createCumulation(Date.today(), family.Id);

            sk4_cumulation__c cumulation = sk4_TestDataFactory.createCumulation(Date.today(), family.Id);

            Test.startTest();
            try {
                insert cumulation;
                Assert.fail();
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains('You cannot perform two cumulations per month!'));
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testCanAddCumulationInAnotherMonth() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        sk4_family__c family = [SELECT Id FROM sk4_family__c LIMIT 1];

        System.runAs(user) {
            insert sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
            insert sk4_TestDataFactory.createCumulation(Date.today().addMonths(-2), family.Id);

            sk4_cumulation__c cumulation00 = sk4_TestDataFactory.createCumulation(Date.today().addMonths(-1), family.Id);

            Test.startTest();
            insert cumulation00;
            Test.stopTest();

            Assert.areEqual(3, [SELECT Count() FROM sk4_cumulation__c]);
        }
    }

    @IsTest
    static void testCanAddCumulationsInOneMonthForTwoFamilies() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        List<sk4_family__c> families = [SELECT Id FROM sk4_family__c LIMIT 2];

        System.runAs(user) {
            sk4_cumulation__c cumulation0 = sk4_TestDataFactory.createCumulation(Date.today(), families[0].Id);
            sk4_cumulation__c cumulation1 = sk4_TestDataFactory.createCumulation(Date.today(), families[1].Id);

            Test.startTest();
            insert new List<sk4_cumulation__c>{cumulation0, cumulation1};
            Test.stopTest();

            Assert.areEqual(2, [SELECT Count() FROM sk4_cumulation__c]);
        }
    }

    @IsTest
    static void testCannotEditCumulation() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        sk4_family__c family = [SELECT Id FROM sk4_family__c LIMIT 1];

        System.runAs(user) {
            sk4_cumulation__c c = sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
            insert c;

            c.sk4_cumulationDate__c = Date.today().addDays(-1);

            try {
                update c;
                Assert.fail();
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains('Editing is not allowed. Delete cumulation and create new one.'));
            }
        }
    }

    @IsTest
    static void testDeleteCumulationTransfersWhenCumulationDeleted() {
        User user = [SELECT Id FROM User WHERE LastName = :USER_NAME LIMIT 1];
        sk4_family__c family = [SELECT Id FROM sk4_family__c WHERE Id IN 
                                (SELECT sk4_family__c FROM sk4_child__c) LIMIT 1];
        Map<Id, sk4_child__c> children = new Map<Id, sk4_child__c>(
            [SELECT Id  FROM sk4_child__c WHERE sk4_family__c = :family.Id]
        );

        sk4_cumulation__c cumulation = sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
        insert cumulation;

        Test.startTest();
        delete cumulation;
        Test.stopTest();

        Integer transferCount = [SELECT Count() FROM sk4_transfer__c WHERE  sk4_child__c IN :children.keySet()];

        Assert.areEqual(0, transferCount);
    }

}