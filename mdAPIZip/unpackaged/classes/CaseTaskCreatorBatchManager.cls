public with sharing class CaseTaskCreatorBatchManager {

    public static void process(List<Case> scope) {
        // R1
        Case taskParentCase = scope[0];

        List<User> userList = [SELECT
                                    Name
                                FROM User
                                WHERE IsActive = true
                                AND Profile.Name = 'System Administrator'];

        List<Task> newTasksList = new List<Task>();
        List<ToDoTaskApexbject> todoTaskObjectList = TaskDomain.getTasksFromAPI();

        for (Integer i = 0; i < todoTaskObjectList.size(); i++) {
            ToDoTaskApexbject todoTaskObject = todoTaskObjectList[i];

            // To avoid any recurring duplicates we make sure the external id(id field) is present
            if (todoTaskObject.Id == null) {
                continue;
            }

            Id ownerId = (Math.mod(i, 2) == 0) ? userList[0].Id : userList[1].Id;

            newTasksList.add(
                TaskDomain.createTask(todoTaskObject, ownerId, taskParentCase.Id)
            );
        }

        Map<Integer, Boolean> insertionFeedbackMap = TaskDomain.insertTasks(newTasksList);

        // R2
        Opportunity oppt = [SELECT
                                Name,
                                Amount,
                                StageName
                            FROM Opportunity
                            WHERE AccountId = :taskParentCase.AccountId
                            LIMIT 1];

        Decimal nrOfCompletedTasks = 0.0;
        for (Integer i: insertionFeedbackMap.keySet()) {
            if (insertionFeedbackMap.get(i) &&
                newTasksList.get(i).Status.equals('Completed')) {
                nrOfCompletedTasks += 1.0;
            }
        }
        Decimal opptAmountPercentIncrease = nrOfCompletedTasks.divide(100, 2);
        Decimal newAmount = oppt.Amount * (1 + opptAmountPercentIncrease);

        update new Opportunity(
            Id = oppt.Id,
            Amount = newAmount
        );
    }

}