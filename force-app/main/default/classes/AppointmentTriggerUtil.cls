// Test: AppointmentTriggerServiceTest
public with sharing class AppointmentTriggerUtil {

    public static final Map<String, RecordTypeInfo> S_TAKER_RT_MAP = SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName();
    public static final Map<String, RecordTypeInfo> APPT_RT_MAP = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName();
    public static final Map<String, RecordTypeInfo> ACCT_RT_MAP = SObjectType.Account.getRecordTypeInfosByDeveloperName();

    public static final String INSTITUTES_RT_ID = APPT_RT_MAP.get('Institutes').getRecordTypeId();
    public static final String SURGERIES_RT_ID = APPT_RT_MAP.get('Surgeries').getRecordTypeId();
    public static final String EXPERTS_RT_ID = APPT_RT_MAP.get('Experts').getRecordTypeId();

    public static final Boolean IS_ENSEMBLE = UserInfo.getUserId() == Label.Ensemble_UserId;
    public static final Boolean IS_INTEGRATION = UserInfo.getProfileId() == Label.Integration_ProfileId;
    public static final List<String> INTERNET_KEYWORDS = Label.internetUsers.split(',');

    public static final List<String> CLINIC_EMAIL_TEMPLATES = new List<String>{
        'Assuta_Kit_Experts_4_clinic',
        'Assuta_Kit_Experts_4_clinic_upd',
        'Assuta_Kit_Experts_4_clinic_cncl'
    };

    public static final List<String> PROCEDURE_LOOKUPS = new List<String>{
        'Medical_Procedure__c',
        'Medical_Procedure2__c',
        'Medical_Procedure3__c', 
        'Medical_Procedure4__c' 
    };

    public static final List<String> PROCEDURE_RELATIONSHIPS = new List<String>{
        'Medical_Procedure__r',
        'Medical_Procedure2__r',
        'Medical_Procedure3__r',
        'Medical_Procedure4__r'
    };

    public static final Map<String, String> COST_TO_FINAL_COST_MAP = new Map<String, String>{
        'Cost_of_medical_operation1__c' => 'Final_Cost_of_Med_1__c',
        'Cost_of_medical_operation2__c' => 'Final_Cost_of_Med_2__c',
        'Cost_of_medical_operation3__c' => 'Final_Cost_of_Med_3__c',
        'Cost_of_medical_operation4__c' => 'Final_Cost_of_Med_4__c'
    };

    public static final Map<String, String> LANGUAGE_NAME_MAP = new Map<String, String>{
        '1' => 'Hebrew',
        '2' => 'English',
        '3' => 'Russian',
        '4' => 'Arabic',
        '5' => 'French'
    };

    public static final Map<String, String> LANGUAGE_CODE_MAP = new Map<String, String>{
        '1' => 'he',
        '2' => 'en',
        '3' => 'ru',
        '4' => 'ar-lb',
        '5' => 'fr'
    };

    private static Map<String, Set<String>> methodToAppointmentIdsMap = new Map<String, Set<String>>();

    public static Boolean isMethodRun(String methodName, String recordId) {
        return methodToAppointmentIdsMap.containsKey(methodName) && methodToAppointmentIdsMap.get(methodName).contains(recordId);
    }

    public static void addExecutedRecordId(String methodName, String recordId) {
        if (!methodToAppointmentIdsMap.containsKey(methodName)) {
            methodToAppointmentIdsMap.put(methodName, new Set<String>());
        }
        methodToAppointmentIdsMap.get(methodName).add(recordId);
    }   

    public static Boolean containsInternetKeyword(String notes) {
        if (String.isBlank(notes) || INTERNET_KEYWORDS.isEmpty()) {
            return false;
        }
        String lowerNotes = notes.toLowerCase();
        for (String word : INTERNET_KEYWORDS) {
            if (!String.isBlank(word) &&
                lowerNotes.contains(word.trim().toLowerCase())) {
                return true;
            }
        }
        return false;
    }
}