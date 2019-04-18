public with sharing class CaseTaskCreatorSchedulableBatch implements Database.Batchable<SObject>,
                                                                Database.AllowsCallouts,
                                                                Schedulable {

    public static String MASTER_ACCOUNT_NAME = 'Uberall GmbH';

    private String query = 'SELECT CaseNumber, AccountId FROM Case WHERE Account.Name = :MASTER_ACCOUNT_NAME LIMIT 1';

    // BATCH
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        CaseTaskCreatorBatchManager.process(scope);
    }

    public void finish(Database.BatchableContext bc) {}

    // SCHEDULER
    public void execute(SchedulableContext sc) {
        Database.executebatch(new CaseTaskCreatorSchedulableBatch());
    }

    // Batch instantiation
    public static void start(Integer hour){
        String jobName = 'To Do Task Creator Job';
        if (hour == 0) {
            Database.executebatch(new CaseTaskCreatorSchedulableBatch());
        }
        else {
            jobName += ' - ' + System.now().format();
            String cronExpression = '0 0 ' + hour + ' * * ?';
            start(jobName, cronExpression);
        }
    }

    public static void start(String jobName, String cronExpression) {
        System.schedule(jobName, cronExpression, new CaseTaskCreatorSchedulableBatch());
    }
}