@isTest
global class ws_gateScannerApiDownload_Mock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();  
        response.setBody('aGVsbG8gdGVzdCBvZiBnYXRlIHNjYW5uZXI=');
        response.setStatusCode(200);
        return response;
    }

}