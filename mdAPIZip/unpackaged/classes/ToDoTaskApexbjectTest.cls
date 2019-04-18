@IsTest
private class ToDoTaskApexbjectTest {

    @IsTest
    static void testObjectParsing() {
        String json= '{'+
        '    "userId": 1,'+
        '    "id": 1,'+
        '    "title": "delectus aut autem",'+
        '    "completed": false'+
        '  }';

        Test.startTest();

        ToDoTaskApexbject obj = (ToDoTaskApexbject) System.JSON.deserialize(json, ToDoTaskApexbject.class);

        Test.stopTest();

        System.assert(obj != null);
        System.assertEquals(1, obj.userId);
        System.assertEquals(1, obj.id);
        System.assertEquals('delectus aut autem', obj.title);
        System.assertEquals(false, obj.completed);
    }

}