global class HttpCalloutHelperMockImpl implements HttpCalloutMock {

    private String jsonBody;

    global HttpCalloutHelperMockImpl(String jsonBody) {
        this.jsonBody = jsonBody;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.jsonBody);
        res.setStatusCode(200);
        return res;
    }
}