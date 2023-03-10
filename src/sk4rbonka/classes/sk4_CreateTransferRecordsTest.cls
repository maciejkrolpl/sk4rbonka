@IsTest
public with sharing class sk4_CreateTransferRecordsTest {
    private final static String USER_NAME = 'TestUser';
    private final static String FAMILY_NAME = 'TestFamily';
    private final static String CHILDREN0_NAME = 'Null';
    private final static String CHILDREN1_NAME = 'One';
    @TestSetup
    static void makeData() {
        User u = sk4_TestDataFactory.createSk4rbonkaAdminUser(USER_NAME);

        List<sk4_family__c> families = sk4_TestDataFactory.createFamilies(FAMILY_NAME, 2);
        insert families;

        List<sk4_child__c> children0 = sk4_TestDataFactory.createChildren(CHILDREN0_NAME, 2, families[0].Id);
        List<sk4_child__c> children1 = sk4_TestDataFactory.createChildren(CHILDREN1_NAME, 2, families[1].Id);
        insert children0;
        insert children1;

        sk4_parent__c parent0 = sk4_TestDataFactory.createParent(CHILDREN0_NAME, families[0].Id);
        sk4_parent__c parent1 = sk4_TestDataFactory.createParent(CHILDREN1_NAME, families[1].Id);
        insert new List<sk4_parent__c>{ parent0, parent1 };

        sk4_transfer__c savingsTransfer = sk4_TestDataFactory.createStandardTransfer('Savings', 20, children1[1].Id, parent1.Id);
    }

    @IsTest
    static void testCreateOtherTransferFromFlow() {
        sk4_family__c family = [SELECT Id, Name, (SELECT Id, Name
                                                  FROM children__r), (SELECT Id, Name
                                                                      FROM parents__r)
                                FROM sk4_family__c
                                LIMIT 1];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = family.Children__r[0];
        i1.parent = family.Parents__r[0];
        i1.otherAmount = 10;
        i1.description = 'TestDescription';

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [SELECT Id
                  FROM User
                  WHERE LastName = :USER_NAME];

        System.runAs(u) {
            Test.startTest();
            sk4_CreateTransferRecords.createRecords(inputs);
            Test.stopTest();

            List<sk4_transfer__c> transfers = [SELECT Id
                                               FROM sk4_transfer__c
                                               WHERE sk4_child__c = :family.Children__r[0].Id AND sk4_type__c = :sk4_Const.TRANSFER_TYPE_OTHER];

            Assert.areEqual(1, transfers.size());
        }
    }

    @IsTest
    static void testCannotCreateOtherTransferWithoutDescription() {
        sk4_family__c family = [SELECT Id, Name, (SELECT Id, Name
                                                  FROM children__r), (SELECT Id, Name
                                                                      FROM parents__r)
                                FROM sk4_family__c
                                LIMIT 1];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = family.Children__r[0];
        i1.parent = family.Parents__r[0];
        i1.otherAmount = 10;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [SELECT Id
                  FROM User
                  WHERE LastName = :USER_NAME];

        System.runAs(u) {
            Test.startTest();
            try {
                sk4_CreateTransferRecords.createRecords(inputs);
                Assert.fail();
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains('Description must be set in Other Transfer.'));
            }

            Test.stopTest();

        }
    }

    @IsTest
    static void cantCreateTransferWithParentAndChildFromNotSameFamily() {
        List<sk4_family__c> families = [SELECT Id, Name, (SELECT Id, Name
                                                          FROM children__r), (SELECT Id, Name
                                                                              FROM parents__r)
                                        FROM sk4_family__c
                                        ORDER BY Name];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = families[0].Children__r[0];
        i1.parent = families[1].Parents__r[0];
        i1.pocketMoneyAmount = 10;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [SELECT Id
                  FROM User
                  WHERE LastName = :USER_NAME];

        System.runAs(u) {
            Test.startTest();

            try {
                sk4_CreateTransferRecords.createRecords(inputs);
                Assert.fail();
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains('Child and parent must be from the same family!'));
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testCantSaveMoreThanGiven() {
        sk4_family__c family = [SELECT Id, Name, (SELECT Id, Name
                                                  FROM children__r), (SELECT Id, Name
                                                                      FROM parents__r)
                                FROM sk4_family__c
                                LIMIT 1];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = family.Children__r[0];
        i1.parent = family.Parents__r[0];
        i1.pocketMoneyAmount = 10;
        i1.savingsAmount = 20;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [SELECT Id
                  FROM User
                  WHERE LastName = :USER_NAME];

        System.runAs(u) {
            Test.startTest();

            try {
                sk4_CreateTransferRecords.createRecords(inputs);
                Assert.fail();
            } catch (Exception ex) {
                Assert.isTrue(ex.getMessage().contains('You cannot save more money that is given.'));
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testCanWithdrawMoreMoneyThanOnAccount() {
        sk4_family__c family = [SELECT Id, Name, (SELECT Id, Name
                                                  FROM children__r), (SELECT Id, Name
                                                                      FROM parents__r)
                                FROM sk4_family__c
                                LIMIT 1];

        sk4_transfer__c savings = sk4_TestDataFactory.createStandardTransfer('Savings', 10, family.Children__r[0].Id, family.Parents__r[0].Id);
        insert savings;

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = family.Children__r[0];
        i1.parent = family.Parents__r[0];
        i1.withdrawAmount = 15;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [SELECT Id
                  FROM User
                  WHERE LastName = :USER_NAME];

        System.runAs(u) {
            Test.startTest();
            sk4_CreateTransferRecords.createRecords(inputs);
            Test.stopTest();
        }

        sk4_child__c fetchedChild = [SELECT Id, sk4_balance__c
                                     from sk4_child__c
                                     WHERE Id = :family.Children__r[0].Id];

        Assert.areEqual(-5, fetchedChild.sk4_balance__c);
    }

    @IsTest
    static void createDeductionTransferFromFlow() {
        List<sk4_family__c> families = [SELECT Id, Name, (SELECT Id, Name
                                                          FROM children__r), (SELECT Id, Name
                                                                              FROM parents__r)
                                        FROM sk4_family__c
                                        ORDER BY Name];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = families[0].Children__r[0];
        i1.parent = families[0].Parents__r[0];
        i1.deductionAmount = 10;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [SELECT Id
                  FROM User
                  WHERE LastName = :USER_NAME];

        System.runAs(u) {
            sk4_CreateTransferRecords.createRecords(inputs);
        }

        List<sk4_transfer__c> savingsTransfers = [SELECT Id, sk4_type__c, sk4_transferAmount__c
                                                  FROM sk4_transfer__c
                                                  WHERE sk4_type__c = 'Deduction'];

        Assert.areEqual(1, savingsTransfers.size());
        Assert.areEqual(10, savingsTransfers[0].sk4_transferAmount__c);
    }

    @IsTest
    static void testCreateSavingsAndPocketMoneyTransfersFromFlow() {
        List<sk4_family__c> families = [SELECT Id, Name, (SELECT Id, Name
                                                          FROM children__r), (SELECT Id, Name
                                                                              FROM parents__r)
                                        FROM sk4_family__c
                                        ORDER BY Name];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = families[0].Children__r[0];
        i1.parent = families[0].Parents__r[0];
        i1.pocketMoneyAmount = 10;

        sk4_CreateTransferRecords.FlowInput i2 = new sk4_CreateTransferRecords.FlowInput();
        i2.child = families[0].Children__r[1];
        i2.parent = families[0].Parents__r[0];
        i2.pocketMoneyAmount = 20;
        i2.savingsAmount = 20;

        sk4_CreateTransferRecords.FlowInput i3 = new sk4_CreateTransferRecords.FlowInput();
        i3.child = families[1].Children__r[0];
        i3.parent = families[1].Parents__r[0];
        i3.pocketMoneyAmount = 30;
        i3.savingsAmount = 10;

        sk4_CreateTransferRecords.FlowInput i4 = new sk4_CreateTransferRecords.FlowInput();
        i4.child = families[1].Children__r[1];
        i4.parent = families[1].Parents__r[0];
        i4.withdrawAmount = 10;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1, i2, i3, i4 };

        sk4_transfer__c pocketMoneyTransfer = sk4_TestDataFactory.createStandardTransfer('Savings', 10, families[1].Children__r[1].Id, families[1].Parents__r[0].Id);
        insert pocketMoneyTransfer;

        User u = [SELECT Id
                  FROM User
                  WHERE LastName = :USER_NAME];

        System.runAs(u) {

            Test.startTest();
            sk4_CreateTransferRecords.createRecords(inputs);
            Test.stopTest();

            Integer transferCount = [SELECT Count()
                                     FROM sk4_transfer__c];
            Integer savingsTransferCount = [SELECT Count()
                                            FROM sk4_transfer__c
                                            WHERE sk4_type__c = 'Savings'];
            Integer pocketMoneyTransferCount = [SELECT Count()
                                                FROM sk4_transfer__c
                                                WHERE sk4_type__c = 'PocketMoney'];
            Integer withdrawTransferCount = [SELECT Count()
                                             FROM sk4_transfer__c
                                             WHERE sk4_type__c = 'Withdraw'];

            Assert.areEqual(7, transferCount);
            Assert.areEqual(3, pocketMoneyTransferCount);
            Assert.areEqual(3, savingsTransferCount);
            Assert.areEqual(1, withdrawTransferCount);
        }
    }

}