/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Case 'Link To Case' quick action Apex Service class to keep main logic
 * 
 * Test                 LC_LinkToCaseTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_LinkToCaseService {

    public class LC_LinkToCaseException extends Exception {}

    private static LC_LinkToCaseService instance;

    private Case cas;

    public static LC_LinkToCaseService getInstance(String caseId) {
        if (instance == null) {
            instance = new LC_LinkToCaseService(caseId);
        }
        return instance;
    }

    /** CONSTRUCTOR */
    private LC_LinkToCaseService(String caseId) {
        this.cas = LC_LinkToCaseUtil.obtainCase(caseId);
        System.debug('case: ' + this.cas);

        if (this.cas.AccountId == null) {
            throw new LC_LinkToCaseException(LC_LinkToCaseUtil.ERR_NO_PATIENT);
        }
    }

    /** METHODS */
    public List<CasetWrp> obtainCases() {
        List<CasetWrp> cases = new List<CasetWrp>();

        for (Case cas_i : LC_LinkToCaseUtil.obtainCases(this.cas.Id, this.cas.AccountId)) {
            cases.add(new CasetWrp(cas_i));
        }
        System.debug('cases: size: ' + cases.size() + ' value: ' + cases);

        return cases;
    }

    public void submit(String selectedCaseId) {
        Case selectedCase = LC_LinkToCaseUtil.obtainCase(selectedCaseId);
        System.debug('selectedCase: ' + selectedCase);

        this.cas.OwnerId = UserInfo.getUserId();
        this.cas.Status = 'In_Progress';
        this.cas.ParentId = selectedCase.Id;
        this.cas.AccountId = selectedCase.AccountId;
        this.cas.ActivityType__c = selectedCase.ActivityType__c;
        this.cas.Patient_Name__c = selectedCase.Patient_Name__c;
        this.cas.anonymous_case__c = selectedCase.anonymous_case__c;
        this.cas.SMS_Phone_Number__c = selectedCase.SMS_Phone_Number__c;
        this.cas.email_from_patient__c = selectedCase.email_from_patient__c;
        this.cas.Site_Public_Inquiry__c = selectedCase.Site_Public_Inquiry__c;
        this.cas.Subject_Public_Inquiry__c = selectedCase.Subject_Public_Inquiry__c;
        update this.cas;
    }

    /** WRAPPERS */
    public class CasetWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled
        public String caseNumber {get;set;}
        @AuraEnabled
        public String sitePublicInquiry {get;set;}
        @AuraEnabled
        public String subjectPublicInquiry {get;set;}
        @AuraEnabled
        public String createdDate {get;set;}

        public CasetWrp(Case cas) {
            this.id = cas.Id;
            this.status = cas.Status;
            this.subject = cas.Subject;
            this.caseNumber = cas.CaseNumber;
            this.sitePublicInquiry = cas.Site_Public_Inquiry__r.Name;
            this.subjectPublicInquiry = cas.Subject_Public_Inquiry__c;
            this.createdDate = cas.Created_date_no_time_text__c;
        }
    }
}