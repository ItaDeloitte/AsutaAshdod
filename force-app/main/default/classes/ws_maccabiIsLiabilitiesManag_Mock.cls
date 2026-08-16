@IsTest
global class ws_maccabiIsLiabilitiesManag_Mock implements WebServiceMock {
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


        ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput RetOutput = new ws_maccabiIsLiabilitiesManag.IsLiabilitiesManagementOutput();
            RetOutput.LiabilityID = '2143556';
            RetOutput.Deductible = 'str';
            RetOutput.AmountDoctor = '500';
            RetOutput.AmountImplants = '10';
            RetOutput.DateCreateLiability = '10102019';
            RetOutput.DateSofLiability = '10102019';
            RetOutput.ErrorCode = '0';

            ws_maccabiIsLiabilitiesManagSOAP.isLiabilitiesManagementResponse_element response_x = new ws_maccabiIsLiabilitiesManagSOAP.isLiabilitiesManagementResponse_element();
            response_x.isLiabilitiesManagementResult = RetOutput;
            response.put('response_x', response_x);
    }
}