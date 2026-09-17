@isTest
global class DemographyHttpMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"IsDemographyExist":1,"PatientID":"123456789","FirstName":"Test","LastName":"Patient","HMOCode":2,"BirthDate":"1990-01-01","Gender":"ז","IsEligble":true,"BeginMembership":"2020-01-01","IdentificationCode":"1","UserSecurityAreaLevel":"1","InfoSorceSystems":{"InfoSorceSystem":[]},"ResultMessage":{"Status":"0","ErrorDescription":"","ErrorCode":0}}');
        return res;
    }
}
