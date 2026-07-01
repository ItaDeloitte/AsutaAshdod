@IsTest
global class ws_maccabiIsReceiveDocFromArc_Mock implements WebServiceMock {
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

            ws_maccabiIsReceiveDocFromArcSOAP.isReceiveDocumentFromArchivesResponse_element response_x = new ws_maccabiIsReceiveDocFromArcSOAP.isReceiveDocumentFromArchivesResponse_element();
            response_x.isReceiveDocumentFromArchivesResult = '<OutputXMLString><NameDocLastO>הפניה </NameDocLastO>'
                                                            +' <ValueDocument>93042</ValueDocument>'
                                                            +'<RepresentationOfTheFile>JVBERi0xLjcNCX+</RepresentationOfTheFile>'
                                                            +'<PathDocument></PathDocument>'
                                                            +'<ErrorCode>0</ErrorCode>'
                                                            +'<DescriptionErrorCode> </DescriptionErrorCode>'
                                                            +'<TypeDocument></TypeDocument>'
                                                            +'<QtyDoc>1</QtyDoc>'
                                                            +'<StatusAgain>ל</StatusAgain>'
                                                            +'<ResultMessage>'
                                                            +'<Message>Success</Message>'
                                                            +'<Description></Description>'
                                                            +'<Code>0</Code>'
                                                            +'</ResultMessage></OutputXMLString>';
            response.put('response_x', response_x);
        }
}