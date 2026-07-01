//Test:GetAccountDemographyTest
@RestResource(urlMapping='/AccountDemography/*')
global with sharing class GetAccountDemography {
    
    public GetAccountDemography() {}

    @HttpPost
    global static void post() {
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            System.debug('jsonBody: ' + jsonBody);

            if (String.isBlank(jsonBody)) {
                system.debug('no request');
                setResponse('No requestBody was provided.', 500);               
            }

            RequestWrp request = (RequestWrp) JSON.deserialize(jsonBody, RequestWrp.class);
            System.debug('request: ' + request);
            Account patient = getDemography(request.idNumber);
            setResponse(JSON.serialize(new ResponsetWrp(patient)), 200);

        } catch (Exception e) {
            system.debug('errr ' + e.getMessage() + '  ' + e.getStacktraceString());
            setResponse(e.getMessage(), 500);            
        }
    }

    private static Account getDemography(String idNumber) {
        System.debug('GetAccountDemography.getDemography ...');
        Account patient = [SELECT Id, Last_update_demographic__c, SorceSysCode__c, QueryStatus__c, ErrorMessage__c, ErrorCode__c, ID_Number__c, ID_Type__c, DisableValidation__c,
                           Start_Date_shaban_maccabi__c, Insurance_is_valid__c, AccountStatus__c, Gender__c, PersonBirthdate, firstName, LastName, Father_Name__c, Patient_Age__c, Phone
                           FROM Account WHERE ID_Number__c =: idNumber AND ID_Type__c = '1'];
        patient.Last_update_demographic__c = DateTime.now().addDays(-1);
        DemographyManager.AccountWithDisabilities accountWithDemography = DemographyManager.updateAccountWithExtendedDetails(patient, patient.ID_Number__c, patient.ID_Type__c);
        if (accountWithDemography.IsDemographyExist) {
            update accountWithDemography.acct;
            return accountWithDemography.acct;
        }
        
        System.debug('patient: ' + patient);
        return patient;
    }

    private static void setResponse(String payload, Integer code) {
        System.debug(code + ' ' + payload);
        if (RestContext.response == null) {
            RestContext.response = new RestResponse();
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(payload);
        RestContext.response.statusCode = code;
    }

    public class RequestWrp {
        public String idNumber;        
    }

    global class ResponsetWrp { 
        public Id accId;
        public string age;
        public string phone;
        public String gender;
        public String firstName;
        public String lastName;
        public String idNumber;
        public Date birthDate;        
        public String fatherName;              
    
        public ResponsetWrp(Account acc) {
            this.accId = acc.Id;
            this.age = acc.Patient_Age__c;
            this.phone = acc.Phone;
            this.gender = acc.Gender__c;
            this.firstName = acc.FirstName;
            this.lastName = acc.LastName;
            this.idNumber = acc.ID_Number__c;
            this.birthDate = acc.PersonBirthdate;        
            this.fatherName = acc.Father_Name__c;
            
        }
    }
}