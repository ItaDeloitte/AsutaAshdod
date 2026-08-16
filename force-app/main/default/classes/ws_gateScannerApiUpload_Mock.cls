@isTest
global class ws_gateScannerApiUpload_Mock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');     
        response.setBody('{"JobDescription":null,"JobError":null,"JobID":"6cf45364-9dc0-4df8-b28b-02ae35930b15","PlaceInQueue":-99,"ScanProgress":0,"ScanStageProgress":0,"Scan_Status_c":1,"ScansLogArr":null}');
        response.setStatusCode(200);
        return response;
    }

}