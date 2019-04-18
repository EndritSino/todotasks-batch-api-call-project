@isTest
private class HttpCalloutHelperTest {

    @isTest
    static void performGetCalloutTest() {

        String exampleEndpoint = 'https://www.example.com/api/service';
        String jsonBody = '{"response": "simple test response in json format"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMockImpl(jsonBody));

        Test.startTest();

        Integer numberOfCalloutsBefore = Limits.getCallouts();

        HttpResponse res = HttpCalloutHelper.performGetCallout(exampleEndpoint);

        Integer numberOfCalloutsAfter = Limits.getCallouts();

        Test.stopTest();

        System.assertEquals((numberOfCalloutsBefore + 1), numberOfCalloutsAfter);

        System.assertEquals('application/json', res.getHeader('Content-Type'));
        System.assertEquals(jsonBody, res.getBody());
        System.assertEquals(200, res.getStatusCode());
    }
}