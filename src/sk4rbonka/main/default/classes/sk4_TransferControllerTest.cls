@IsTest
public with sharing class sk4_TransferControllerTest {
    @IsTest
    static void testGetTransfersHistory() {
        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>{
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_POCKETMONEY, 20),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_OTHER, 20),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_WITHDRAW, 10),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_DEDUCTION, 10),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_DEDUCTION, 10),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_CUMULATION, 5)
        };

        Test.startTest();
        SOQL.setMock('sk4_TransferController', transfers);
        List<sk4_TransferController.Wrapper> wrappers = sk4_TransferController.getTransfersByChildren(
            'a007Y00000O3ODfAKE'
        );
        Test.stopTest();

        Assert.areEqual(6, wrappers.size());
        Assert.areEqual(15, wrappers[5].total);
    }
}
