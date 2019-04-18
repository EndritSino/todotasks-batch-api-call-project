@IsTest
private class TaskDomainTest {

    @IsTest
    static void getTasksFromAPITest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TestJSONMockToDoTaskList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        List<ToDoTaskApexbject> todoTaskObjectList = TaskDomain.getTasksFromAPI();

        Test.stopTest();

        System.assertNotEquals(null, todoTaskObjectList);
        System.assertNotEquals(0, todoTaskObjectList.size());

        // Take a sample from the retreived tasks and confirm that the data is not null
        ToDoTaskApexbject taskObject = todoTaskObjectList[23];

        System.assertNotEquals(null, taskObject.userId);
        System.assertNotEquals(null, taskObject.id);
        System.assert(!String.isBlank(taskObject.title));
        System.assertNotEquals(null, taskObject.completed);
    }

    @IsTest
    static void createTaskTest() {
        ToDoTaskApexbject taskObject = new ToDoTaskApexbject();
        taskObject.userId = 2942;
        taskObject.id = 23;
        taskObject.title = 'lorem ipsum emangiajfud';
        taskObject.completed = true;

        Account testAccount = new Account(
            Name = 'Test Acc'
        );
        insert testAccount;
        Id ownerId = UserInfo.getUserId();

        Test.startTest();

        Task sfTask = TaskDomain.createTask(taskObject, ownerId, testAccount.Id);

        Test.stopTest();

        System.assertNotEquals(null, sfTask);

        System.assertEquals(taskObject.title, sfTask.Subject);
        System.assertEquals('Completed', sfTask.Status);
        System.assertEquals(String.valueOf(taskObject.id), sfTask.External_Id__c);
        System.assertEquals(ownerId, sfTask.OwnerId);
        System.assertEquals(testAccount.Id, sfTask.WhatId);
    }

    @IsTest
    static void insertTasksTest() {
        List<Task> taskListToInert = new List<Task>();

        // 1. Task should be inserted correctly
        taskListToInert.add(
            new Task(
                Subject = 'lorem ispuasud'
            )
        );
        // 2. Task should be inserted correctly
        taskListToInert.add(
            new Task(
                Subject = 'adoramentiansd oasdnhgiadj'
            )
        );
        // 3. Task should be NOT inserted correctly
        taskListToInert.add(
            new Task(
                Subject = 'lorem ispuasud',
                OwnerId = null
            )
        );

        Test.startTest();

        Map<Integer, Boolean> feedbackMap = TaskDomain.insertTasks(taskListToInert);

        Test.stopTest();

        System.assertEquals(3, feedbackMap.size());

        System.assertEquals(true, feedbackMap.get(0));
        System.assertEquals(true, feedbackMap.get(1));
        System.assertEquals(false, feedbackMap.get(2));
    }

}