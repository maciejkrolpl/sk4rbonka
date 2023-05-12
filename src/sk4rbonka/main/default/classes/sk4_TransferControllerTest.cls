@IsTest
public with sharing class sk4_TransferControllerTest {
    
    private static final String USERNAME = 'TestUser';
    private static final String FAMILY = 'Doe';
    private static final String PARENT = 'Jane';
    private static final String CHILD1 = 'Aaa';
    private static final String CHILD2 = 'Zzz';


    @TestSetup
    static void makeData(){
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
        insert new List<sk4_child__c>{child1, child2};

        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>{
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_POCKETMONEY, 15, child1.Id, parent.Id),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_SAVINGS, 10, child1.Id, parent.Id),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_DEDUCTION, 5, child1.Id, parent.Id),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_POCKETMONEY, 20, child2.Id, parent.Id),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_WITHDRAW, 10, child2.Id, parent.Id)
        };
        insert transfers;

        sk4_cumulation__c cumulation = sk4_TestDataFactory.createCumulation(Date.today(), family.Id);
        insert cumulation;
    }
    }

    @IsTest
    static void testGetTransfersHistory() {
        User user = [SELECT Id FROM User WHERE LastName =: USERNAME];
        List<sk4_child__c> children = [SELECT Id, Name FROM sk4_child__c ORDER BY Name ASC];
        System.runAs(user) {
            List<sk4_TransferController.Wrapper> transfers1 = sk4_TransferController.getTransfersByChildren(children[0].Id);
            List<sk4_TransferController.Wrapper> transfers2 = sk4_TransferController.getTransfersByChildren(children[1].Id);

            Assert.areEqual(3, transfers1.size());
            Assert.areEqual(2, transfers2.size());
            
            Assert.areEqual(10.00, transfers1[0].amount);
            Assert.areEqual(10.00, transfers1[0].total);
            Assert.areEqual('Savings', transfers1[0].type);
            Assert.areEqual(5.00, transfers1[1].amount);
            Assert.areEqual(5.00, transfers1[1].total);
            Assert.areEqual('Deduction', transfers1[1].type);
            Assert.areEqual(2.50, transfers1[2].amount);
            Assert.areEqual(7.50, transfers1[2].total);
            Assert.areEqual('Cumulation', transfers1[2].type);

            Assert.areEqual(10.00, transfers2[0].amount);
            Assert.areEqual(-10.00, transfers2[0].total);
            Assert.areEqual('Withdraw', transfers2[0].type);
            Assert.areEqual(0.00, transfers2[1].amount);
            Assert.areEqual(-10.00, transfers2[1].total);
            Assert.areEqual('Cumulation', transfers2[1].type);

        }
    }

}