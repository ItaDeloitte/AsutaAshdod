@isTest
global class ws_insertDocMaccabiToPortal_Mock implements HttpCalloutMock{

    @TestVisible
    private String statusCode {get; set;}

    global ws_insertDocMaccabiToPortal_Mock() {
        this.statusCode = '1';
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');     
        response.setBody('{"AssutaResult":"<Response><StatusCode> ' + statusCode + ' </StatusCode><StatusDesc></StatusDesc><ErrorDesc> Success </ErrorDesc><Results><XMLFileUrl>http://docsportaltest.asuta.co.il/sites/DocsPortalTest05/Site/DocLib/DocLibAutoCreatedByEDM3/00454719.xml</XMLFileUrl><PDFFileUrl>http://docsportaltest.asuta.co.il/sites/DocsPortalTest05/Site/DocLib/DocLibAutoCreatedByEDM3/00454819.pdf</PDFFileUrl><AutoNumber>00454819</AutoNumber></Results></Response>"}');
        response.setStatusCode(200);
        return response;
    }
}