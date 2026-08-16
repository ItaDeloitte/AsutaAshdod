@isTest
global class CreatePatientMock implements WebServiceMock {
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType)
           {
          
            ws_CreatePatient.InfoSorceSystem  InfoSorceSystem = new ws_CreatePatient.InfoSorceSystem();
            InfoSorceSystem.SysCode = 'str';
            InfoSorceSystem.Success = true;
            InfoSorceSystem.ErrorMessage = 'str';


           ws_CreatePatient.InfoSorceSystem[] InfoSorceSystemarray = new ws_CreatePatient.InfoSorceSystem[]{};
            InfoSorceSystemarray.add(InfoSorceSystem);

           ws_CreatePatient.ArrayOfInfoSorceSystemInfoSorceSystem ArrayOfInfoSorceSystems = new ws_CreatePatient.ArrayOfInfoSorceSystemInfoSorceSystem();
            ArrayOfInfoSorceSystems.InfoSorceSystem = InfoSorceSystemarray;

           ws_CreatePatient.CreatePatientResponse CreateAssutaPatientResult = new ws_CreatePatient.CreatePatientResponse();
            CreateAssutaPatientResult.SMSSendSuccess = true;
            CreateAssutaPatientResult.SMSSendErrorDescription = 'SMSSendErrorDescription';
            CreateAssutaPatientResult.PasswordText = 'PasswordText';
            CreateAssutaPatientResult.InfoSorceSystems = ArrayOfInfoSorceSystems;

           ws_CreatePatient.CreateAssutaPatientResponse_element response_x = new ws_CreatePatient.CreateAssutaPatientResponse_element();
           response_x.CreateAssutaPatientResult = CreateAssutaPatientResult;
           response.put('response_x', response_x); 
           } 
}