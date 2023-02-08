public with sharing class sk4_CumulateScheduler implements Schedulable {
    /*
    sk4_CumulateScheduler s = new sk4_CumulateScheduler();
    String sch = '0 0 1 ? * * *';
    System.schedule('Cumulate Job', sch, s);
    */

    public void execute(SchedulableContext sc) {
        sk4_CumulateBatch b = new sk4_CumulateBatch();
        Database.executeBatch(b);
    }
}