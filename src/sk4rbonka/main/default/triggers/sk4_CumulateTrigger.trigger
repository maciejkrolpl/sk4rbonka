trigger sk4_CumulateTrigger on sk4_cumulation__c(before insert, after insert, before update, before delete ) {

  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      sk4_CumulateTriggerHandler.beforeInsert(Trigger.new );
    } else if (Trigger.isUpdate) {
      sk4_CumulateTriggerHandler.beforeUpdate(Trigger.new );
    } else if (Trigger.isDelete) {
      sk4_CumulateTriggerHandler.beforeDelete(Trigger.oldMap);
    }
  } else if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      sk4_CumulateTriggerHandler.afterInsert(trigger.new );
    }
  }
}