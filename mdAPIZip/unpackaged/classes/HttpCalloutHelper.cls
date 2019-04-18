public with sharing class HttpCalloutHelper {

    private static final String GET = 'GET';
    private static final Integer TIMEOUT = 2000;

    public static HttpResponse performGetCallout(String endpoint) {        
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(GET);
        req.setTimeout(TIMEOUT);

        HttpResponse res = h.send(req);

        return res;
    }
}