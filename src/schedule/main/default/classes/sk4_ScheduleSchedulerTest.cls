@IsTest
public with sharing class sk4_ScheduleSchedulerTest {
    private final static String CRON_EXP = '0 0 0 ? * *';

    @IsTest
    static void shouldRunSchedule() {
        Test.startTest();
        String scheduleJobId = System.schedule('Test Schedule Cumulations', CRON_EXP, new sk4_ScheduleScheduler());
        Test.stopTest();

        List<String> classNames = new List<String>();

        for (ApexClass apexClass : [
            SELECT Id, Name
            FROM ApexClass
            WHERE Id IN (SELECT ApexClassId FROM AsyncApexJob)
            ORDER BY Name ASC
        ]) {
            classNames.add(apexClass.Name);
        }

        Assert.areEqual('sk4_ScheduleBatch', classNames[0]);
        Assert.areEqual('sk4_ScheduleScheduler', classNames[1]);
    }
}
