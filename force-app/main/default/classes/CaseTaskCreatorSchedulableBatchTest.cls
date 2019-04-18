@IsTest
private class CaseTaskCreatorSchedulableBatchTest {

    private static final Decimal INITIAL_OPPT_AMOUNT = 1000;

    @TestSetup
    static void createTestAccountCaseOppt() {
        Account account = new Account(
            Name = CaseTaskCreatorSchedulableBatch.MASTER_ACCOUNT_NAME
        );
        insert account;

        Case accountCase = new Case(
            Subject = 'Customer Complaint #1',
            Status = 'In Progress',
            AccountId = account.Id
        );
        insert accountCase;

        Opportunity oppt = new Opportunity(
            Name = 'Product Line 2nd Subscription',
            StageName = 'Discovery',
            CloseDate = System.today().addDays(23),
            Amount = INITIAL_OPPT_AMOUNT,
            AccountId = account.Id
        );
        insert oppt;
    }

    @IsTest
    static void batchExecutionTest_execute_now() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestJSONMockToDoTaskList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        Integer nrOfTasksBefore = [SELECT count() FROM Task];

        Test.startTest();

        CaseTaskCreatorSchedulableBatch.start(0);// 0 means execute batch now

        Test.stopTest();

        Integer nrOfTasksAfter = [SELECT count() FROM Task];
        System.assertNotEquals(0, nrOfTasksAfter);
        System.assert(nrOfTasksBefore < nrOfTasksAfter);

        Opportunity oppt = [SELECT Amount FROM Opportunity LIMIT 1];
        System.assertNotEquals(INITIAL_OPPT_AMOUNT, oppt.Amount);
        // There should be at least a successfully inserted task to increase the amount by 1%
        System.assert(INITIAL_OPPT_AMOUNT < oppt.Amount);
    }

    @IsTest
    static void batchExecutionTest_execute_scheduled_fixed_hour() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestJSONMockToDoTaskList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        Integer fixedHour = 22;

        Test.startTest();

        String formattedDateTomeNow = System.now().format();
        CaseTaskCreatorSchedulableBatch.start(fixedHour);// means execute batch every day at the fixed hour; in this case: 22:00

        Test.stopTest();

        // Assert that the job was scheduled
        CronTrigger ct = [SELECT
                            CronExpression,
                            TimesTriggered,
                            NextFireTime,
                            CronJobDetailId
                        FROM CronTrigger LIMIT 1];

        String expectedCronExpression = '0 0 ' + fixedHour + ' * * ?';
        System.assertEquals(expectedCronExpression, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        CronJobDetail cjd = [SELECT Id, Name, JobType FROM CronJobDetail WHERE Id =: ct.CronJobDetailId];
        String expectedJobName = 'To Do Task Creator Job - ' + formattedDateTomeNow;
        System.assertEquals(expectedJobName, cjd.Name);
    }

    @IsTest
    static void schedulableExecutionTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestJSONMockToDoTaskList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        Integer nrOfTasksBefore = [SELECT count() FROM Task];

        Test.startTest();

        String cronExp = '0 0 23 * * ?';// schedule class for every day execution at 23:00
        String jobName = 'Test Case Task Creator Scheduler';
        String jobId = System.schedule(jobName,
                                        cronExp, 
                                        new CaseTaskCreatorSchedulableBatch());

        Test.stopTest();

        // Assert that the job was scheduled
        CronTrigger ct = [SELECT
                            CronExpression,
                            TimesTriggered,
                            NextFireTime,
                            CronJobDetailId
                        FROM CronTrigger WHERE id = :jobId];

        System.assertEquals(cronExp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        CronJobDetail cjd = [SELECT Id, Name, JobType FROM CronJobDetail WHERE Id =: ct.CronJobDetailId];
        System.assertEquals(jobName, cjd.Name);
    }
}