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

        sk4_transfer__c savingsTransfer = sk4_TestDataFactory.createStandardTransfer(
            'PocketMoney',
            20,
            children1[1].Id,
            parent1.Id
        );
    }

    @IsTest
    static void testCreateOtherTransferFromFlow() {
        sk4_parent__c parent = [
            SELECT Id, Name, sk4_family__c
            FROM sk4_parent__c
            LIMIT 1
        ];

        sk4_child__c child = [
            SELECT Id, Name
            FROM sk4_child__c
            WHERE sk4_family__c = :parent.sk4_family__c
            LIMIT 1
        ];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = child;
        i1.parent = parent;
        i1.otherAmount = 10;
        i1.description = 'TestDescription';

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];

        System.runAs(u) {
            Test.startTest();
            sk4_CreateTransferRecords.createRecords(inputs);
            Test.stopTest();

            List<sk4_transfer__c> transfers = [
                SELECT Id
                FROM sk4_transfer__c
                WHERE sk4_child__c = :child.Id AND sk4_type__c = :sk4_Const.TRANSFER_TYPE_OTHER
            ];

            Assert.areEqual(1, transfers.size());
        }
    }

    @IsTest
    static void testCannotCreateOtherTransferWithoutDescription() {
        sk4_parent__c parent = [
            SELECT Id, Name, sk4_family__c
            FROM sk4_parent__c
            LIMIT 1
        ];

        sk4_child__c child = [
            SELECT Id, Name
            FROM sk4_child__c
            WHERE sk4_family__c = :parent.sk4_family__c
            LIMIT 1
        ];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = child;
        i1.parent = parent;
        i1.otherAmount = 10;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];

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
        sk4_parent__c parent = [
            SELECT Id, Name, sk4_family__c
            FROM sk4_parent__c
            LIMIT 1
        ];

        sk4_child__c child = [
            SELECT Id, Name
            FROM sk4_child__c
            WHERE sk4_family__c != :parent.sk4_family__c
            LIMIT 1
        ];

        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.child = child;
        i1.parent = parent;
        i1.pocketMoneyAmount = 10;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];

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
    static void testCanWithdrawMoreMoneyThanOnAccount() {
        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.parent = [
            SELECT Id, Name, sk4_family__c
            FROM sk4_parent__c
            LIMIT 1
        ];

        i1.child = [
            SELECT Id, Name
            FROM sk4_child__c
            WHERE sk4_family__c = :i1.parent.sk4_family__c
            LIMIT 1
        ];
        i1.withdrawAmount = 15;

        sk4_transfer__c pocketMoney = sk4_TestDataFactory.createStandardTransfer(
            'PocketMoney',
            10,
            i1.child.Id,
            i1.parent.Id
        );
        pocketMoney.sk4_family__c = i1.parent.sk4_family__c;
        insert pocketMoney;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];

        System.runAs(u) {
            Test.startTest();
            sk4_CreateTransferRecords.createRecords(inputs);
            Test.stopTest();
        }

        sk4_child__c fetchedChild = [
            SELECT Id, sk4_balance2__c
            FROM sk4_child__c
            WHERE Id = :i1.child.Id
        ];

        Assert.areEqual(-5, fetchedChild.sk4_balance2__c);
    }

    @IsTest
    static void createDeductionTransferFromFlow() {
        sk4_CreateTransferRecords.FlowInput i1 = new sk4_CreateTransferRecords.FlowInput();
        i1.parent = [
            SELECT Id, Name, sk4_family__c
            FROM sk4_parent__c
            LIMIT 1
        ];

        i1.child = [
            SELECT Id, Name
            FROM sk4_child__c
            WHERE sk4_family__c = :i1.parent.sk4_family__c
            LIMIT 1
        ];

        i1.deductionAmount = 10;

        List<sk4_CreateTransferRecords.FlowInput> inputs = new List<sk4_CreateTransferRecords.FlowInput>{ i1 };

        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];

        System.runAs(u) {
            sk4_CreateTransferRecords.createRecords(inputs);
        }

        List<sk4_transfer__c> deductionTransfers = [
            SELECT Id, sk4_type__c, sk4_transferAmount__c
            FROM sk4_transfer__c
            WHERE sk4_type__c = 'Deduction'
        ];

        Assert.areEqual(1, deductionTransfers.size());
        Assert.areEqual(-10, deductionTransfers[0].sk4_transferAmount__c);
    }
}
