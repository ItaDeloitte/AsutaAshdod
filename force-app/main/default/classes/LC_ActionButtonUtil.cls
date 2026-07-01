/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Custom Buttons component Apex Util class to keep some static methods and data
 * 
 * Test                 LC_ActionButtonTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             27-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_ActionButtonUtil {

    /** ERRORS */
    public static final String ERR_UNKNOWN_ACTION = 'UNKNOWN ACTION';

    /** LABELS */
    public static final String LBL_EXPERTS = Label.ActionButton_Experts;
    public static final String LBL_SEND_OTP = Label.ActionButton_SendOTP;
    public static final String LBL_LINK_TO_CASE = Label.ActionButton_LinkToCase;
    public static final String LBL_MAKE_PAYMENT = Label.ActionButton_MakePayment;
    public static final String LBL_URGENT_UPDATE = Label.ActionButton_UrgentUpdate;
    public static final String LBL_SEND_QUESTIONNAIRE = Label.ActionButton_SendQuestionnaire;
    public static final String LBL_UPDATE_APPOINTMENT = Label.ActionButton_UpdateAppointment;
    public static final String LBL_CANCEL_APPOINTMENT = Label.ActionButton_CancelAppointment;
    public static final String LBL_CONVERT_TO_360_CASE = Label.ActionButton_ConvertTo360Case;
    public static final String LBL_TRANSFER_TO_MANAGER = Label.ActionButton_TransferToManager;
    public static final String LBL_UPDATE_DISABILITIES = Label.ActionButton_UpdateDisabilities;
    public static final String LBL_SCHEDULE_PRE_SURGERY = Label.ActionButton_SchedulePreSurgery;
    public static final String LBL_SCHEDULE_APPOINTMENT = Label.ActionButton_ScheduleAppointment;
    public static final String LBL_UPLOAD_FILES_TO_CLINIC = Label.ActionButton_UploadFilesToClinic;
    public static final String LBL_SEND_FILE_UPLOADING_LINK = Label.ActionButton_SendFileUploadingLink;
    public static final String LBL_SCHEDULE_ANALYSIS_SESSION = Label.ActionButton_ScheduleAnalysisSession;

    /** VALUES */
    public static final String CREATE_MODE = 'create';
    public static final String UPDATE_MODE = 'update';
    public static final String CANCEL_MODE = 'cancel';
    public static final String FULL_SCREEN = 'full';
    public static final String DOCTOR_HEADER_SCREEN = 'doctorHeader';
    public static final String LIMITED_PROCEDURES_SCREEN = 'limitedProcedures';
    public static final List<String> OPPORTUNITY_SKIP_STAGES = new List<String>{'Closed Lost', 'Closed Won'};
    public static final List<String> CASE_SKIP_STATUSES = new List<String>{'Closed', 'Caneclled', 'סגירת אירוע אוטומטית'};

    private static final String ZERO_OR_MORE_CHARACTERS = '%';
    private static final Integer SEARCH_LIMIT = 10;

    /** METHODS */
    public static User obtainUser() {
        return (User) getFirstElement([
            SELECT ProfileId
                 , UserRoleId
                 , Ashdod_employee__c
              FROM User
             WHERE Id = :UserInfo.getUserId()]);
    }

    public static SObject obtainRecord(String recordId) {
        String sObjectType = getSObjectType(recordId);
        List<String> fields = getFields(sObjectType);

        return obtainRecord(fields, sObjectType, recordId);
    }

    public static String getSObjectType(String recordId) {
        return String.valueOf(Id.valueOf(recordId).getSObjectType());
    }

    public static List<Appointment__c> obtainFutureAppointments(Case cas) {
        Datetime now = Datetime.now();
        String patientId = cas.AccountId;
        String profileId = wrap(UserInfo.getProfileId());
        String appointmentRT = cas.RecordType.DeveloperName == 'DOC_expert' ? 'Experts' : 'Institutes';

        String query = 'SELECT Id'
                      + ' FROM Appointment__c '
                     + ' WHERE Patient_Account__c = :patientId'
                       + ' AND Appointment_Date_Time__c > :now'
                       + ' AND Appointment_Status__c != \'Canceled\'';

        if (cas.RecordType.DeveloperName == 'Assuta_360' || cas.RecordType.DeveloperName == 'CaseAfterSale') {
            query += ' AND (RecordType.DeveloperName = \'Institutes\' OR RecordType.DeveloperName = \'Experts\')';
        } else {
            query += ' AND RecordType.DeveloperName = :appointmentRT'
                + ' AND ((Medical_Procedure__r.Profile_upd_cncl__c = null OR Medical_Procedure__r.Profile_upd_cncl__c LIKE :profileId)'
                + ' AND (Medical_Procedure__r.Domain__r.Profile_upd_cncl__c = null OR Medical_Procedure__r.Domain__r.Profile_upd_cncl__c LIKE :profileId))';
        }

        if (cas.RecordType.DeveloperName != 'DOC_expert' && cas.RecordType.DeveloperName != 'Assuta_360' && cas.RecordType.DeveloperName != 'CaseAfterSale') {
            query += ' AND Accession_Number__c != null';
        }

        return Database.query(query + ' LIMIT :SEARCH_LIMIT');
    }

    public static calendar_medp__c obtainCalendarProcedure(Appointment__c appt) {
        return (calendar_medp__c) getFirstElement([
            SELECT save_slot__c
              FROM calendar_medp__c
             WHERE Calendar__c = :appt.Calendar__c
               AND Medical_Procedure__c = :appt.Medical_Procedure__c]);
    }

    public static List<Disabilities__c> obtainDisabilities(Account acct) {
        return [SELECT Id
                  FROM Disabilities__c
                 WHERE Patient_Account__c = :acct.Id];
    }

    /** INNER METHODS */
    private static List<String> getFields(String sObjectType) {
        Set<String> fields = new Set<String>{'Id'};

        switch on sObjectType {
            when 'Account' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'ID_Type__c',
                    'ID_Number__c',
                    'Insurer_factor__c'});
            }
            when 'Appointment__c' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'Is_Urgent__c',
                    'Calendar__c',
                    'BIRAD_apt__c',
                    'Accession_Number__c',
                    'after_appointment__c',
                    'Presurgery_needed1__c',
                    'Appointment_Status__c',
                    'Appointment_Date_Time__c',
                    'Is_Hidden_Appointment__c',                    
                    'Site__r.Site_Code__c',
                    'Spincal__r.tafnitID__c',
                    'Case__r.Case_subject__c',
                    'Case__r.sub_case_subject__c',
                    'PayerFactor__r.InsuranceCode__c',
                    'Patient_Account__r.Not_active__c',
                    'Patient_Account__r.PersonBirthdate',
                    'Medical_Procedure__r.Profile_upd_cncl__c',
                    'Medical_Procedure__r.Domain__r.Profile_upd_cncl__c'});
            }
            when 'Case' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'Status',
                    'ParentId',
                    'send_OTP__c',
                    'Clinic_Email__c',
                    'Case_subject__c',
                    'Medical_Tourism__c',
                    'sub_case_subject__c',
                    'Account.ID_Number__c',
                    'Account.Not_active__c',
                    'Account.Insurer_factor__c',
                    'Account.Patient_not_entitled_for_ambulatory__c',
                    'Recommended_doc__r.Experts_center__c'});
            }
            when 'Opportunity' {
                fields.addAll(new Set<String>{
                    'AccountId',
                    'StageName',
                    'SendOTP__c',
                    'Medical_Tourism__c'});
            }
            when 'Recommendations_after_exam__c' {
                fields.addAll(new Set<String>{
                    'RecordType.DeveloperName',
                    'Status_recommendation__c'});
            }
        }

        return new List<String>(fields);
    }

    private static SObject obtainRecord(List<String> fields, String sObjectType, String recordId) {
        return Database.query(
            'SELECT ' + String.join(fields, ',')
           + ' FROM ' + sObjectType
          + ' WHERE Id = :recordId');
    }

    private static Object getFirstElement(List<Object> objs) {
        return objs.isEmpty() ? null : objs.get(0);
    }

    private static String wrap(String keyword) {
        return ZERO_OR_MORE_CHARACTERS + keyword + ZERO_OR_MORE_CHARACTERS;
    }
}