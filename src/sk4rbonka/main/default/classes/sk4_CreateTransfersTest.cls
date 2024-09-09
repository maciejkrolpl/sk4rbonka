@IsTest
public with sharing class sk4_CreateTransfersTest {
    private static final String USER_NAME = 'TestUser';
    private static final String FAMILY_NAME = 'TestFamily';
    @TestSetup
    static void makeData() {
        User user = sk4_TestDataFactory.createSk4rbonkaAdminUser(USER_NAME);

        sk4_family__c family = sk4_TestDataFactory.createFamilies(FAMILY_NAME, 1)[0];
        family.sk4_cumulationPercent__c = 50;
        insert family;

        sk4_parent__c parent = sk4_TestDataFactory.createParent('Oneone', family.Id);
        insert parent;

        family.sk4_defaultParent__c = parent.Id;
        family.sk4_ScheduledPocketMoneyEnabled__c = true;
        family.sk4_CumulationEnabled__c = true;
        family.sk4_defaultPocketMoneyAmount__c = 10;
        family.sk4_cumulationDay__c = date.today().day();
        family.sk4_PocketMoneyDay__c = date.today().day();
        update family;

        List<sk4_child__c> children = sk4_TestDataFactory.createChildren('One', 2, family.Id);
        insert children;
    }

    @IsTest
    static void testCreatePocketMoneyTransfer() {
        sk4_family__c family = [SELECT Id, sk4_defaultPocketMoneyAmount__c, sk4_defaultParent__c FROM sk4_family__c];
        Id childId = [SELECT Id FROM sk4_child__c LIMIT 1].Id;

        Test.startTest();
        sk4_transfer__c transfer = sk4_CreateTransfers.createPocketMoneyTransfer(family, childId);
        Test.stopTest();

        Assert.areEqual(10, transfer.sk4_transferAmount__c);
        Assert.areEqual('PocketMoney', transfer.sk4_type__c);
    }

    @IsTest
    static void testCreateCumulationTransfer() {
        sk4_child__c child = [SELECT Id, sk4_family__c, sk4_balance2__c FROM sk4_child__c LIMIT 1];
        Test.startTest();
        sk4_transfer__c transfer = sk4_CreateTransfers.createCumulationTransfer(child);
        Test.stopTest();

        Assert.areEqual(0, transfer.sk4_transferAmount__c);
        Assert.areEqual('Cumulation', transfer.sk4_type__c);
    }

    @IsTest
    static void addTransfer() {
        Id childId = [SELECT Id FROM sk4_child__c LIMIT 1].Id;

        sk4_CreateTransfers.addWithdraw(childId, 10, 'PocketMoney', 'description');

        Test.startTest();
        sk4_transfer__c transfer = [SELECT id, sk4_transferAmount__c, sk4_child__c FROM sk4_transfer__c];
        Test.stopTest();

        Assert.isNotNull(transfer);
        Assert.areEqual(10, transfer.sk4_transferAmount__c);
        Assert.areEqual(childId, transfer.sk4_child__c);

    }
}
