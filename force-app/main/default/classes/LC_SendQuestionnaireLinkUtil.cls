/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Appointment 'Send Questionnaire Link' button Apex Util class to keep some static methods and data
 * 
 * Test                 LC_SendQuestionnaireLinkTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             13-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_SendQuestionnaireLinkUtil {

    /** MESSAGES */
    public static final String MSG_SUCCESS = 'success';

    /** ERRORS */
    public static final String ERR_PHONE = 'חסר טלפון נייד לשליחת מסרונים בפניית המקור של הפגישה';

    /** VALUES */
    private static final String ZERO_OR_MORE_CHARACTERS = '%';
    private static final Integer SEARCH_LIMIT = 10;

    /** METHODS */
    public static Appointment__c obtainAppointment(String appointmentId) {
        return (Appointment__c) getFirstElement([
            SELECT Case__r.SMS_Phone_Number__c
                 , (SELECT Name
                         , IsLocked__c
                         , Survey_link__c
                         , Fill_Percentage__c
                         , Survey__r.Name
                      FROM Surveys_Taken_Appointment__r)
              FROM Appointment__c
             WHERE Id = :appointmentId]);
    }

    private static Object getFirstElement(List<Object> objs) {
        return objs.isEmpty() ? null : objs.get(0);
    }
}