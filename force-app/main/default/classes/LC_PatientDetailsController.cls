//Test: LC_PatientDetailsControllerTest
public with sharing class LC_PatientDetailsController implements ILCController {

    public class LC_PatientDetailsControllerException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getPatientDetails' {
                return this.getPatientDetails((String) params.get('patientId'),
                                              (String) params.get('idType'));
            }
            when 'setPatientDetails' {
                return this.setPatientDetails((String) params.get('patientId'),
                                              (String) params.get('idType'),
                                              (Map<Object, Object>) params.get('sensitivitiesData'));
            }
            when else {
                throw new LC_PatientDetailsControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response getPatientDetails(String patientId, String idType) {
        System.debug('LC_PatientDetailsController.getPatientDetails...\npatientId: ' + patientId + '\nidType: ' + idType);
        return new Response(new PatientFormWrapper(LC_BackendUtils.getPatientAccountData(patientId, idType)));
    }

    private Response setPatientDetails(String patientId, String idType, Map<Object, Object> sensitivitiesData) {
        System.debug('LC_PatientDetailsController.setPatientDetails...\npatientId: ' + patientId + '\nidType: ' + idType + '\nsensitivitiesData: ' + sensitivitiesData );
        Account account = LC_BackendUtils.getPatientAccountData(patientId, idType);
        System.debug('account ' + account);
        Account patient = new Account(Id = account.Id);
        Boolean updated = false;
        map<String, String> sensitivitiesMap = new Map<String, String>();

        for(Object strKey: sensitivitiesData.keyset()){
            sensitivitiesMap.put(String.valueof(strKey), String.valueof(sensitivitiesData.get(strKey)));
        }
        if(account.Asthma__c != sensitivitiesMap.get('asthma')){
            patient.Asthma__c = sensitivitiesMap.get('asthma');
            updated = true;
        }
        String metalsInBody = (sensitivitiesMap.get('metalsInBody').remove('(').remove(')')).replace(', ', ';');
        if(account.Metals_in_body__c != metalsInBody){
            patient.Metals_in_body__c = metalsInBody;
            updated = true;
        }
        if(account.Iodine_sensitivity__c != sensitivitiesMap.get('iodineSensitivity')){
            patient.Iodine_sensitivity__c = sensitivitiesMap.get('iodineSensitivity');
            updated = true;
        }
        if(account.Diabetic__c != sensitivitiesMap.get('diabetic')){
            patient.Diabetic__c = sensitivitiesMap.get('diabetic'); 
            updated = true;
        }
        if(account.Dust__c != sensitivitiesMap.get('dust')){
            patient.Dust__c = sensitivitiesMap.get('dust');
            updated = true;
        }
        if(account.Blood_Dilution__c != sensitivitiesMap.get('bloodDilution')){
            patient.Blood_Dilution__c = sensitivitiesMap.get('bloodDilution'); 
            updated = true;
        }
        if(account.Weight__c != sensitivitiesMap.get('weight')){
            patient.Weight__c = sensitivitiesMap.get('weight');
            updated = true;
        }
        if(account.Gender__c != sensitivitiesMap.get('gender')){
            patient.Gender__c = sensitivitiesMap.get('gender');
            updated = true;
        }
        System.debug('updated ' + updated);
        if(updated) update patient;
        return new Response('success');
    }

    public class PatientFormWrapper {
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public Account accountRecord {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> asthmaOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> metalsInBodyOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> iodineSensitivityOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> diabeticOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> dustOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> bloodDilutionOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> weightOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> genderOptions {get;set;}
        @AuraEnabled
        public String defaultAsthma {get;set;}
        @AuraEnabled
        public List<String> defaultMetalsInBody {get;set;}
        @AuraEnabled
        public String defaultIodineSensitivity {get;set;}
        @AuraEnabled
        public String defaultDust {get;set;}
        @AuraEnabled
        public String defaultDiabetic {get;set;}
        @AuraEnabled
        public String defaultBloodDilution {get;set;}
        @AuraEnabled
        public String defaultWeight {get;set;}
        @AuraEnabled
        public String defaultGender {get;set;}
        public PatientFormWrapper(Account patient) {
            this.accountRecord = patient;
            this.accountName = patient.Name;
            this.asthmaOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Asthma__c', false);
            this.defaultAsthma = patient.Asthma__c != null ? patient.Asthma__c : '';
            this.metalsInBodyOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Metals_in_body__c', false);
            this.defaultMetalsInBody = patient.Metals_in_body__c != null ? new List<String> (patient.Metals_in_body__c.split(';')) : new List<String>();
            this.iodineSensitivityOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Iodine_sensitivity__c', false);
            this.defaultIodineSensitivity = patient.Iodine_sensitivity__c != null ? patient.Iodine_sensitivity__c : '';
            this.diabeticOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Diabetic__c', false);
            this.defaultDiabetic = patient.Diabetic__c != null ? patient.Diabetic__c : '';
            this.dustOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Dust__c', false);
            this.defaultDust = patient.Dust__c != null ? patient.Dust__c : '';
            this.bloodDilutionOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Blood_Dilution__c', false);
            this.defaultBloodDilution = patient.Blood_Dilution__c != null ? patient.Blood_Dilution__c : '';
            this.weightOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Weight__c', false);
            this.defaultWeight = patient.Weight__c != null ? patient.Weight__c : '';
            this.genderOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Gender__c', false);
            this.defaultGender = patient.Gender__c != null ? patient.Gender__c : '';
        }
    }
}