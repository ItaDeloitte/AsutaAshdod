/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Case 'Link To Case' quick action Apex Util class to keep some static methods and data
 * 
 * Test                 LC_LinkToCaseTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_LinkToCaseUtil {

    /** MESSAGES */
    public static final String MSG_SUCCESS = 'success';

    /** ERRORS */
    public static final String ERR_NO_PATIENT = Label.linkToCase_err_no_patient;

    /** VALUES */
    private static final String ZERO_OR_MORE_CHARACTERS = '%';
    private static final Integer SEARCH_LIMIT = 10;

    /** METHODS */
    public static Case obtainCase(String caseId) {
        return (Case) getFirstElement([
            SELECT Subject
                 , AccountId
                 , CaseNumber
                 , ActivityType__c
                 , Patient_Name__c
                 , anonymous_case__c
                 , SMS_Phone_Number__c
                 , email_from_patient__c
                 , Subject_Public_Inquiry__c
                 , Site_Public_Inquiry__r.Name
              FROM Case
             WHERE Id = :caseId]);
    }

    public static List<Case> obtainCases(String caseId, String patientId) {
        return [SELECT Status
                     , Subject
                     , CaseNumber
                     , Subject_Public_Inquiry__c
                     , Created_date_no_time_text__c
                     , Site_Public_Inquiry__r.Name
                  FROM Case
                 WHERE Id != :caseId
                   AND AccountId = :patientId
                   AND RecordType.DeveloperName = 'PublicInquiries'
              ORDER BY CreatedDate DESC];
    }

    private static Object getFirstElement(List<Object> objs) {
        return objs.isEmpty() ? null : objs.get(0);
    }
}