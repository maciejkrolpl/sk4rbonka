trigger sk4_TransferTrigger on sk4_transfer__c(before insert ) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      sk4_TransferTriggerHandler.beforeInsert(Trigger.new );
    }
  }
}
