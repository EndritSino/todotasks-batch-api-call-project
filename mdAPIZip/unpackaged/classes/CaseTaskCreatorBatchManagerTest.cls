@IsTest
private class CaseTaskCreatorBatchManagerTest {

    @IsTest
    static void processTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestJSONMockToDoTaskList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        Account account = new Account(
            Name = 'Hiberweis GmbH Test'
        );
        insert account;

        Case accountCase = new Case(
            Subject = 'Customer Complaint #1',
            Status = 'In Progress',
            AccountId = account.Id
        );
        insert accountCase;

        Decimal initialOpptAmount = 1000.00;
        Opportunity oppt = new Opportunity(
            Name = 'Product Line 2nd Subscription',
            StageName = 'Discovery',
            CloseDate = System.today().addDays(23),
            Amount = initialOpptAmount,
            AccountId = account.Id
        );
        insert oppt;

        Integer nrOfTasksBefore = [SELECT count() FROM Task];

        Test.startTest();

        List<Case> caseList = [SELECT CaseNumber, AccountId FROM Case];
        CaseTaskCreatorBatchManager.process(caseList);

        Test.stopTest();

        Integer nrOfTasksAfter = [SELECT count() FROM Task];
        System.assertNotEquals(0, nrOfTasksAfter);
        System.assert(nrOfTasksBefore < nrOfTasksAfter);

        oppt = [SELECT Amount FROM Opportunity WHERE Id = :oppt.Id];
        System.assertNotEquals(initialOpptAmount, oppt.Amount);
        // There should be at least a successfully inserted task to increase the amount by 1%
        System.assert(initialOpptAmount < oppt.Amount);
    }

}