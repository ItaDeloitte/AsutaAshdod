// Test: LC_FillAccountTest
public with sharing class LC_FillAccountService {

    public class LC_FillAccountException extends Exception {}

    private static LC_FillAccountService instance;

    private Opportunity oppt;

    public static LC_FillAccountService getInstance() {
        return getInstance(null);
    }

    public static LC_FillAccountService getInstance(String opptId) {
        if (instance == null) {
            instance = new LC_FillAccountService(opptId);
        }
        return instance;
    }

    private LC_FillAccountService(String opptId) {
        this.oppt = LC_FillAccountUtil.obtainOpportunityDetails(opptId);
    }

    public Boolean isAccountFull() {
        Account patient = LC_FillAccountUtil.obtainAccountDetails(this.oppt.AccountId);
        System.debug('patient: ' + patient);

        return patient.AccountStatus__c == 'לקוח מלא' ? true : false;
    }

    public FormDetails getAccount() {
        Account patient = LC_FillAccountUtil.obtainAccountDetails(this.oppt.AccountId);
        System.debug('patient: ' + patient);

        return new FormDetails(patient);
    }

    public Id setAccount(Map<String, Object> acctData) {
        Account patient = LC_FillAccountUtil.obtainAccountDetails(this.oppt.AccountId);
        System.debug('patient: ' + patient);

        this.setField(patient, 'FirstName', acctData.get('firstName'));
        this.setField(patient, 'LastName', acctData.get('lastName'));
        this.setField(patient, 'ID_Number__c', acctData.get('idNumber'));
        this.setField(patient, 'ID_Type__c', acctData.get('idType'));
        this.setField(patient, 'Phone', acctData.get('phone'));
        this.setField(patient, 'Gender__c', acctData.get('gender'));
        this.setField(patient, 'Mailing_approval__c', acctData.get('mailingApproval'));
        this.setField(patient, 'Insurer_factor__c', acctData.get('insurerFactor'));
        this.setField(patient, 'Other_Health_Services__c', acctData.get('otherHealthServices'));
        this.setField(patient, 'PersonBirthdate', Date.valueOf(String.valueOf(acctData.get('birthDay'))));
        update patient;

        return patient.Id;
    }

    private void setField(Account patient, String fieldName, Object value) {
        if (value != null && value != patient.get(fieldName)) {
            patient.put(fieldName, value);
        }
    }

    public class FormDetails {
        @AuraEnabled
        public Account accountRecord {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> idTypeOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> mailingApprovalOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> genderOptions {get;set;}
        @AuraEnabled
        public List<PicklistUtil.PicklistValue> insurerFactorOptions {get;set;}
        //@AuraEnabled
        //public List<PicklistUtil.PicklistValue> otherHealthServicesOptions {get;set;}
        @AuraEnabled
        public Map<String, List<PicklistUtil.PicklistValue>> otherHealthServicesDependences {get;set;}
        @AuraEnabled
        public DefaultEditData defaultEditData {get;set;}
        @AuraEnabled
        public Date maxDate {get;set;}

        public FormDetails(Account patient) {
            this.accountRecord = patient;
            this.idTypeOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'ID_Type__c', false);
            this.mailingApprovalOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Mailing_approval__c', false);
            this.genderOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Gender__c', false);
            this.insurerFactorOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Insurer_factor__c', false);
            //this.otherHealthServicesOptions = PicklistUtil.buildPickListOptionsBySchema('Account', 'Other_Health_Services__c', false);
            this.otherHealthServicesDependences = PicklistUtil.buildDependedPicklistSchema('Account', 'Insurer_factor__c', 'Other_Health_Services__c');
            this.defaultEditData = new DefaultEditData(patient);
            this.maxDate = Date.today();
        }
    }

    public class DefaultEditData {
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public String idNumber {get;set;}
        @AuraEnabled
        public String idType {get;set;}
        @AuraEnabled
        public String phone {get;set;}
        @AuraEnabled
        public String gender {get;set;}
        @AuraEnabled
        public String mailingApproval {get;set;}
        @AuraEnabled
        public String insurerFactor {get;set;}
        @AuraEnabled
        public String otherHealthServices {get;set;}
        @AuraEnabled
        public Date birthDay {get;set;}

        public DefaultEditData(Account patient) {
            this.firstName = patient.FirstName != null ? patient.FirstName : '';
            this.lastName = patient.LastName != null ? patient.LastName : '';
            this.idNumber = patient.ID_Number__c != null ? patient.ID_Number__c : '';
            this.idType = patient.ID_Type__c != null ? patient.ID_Type__c : '';
            this.phone = patient.Phone != null ? patient.Phone : '';
            this.gender = patient.Gender__c != null ? patient.Gender__c : '';
            this.mailingApproval = patient.Mailing_approval__c != null ? patient.Mailing_approval__c : '';
            this.insurerFactor = patient.Insurer_factor__c != null ? patient.Insurer_factor__c : '';
            this.otherHealthServices = patient.Other_Health_Services__c != null ? patient.Other_Health_Services__c : '';
            this.birthDay = patient.PersonBirthdate != null ? patient.PersonBirthdate : null;
        }
    }
}