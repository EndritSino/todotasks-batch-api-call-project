public with sharing class TaskDomain {

    public static String TODO_TASKS_ENDPOINT = 'https://jsonplaceholder.typicode.com/todos';

    public static List<ToDoTaskApexbject> getTasksFromAPI() {
        HttpResponse response = HttpCalloutHelper.performGetCallout(TODO_TASKS_ENDPOINT);
        String body = response.getBody();
        return (List<ToDoTaskApexbject>) JSON.deserialize(body, List<ToDoTaskApexbject>.class);
    }

    public static Task createTask(ToDoTaskApexbject todoTaskObject, Id ownerId, Id whatId) {
        return new Task(
            Subject = todoTaskObject.title,
            Status = (todoTaskObject.completed) ? 'Completed' : 'In Progress',
            External_Id__c = String.valueOf(todoTaskObject.id),
            OwnerId = ownerId,
            WhatId = whatId
        );
    }

    public static Map<Integer, Boolean> insertTasks(List<Task> newTasksList) {
        Map<Integer, Boolean> insertionFeedbackMap = new Map<Integer, Boolean>();
        Database.SaveResult[] saveResults = Database.insert(newTasksList, false);

        for (Integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult sr =saveResults[i];
            Boolean isSuccess = sr.isSuccess();
            insertionFeedbackMap.put(i, isSuccess);
        }

        return insertionFeedbackMap;
    }

}