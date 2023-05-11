public class sk4_HistoryController {

  public static void calculateTotals(Id recordId) {
    List<sk4_transfer__c> originalTransferList = [
      SELECT Id, sk4_type__c, sk4_transferAmount__c, sk4_amountAfter__c
      FROM sk4_transfer__c
      WHERE sk4_child__c = :recordId
      ORDER BY sk4_date__c ASC
    ];
    List<sk4_transfer__c> updatedTransferList = new List<sk4_transfer__c>();
    Decimal runningTotal = 0;

    for (sk4_transfer__c transfer : originalTransferList) {
      if (sk4_Const.PLUS_TRANSFERS.contains(transfer.sk4_type__c)) {
        runningTotal += transfer.sk4_transferAmount__c;
      } else if (sk4_Const.MINUS_TRANSFERS.contains(transfer.sk4_type__c)) {
        runningTotal -= transfer.sk4_transferAmount__c;
      }
      transfer.sk4_amountAfter__c = runningTotal;
      updatedTransferList.add(transfer);
    }

    try {
      update updatedTransferList;
    } catch (DmlException e) {
      throw new DmlException(
        'Oh woe is me, for my attempts to update transfers did fail. Pray tell, what foul magic has cursed my code and made it frail?'
      );
    }
  }
}
