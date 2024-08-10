@IsTest
public with sharing class sk4_TransferControllerTest {
    @IsTest
    static void testGetTransfersHistory() {
        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>{
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_POCKETMONEY, 20),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_WITHDRAW, -10),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_WITHDRAW, -10),
            sk4_TestDataFactory.createStandardTransfer(sk4_Const.TRANSFER_TYPE_CUMULATION, 5)
        };

        Test.startTest();
        SOQL.setMock('sk4_TransferController', transfers);
        List<sk4_TransferController.Wrapper> wrappers = sk4_TransferController.getTransfersByChildren(
            'a007Y00000O3ODfAKE'
        );
        Test.stopTest();

        Assert.areEqual(4, wrappers.size());
        Assert.areEqual(5, wrappers[3].total);
    }
}
