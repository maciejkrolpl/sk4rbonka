@IsTest
public with sharing class SOQL_TransferTest {
    private static final String USERNAME = 'TestUser';
    private static final String FAMILY = 'Doe';
    private static final String PARENT = 'Jane';
    private static final String CHILD1 = 'Aaa';
    private static final String CHILD2 = 'Zzz';

    @TestSetup
    static void makeData() {
        User user = sk4_TestDataFactory.createSk4rbonkaUser(USERNAME);
        System.runAs(user) {
            sk4_family__c family = sk4_TestDataFactory.createFamilies(FAMILY, 1)[0];
            family.sk4_cumulationDay__c = Date.today().day();
            family.sk4_cumulationPercent__c = 50;
            insert family;

            sk4_parent__c parent = sk4_TestDataFactory.createParent(PARENT, family.Id);
            insert parent;

            sk4_child__c child1 = sk4_TestDataFactory.createChildren(CHILD1, 1, family.Id)[0];
            sk4_child__c child2 = sk4_TestDataFactory.createChildren(CHILD2, 1, family.Id)[0];
            insert new List<sk4_child__c>{ child1, child2 };

            List<sk4_transfer__c> transfers = new List<sk4_transfer__c>{
                sk4_TestDataFactory.createStandardTransfer(
                    sk4_Const.TRANSFER_TYPE_POCKETMONEY,
                    15,
                    child1.Id,
                    parent.Id
                ),
                // sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_DEDUCTION, -5, child1.Id, parent.Id),
                sk4_TestDataFactory.createStandardTransfer(
                    sk4_Const.TRANSFER_TYPE_POCKETMONEY,
                    0,
                    child2.Id,
                    parent.Id
                ),
                sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_WITHDRAW, -10, child2.Id, parent.Id)
            };
            for (sk4_transfer__c t : transfers) {
                t.sk4_family__c = family.Id;
            }
            insert transfers;

            sk4_cumulation__c cumulation = sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
            insert cumulation;
        }
    }

    @IsTest
    static void testQuery() {
        Test.startTest();
        List<sk4_transfer__c> transfer = (List<sk4_transfer__c>) SOQL_Transfer.query().toList();
        Test.stopTest();

        Assert.areEqual(5, transfer.size());
    }

    @IsTest
    static void testByChildId() {
        String searchKey = '%' + CHILD1 + '%';
        Id childId = [SELECT Id FROM sk4_child__c WHERE Name LIKE :searchKey].Id;

        Test.startTest();
        List<sk4_transfer__c> transfer = (List<sk4_transfer__c>) SOQL_Transfer.query().byChildId(childId).toList();
        Test.stopTest();

        Assert.areEqual(2, transfer.size());
    }

    @IsTest
    static void testByFakeChildId() {
        Id childId = 'a007Y00000O3ODfAKE';

        Test.startTest();
        List<sk4_transfer__c> transfer = (List<sk4_transfer__c>) SOQL_Transfer.query().byChildId(childId).toList();
        Test.stopTest();

        Assert.isTrue(transfer.isEmpty());
    }

    @IsTest
    static void testByTypes() {
        List<String> types = new List<String>{ sk4_Const.TRANSFER_TYPE_WITHDRAW };

        Test.startTest();
        List<sk4_transfer__c> transfers = (List<sk4_transfer__c>) SOQL_Transfer.query().byTypes(types).toList();
        Test.stopTest();

        Assert.areEqual(1, transfers.size());
    }

    @IsTest
    static void testFromNewest() {
        Test.startTest();
        List<sk4_transfer__c> transfers = (List<sk4_transfer__c>) SOQL_Transfer.query().fromNewest().toList();
        Test.stopTest();

        Assert.isFalse(transfers.isEmpty());
    }
}
