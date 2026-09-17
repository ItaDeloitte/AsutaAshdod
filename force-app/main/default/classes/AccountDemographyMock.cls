@isTest
global class AccountDemographyMock implements WebServiceMock {
    
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        System.debug('REQUEST INSTANCE '+ request);
        if (request instanceof ws_CreatePatient.CreateAssutaPatientResponse_element || request instanceof ws_CreatePatient.CreateAssutaPatient_element) {
            System.debug('request instanceof ws_CreatePatient.CreateAssutaPatientResponse_element || request instanceof ws_CreatePatient.CreateAssutaPatient_element');
            ws_CreatePatient.InfoSorceSystem infoSystem = new ws_CreatePatient.InfoSorceSystem();
            infoSystem.SysCode = 'SysCode';
            infoSystem.Success = true;
            infoSystem.ErrorMessage = 'ErrorMessage';

            ws_CreatePatient.ArrayOfInfoSorceSystemInfoSorceSystem arrauInfoSys = new ws_CreatePatient.ArrayOfInfoSorceSystemInfoSorceSystem();
            arrauInfoSys.InfoSorceSystem = new List<ws_CreatePatient.InfoSorceSystem>{infoSystem};
                
            ws_CreatePatient.CreatePatientResponse assutePatientResult = new ws_CreatePatient.CreatePatientResponse();
            assutePatientResult.SMSSendSuccess = false;
            assutePatientResult.SMSSendErrorDescription = 'test failed MOCK ws_CreatePatient';
            assutePatientResult.PasswordText = 'test';
            assutePatientResult.InfoSorceSystems = arrauInfoSys;
            
            ws_CreatePatient.CreateAssutaPatientResponse_element response_x = new ws_CreatePatient.CreateAssutaPatientResponse_element();
            response_x.CreateAssutaPatientResult = assutePatientResult;
            response.put('response_x', response_x);
        }
        else if (request instanceof WS_OutboundSMS.SendSMSResponse_element || request instanceof WS_OutboundSMS.SendSMS_element) {
            System.debug('request instanceof WS_OutboundSMS.SendSMSResponse_element || request instanceof WS_OutboundSMS.SendSMS_element');
            WS_OutboundSMS.SendText smsResult = new WS_OutboundSMS.SendText();
            smsResult.Success = true;
        	smsResult.ErrorMessage = 'test';
            
            WS_OutboundSMS.SendSMSResponse_element response_x = new WS_OutboundSMS.SendSMSResponse_element();
            response_x.SendSMSResult = smsResult;
            response.put('response_x', response_x);
        }
    }
}