@IsTest
global class ws_maccabiInsertDocumentToArchive_Mock implements WebServiceMock {
   global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            ws_maccabiInsertDocumentToArchiveSOAP.insertDocumentToArchiveResponse_element response_x = new ws_maccabiInsertDocumentToArchiveSOAP.insertDocumentToArchiveResponse_element();
            response_x.insertDocumentToArchiveResult = '<SOAP-ENV:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"> <ser-root:insertDocumentToArchiveResponse SOAP-ENC:root="1" xmlns:ser-root="http://MACCABI-ESB/macHit.ws.provider:InsertDocumentToArchive"> <OutputXMLString xsi:type="xsd:string"><OutputXMLString><PRDOCUMENTPATH>h00307961110 </PRDOCUMENTPATH> <PRRTNSTATUS>0</PRRTNSTATUS> <ResultMessage> <Message>Success</Message> <Description></Description> <Code>0</Code> </ResultMessage></OutputXMLString></OutputXMLString> </ser-root:insertDocumentToArchiveResponse> </SOAP-ENV:Body>';
            response.put('response_x', response_x);
        }
}