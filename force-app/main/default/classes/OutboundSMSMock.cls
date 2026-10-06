@isTest
global class OutboundSMSMock implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Success": true, "ErrorMessage": ""}');
        return res;
    }
}
