public with sharing class sk4_ScheduleScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        sk4_ScheduleBatch b = new sk4_ScheduleBatch();
        Database.executeBatch(b);
    }
}