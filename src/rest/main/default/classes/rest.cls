@RestResource(urlMapping='/rest/*')
global with sharing class rest {

    @HttpPost
    global static void createTransfer(TransferWrapper transfer) {
        if (transfer.childId == null || transfer.amount == null || transfer.type == null) {
            IllegalArgumentException ex = new IllegalArgumentException();
            ex.setMessage('Brak którego z argów');
            throw ex;
        }

            sk4_CreateTransferRecords.addWithdraw(transfer.childId, transfer.amount, transfer.type, transfer.description);

    }

    global class TransferWrapper {
        global Id childId;
        global Decimal amount;
        global String description;
        global String type;

    }

}
