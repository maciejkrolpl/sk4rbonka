public with sharing class sk4_CumulateScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        sk4_CumulateBatch b = new sk4_CumulateBatch();
        Database.executeBatch(b);
    }
}