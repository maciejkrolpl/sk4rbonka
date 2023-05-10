global class sk4_CumulatePercents implements Database.Batchable<sObject>, schedulable {
    // add Database.Stateful above to make data transcend batches
    String query;
    global sk4_CumulatePercents() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        // execute code
    }

    global void finish(Database.BatchableContext BC) {
        // finish code
    }

    global void execute(SchedulableContext SC) {
        database.executebatch(new sk4_CumulatePercents());
    }

    global static void start(integer hour) {
        string jobName = 'job name';
        if (hour == 0)
            database.executebatch(new sk4_CumulatePercents());
        else {
            jobName = jobName += ' - ' + datetime.now().format();
            string cron = '0 0 ' + string.valueof(hour) + ' * * ?';
            system.schedule(jobName, cron, new sk4_CumulatePercents());
        }
    }

}