public with sharing class sk4_addWithdrawController {
    @AuraEnabled
    public static void createTransfer(Id childId, Decimal amount, String type, String description) {
        try {
            sk4_CreateTransfers.addWithdraw(childId, amount, type, description);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
