@isTest
global class OutboundSMSMock implements WebServiceMock {

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        WS_OutboundSMS.SendText sendSMSRes = new WS_OutboundSMS.SendText();
        sendSMSRes.Success = true;
        sendSMSRes.ErrorMessage = '';

        WS_OutboundSMS.SendSMSResponse_element response_x = new WS_OutboundSMS.SendSMSResponse_element();
        response_x.SendSMSResult = sendSMSRes;
        response.put('response_x', response_x);
    }
}