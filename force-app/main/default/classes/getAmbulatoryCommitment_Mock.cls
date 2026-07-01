public class getAmbulatoryCommitment_Mock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"CommitmentID": "123456789", "Success" : true, "ErrorMessage" : "Success"}');
        response.setStatusCode(200);
        return response;
    }
}