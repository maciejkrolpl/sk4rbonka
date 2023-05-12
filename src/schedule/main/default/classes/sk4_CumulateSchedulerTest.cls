@IsTest
public with sharing class sk4_CumulateSchedulerTest {
    private final static String CRON_EXP = '0 0 0 ? * *';

    @IsTest
    static void shouldRunSchedule() {
        Test.startTest();
        String scheduleJobId = System.schedule(
            'Test Schedule Cumulations',
            CRON_EXP,
            new sk4_CumulateScheduler()
        );
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

        Assert.areEqual('sk4_CumulateBatch', classNames[0]);
        Assert.areEqual('sk4_CumulateScheduler', classNames[1]);
    }
}
