/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Appointment Scheduling Screen Apex Util class to keep some static methods and data
 *
 * Test                 LC_AppointmentScreenTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             28-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_AppointmentScreenUtil {

    /** ENUMS */
    public enum Page {APPT, CAS}

    /** MESSAGES */
    public static final String MSG_SUCCESS = 'success';
    public static final String MSG_ALL_TECHS = Label.All_technician;
    public static final String MSG_NO_TECH = Label.Without_a_technician;
    public static final String MSG_DOMAIN_WARNING = Label.Warning_Domain;
    public static final String MSG_DOCTOR_COST = Label.Doc_expert_cost_message;
    public static final String MSG_PREFERRED_CHANNEL_INFO = Label.Preferred_Channel_Info_Message;
    public static final String MSG_NO_PF_AGREEMENT = Label.This_payer_factor_doesnt_have_agreement_to_this_procedure;
    public static final String MSG_SUCCESSFULL_TRANSFER = Label.Successfully_transferred;
    public static final String MSG_APPOINTMENT_CANCELED = Label.Appointment_cancelled;
    public static final String MSG_ALREADY_TRANSFERED = 'The case has already been transferred earlier.';
    public static final String MSG_TWO_WEAKS_APPOINTMENT_UPDATED = 'Appointment for more than 14 days is successfully updated';
    public static final String MSG_TWO_WEAKS_APPOINTMENT_CANCELED = 'Appointment for more than 14 days is successfully cancelled';
    public static final String MSG_SCHEDULE = 'schedule';
    public static final String MSG_UPDATE = 'update';

    /** ERRORS */
    public static final String ERR_NO_PATIENT = 'Patient Account is blank.';
    public static final String ERR_NO_SITES = 'This region has no avaliable sites';
    public static final String ERR_CREATE_APPTS_PARAMS = 'Failed to obtain Patient or Payer Factor or Site from the DB.';
    public static final String ERR_FIRST_APPT_FAILED = 'First appointment failed with error: ';
    public static final String ERR_SECOND_APPT_FAILED = 'First appointment success. Second appointment failed with error: ';
    public static final String ERR_THIRD_APPT_FAILED = 'First appointment success. Second appointment success. Third appointment failed with error: ';
    public static final String ERR_ENSEMBLE = Label.Ensemble_error;
    public static final String ERR_CASE_PF = Label.Fill_payer_factor;
    public static final String ERR_NO_SLOTS = Label.No_slots_found;
    public static final String ERR_EMPTY_USER_AD = Label.User_AD_is_blank;
    public static final String ERR_NO_RESPONSE = Label.No_response_from_Ensemble;
    public static final String ERR_PATIENT_PF = Label.Fill_patient_insurer_factor;
    public static final String ERR_NO_AGREEMENT_RESPONSE = Label.No_response_from_agreement;
    public static final String ERR_DOCTOR_HAS_ANOTHER_APPT = Label.Doctor_has_another_appointment;
    public static final String ERR_PATIENT_HAS_ANOTHER_APPT = Label.Patient_has_another_appointment;
    public static final String ERR_SIGN_TRANSLATOR_NEEDED = Label.Translator_patient_7_business_days;
    public static final String ERR_NO_AGREEMENT_PARAMS = Label.There_is_no_agreement_for_the_parameters_above_and_for_private_payer_factors;

    /** LABELS */
    public static final String LBL_ALL_SITES = Label.All_sites;

    /** VALUES */
    public static final Integer TIMEOUT = 4;
    public static final Integer SEARCH_LIMIT = 10;
    public static final String RIS = 'RIS';
    public static final String QFLOW = 'QFlow';
    public static final String SHIDURIT = 'Shidurit';
    public static final String PIU_USER_AD = Label.AD_Number_for_PIU;
    public static final String FORCED_UPR_IDS = Label.Forced_slots_available_UserId_ProfileId_RoleId;
    public static final String WITHOUT_SLOTS_P_IDS= Label.ProfileId_to_see_site_without_slots;
    public static final List<String> ASHDOD_SITE_CODES = new List<String>{'33'};
    public static final List<String> DAYS = new List<String>{'SUN', 'MON', 'TUE', 'WEDE', 'THU', 'FRI', 'SAT'};
    public static final Map<String, RecordTypeInfo> APPT_RT_MAP = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName();
    public static final Map<String, RecordTypeInfo> FILE_RT_MAP = SObjectType.File__c.getRecordTypeInfosByDeveloperName();
    public static final Map<String, String> SENSITIVITY_TO_FIELD_MAP = new Map <String, String> {
        'showMetalsInBody' => 'Metals_In_Body__c',
        'showDiabetes' => 'Diabetes__c',
        'showDust' => 'Dust__c',
        'showIodineSensitivity' => 'Iodine_Sensitivity__c',
        'showBloodThinningPills' => 'Blood_Thinning_Pills__c',
        'showAsthma' => 'Asthma__c',
        'showWeight' => 'Weight__c',
        'showGender' => 'Gender__c'
    };
    public static final Map<String, Map<String, String>> ACTIONTYPE_TO_FIELDS_MAP = new Map<String, Map<String, String>> {
        'preventAppointment' => new Map<String, String> {
            'previewText' => 'Preview_Text__c'
        },
        'message' => new Map<String, String> {
            'previewText' => 'Preview_Text__c',
            'fromHour' => 'FromHour__c',
            'toHour' => 'ToHour__c'
        },
        'changeOwner' => new Map<String, String> {
            'previewText' => 'Preview_Text__c',
            'ownerForTransfer' => 'Owner_For_Transfer__c'
        },
        'changeFromDate' => new Map<String, String> {
            'previewText' => 'Preview_Text__c',
            'days' => 'From_Date__c',
            'fromHour' => 'FromHour__c',
            'toHour' => 'ToHour__c'
        },
        'scheduleByCalendar' => new Map<String, String> {
            'previewText' => 'Preview_Text__c',
            'calendar' => 'Calendar__r.ServiceId__c',
            'fromHour' => 'FromHour__c',
            'toHour' => 'ToHour__c'
        }
    };
    public static final Map<String, String> ACTIONTYPE_NAME_MAP = new Map<String, String> {
        'מניעת זימון' => 'preventAppointment',
        'הודעת אזהרה' => 'message',
        'מניעת זימון ושינוי בעלים' => 'changeOwner',
        'מתאריך' => 'changeFromDate',
        'חיפוש לפי יומן' => 'scheduleByCalendar'
    };

    private static final String LIMITED_MODE = 'limitedProcedures';
    private static final String ZERO_OR_MORE_CHARACTERS = '%';
    private static final TimeZone ISRAEL_TIMEZONE = TimeZone.getTimeZone('Asia/Tel_Aviv');

    /** METHODS */
    public static Page definePage(String recordId) {
        if (recordId == null) {
            return null;
        }

        switch on String.valueOf(Id.valueOf(recordId).getSobjectType()) {
            when 'Appointment__c' {
                return Page.APPT;
            }
            when 'Case' {
                return Page.CAS;
            }
            when else {
                return null;
            }
        }
    }

    public static Datetime getLocalDatetime(Datetime gmtDatetime) {
        return gmtDatetime.addSeconds(ISRAEL_TIMEZONE.getOffset(gmtDatetime) / 1000);
    }

    public static Datetime getGmtDatetime(Datetime localDatetime) {
        return Datetime.newInstance(localDatetime.dateGmt(), localDatetime.timeGmt());
    }

    public static Datetime getFromDatetime(Date fDate) {
        return getFromDatetime(fDate, 0);
    }

    public static Datetime getFromDatetime(Date fDate, Integer fHour) {
        return Datetime.newInstanceGmt(fDate, Time.newInstance(fHour, 0, 0, 0));
    }

    public static Datetime getToDatetime(Date tDate) {
        return getToDatetime(tDate, 23);
    }

    public static Datetime getToDatetime(Date tDate, Integer tHour) {
        return Datetime.newInstanceGmt(tDate, Time.newInstance(tHour, tHour == 23 ? 59 : 0, 0, 0));
    }

    public static Integer getTimeZoneOffset(Date fDate) {
        return Integer.valueOf(ISRAEL_TIMEZONE.getOffset(getFromDatetime(fDate)));
    }

    public static Object getValue(SObject record, String field) {
        List<String> splitedFieldList = field.split('\\.');
        SObject relatedRecord = record;
        for (Integer i = 0; i < splitedFieldList.size() - 1; i++) {
            relatedRecord = relatedRecord?.getSObject(splitedFieldList[i]);
        }
        return relatedRecord?.get(splitedFieldList[splitedFieldList.size() - 1]);
    }

    public static List<String> getExpertProcedureCodes(Case cas) {
        ExpertProcedureService sExpertProcedure = ExpertProcedureService.getInstance();
        return cas?.sub_case_subject__c == 'המלצה על רופא מומחה'
            ? cas?.Channel__c == 'פרטי' ? sExpertProcedure.getPrivateDefault() : sExpertProcedure.getPublicDefault()
            : cas?.Channel__c == 'פרטי' ? sExpertProcedure.getAllPrivate() : sExpertProcedure.getAllPublic();
    }

    public static String getEnsembleSystemName(Medical_Procedure__c procedure) {
        return (String) getEnsembleSystem(procedure, 'name');
    }

    public static Integer getEnsembleSystemCode(Medical_Procedure__c procedure) {
        return (Integer) getEnsembleSystem(procedure, 'code');
    }

    public static String getEnsembleSystemName(Appointment__c appointment) {
        return (String) getEnsembleSystem(appointment, 'name');
    }

    public static Integer getEnsembleSystemCode(Appointment__c appointment) {
        return (Integer) getEnsembleSystem(appointment, 'code');
    }

    public static String getEnsembleSystemName(Calendar__c calendar) {
        return (String) getEnsembleSystem(calendar, 'name');
    }

    public static Integer getEnsembleSystemCode(Calendar__c calendar) {
        return (Integer) getEnsembleSystem(calendar, 'code');
    }

    private static Object getEnsembleSystem(Medical_Procedure__c procedure, String returnType) {
        String systemName = procedure.ScheduleAppointmentSystem__c == null
            ? procedure.Domain__r.Appointment_Coordination_System__c
            : procedure.ScheduleAppointmentSystem__c;

        return getEnsembleSystem(systemName, returnType);
    }

    private static Object getEnsembleSystem(Appointment__c appointment, String returnType) {
        return getEnsembleSystem(appointment?.SourceSystem__c, returnType);
    }

    private static Object getEnsembleSystem(Calendar__c calendar, String returnType) {
        return getEnsembleSystem(calendar.AppointmentSys__c, returnType);
    }

    private static Object getEnsembleSystem(String systemName, String returnType) {
        switch on returnType {
            when 'name' {
                return systemName == QFLOW
                        ? QFLOW
                        : (systemName == SHIDURIT
                            ? SHIDURIT
                            : RIS);
            }
            when 'code' {
                return systemName == QFLOW
                        ? 29
                        : (systemName == SHIDURIT
                            ? 86
                            : 26);
            }
            when else {
                return null;
            }
        }
    }

    private static Object getFirstElement(List<Object> objs) {
        return objs.isEmpty() ? null : objs.get(0);
    }

    private static String append(String keyword) {
        return keyword + ZERO_OR_MORE_CHARACTERS;
    }

    private static String wrap(String keyword) {
        return ZERO_OR_MORE_CHARACTERS + keyword + ZERO_OR_MORE_CHARACTERS;
    }

    /** User */
    public static User obtainUser() {
        return [SELECT Name
                     , User_AD__c
                     , Ashdod_employee__c
                     , Profile.Name
                  FROM User
                 WHERE Id = :UserInfo.getUserId()];
    }

    /** Case (General) */
    public static Case obtainCase(String caseId) {
        return (Case) getFirstElement([
            SELECT Status
                 , OwnerId
                 , Site__c
                 , Channel__c
                 , Opportunity__c
                 , PayerFactor__c
                 , Contact_doctor__c
                 , Note_to_screen__c
                 , Recommended_doc__c
                 , sub_case_subject__c
                 , Medical_Procedure__c
                 , email_from_patient__c
                 , preferd_chanal_case__c
                 , Account.Name
                 , Account.PersonEmail
                 , RecordType.DeveloperName
                 , Account.Status__c
                 , Account.KupaId__c
                 , Account.ID_Type__c
                 , Account.ID_Number__c
                 , Account.Insurer_factor__c
                 , Account.Icon_insurgence__c
                 , Account.Sabbath_keeping__c
                 , Account.SMS_Phone_Number__c
                 , Account.Preferred_Channel__c
                 , Agreement__r.self_payment__c
                 , Agreement__r.self_payment_formula__c
                 , Agreement__r.PayerFactor__r.Name
                 , Agreement__r.PayerFactor__r.Icon__c
                 , PayerFactor__r.InsuranceCode__c
                 , Doctor_Arrangement__r.self_payment__c
                 , Doctor_Arrangement__r.self_payment_formula__c
                 , Doctor_Arrangement__r.Arrangement__r.PayerFactor__r.Name
                 , Doctor_Arrangement__r.Arrangement__r.PayerFactor__r.Icon__c
              FROM Case
             WHERE Id = :caseId]);
    }

    /** Appointment__c (General) */
    public static Appointment__c obtainAppointment(String appointmentId) {
        return (Appointment__c) getFirstElement([
            SELECT RecordType.DeveloperName
                 , Name
                 , Case__c
                 , Clinic__c
                 , Duration__c
                 , Protocol__c
                 , SourceSystem__c
                 , UrgentReason__c
                 , Doctor_Account__c
                 , Accession_Number__c
                 , after_appointment__c
                 , Appointment_Status__c
                 , Appointment_Date_Time__c
                 , Is_Hidden_Appointment__c
                 , Site__r.Name
                 , Site__r.Site_Code__c
                 , Calendar__r.Name
                 , Calendar__r.ServiceId__c
                 , Calendar__r.BranchName__r.Site_Code__c
                 , Case__r.Contact_doctor__c
                 , Case__r.Recommended_doc__c
                 , PayerFactor__r.InsuranceCode__c
                 , Patient_Account__r.Name
                 , Patient_Account__r.PersonEmail
                 , Patient_Account__r.ID_Type__c
                 , Patient_Account__r.ID_Number__c
                 , Patient_Account__r.Insurer_factor__c
                 , Patient_Account__r.Sabbath_keeping__c
                 , Medical_Procedure__r.Name
                 , Medical_Procedure__r.Waiting_List__c
                 , Medical_Procedure__r.Procedure_Code__c
                 , Medical_Procedure__r.Marketing_Procedure_Name__c
                 , Medical_Procedure__r.ScheduleAppointmentSystem__c
                 , Medical_procedure__r.Domain__r.Name
                 , Medical_procedure__r.Domain__r.DomainCode__c
                 , Medical_procedure__r.Domain__r.Appointment_Coordination_System__c
                 , after_appointment__r.after_appointment__c
              FROM Appointment__c
             WHERE Id = :appointmentId]);
    }

    /** Medical_Procedure_Plan_All__mdt */
    public static List<Medical_Procedure_Plan_All__mdt> obtainMedicalPlans(String procedureCode) {
        return [SELECT SiteCode__c
                     , ModalityCode__c
                     , ProcedureCode1__c
                     , ProcedureCode2__c
                     , ProceduresBreak__c
                     , ProcedurePlanCode__c
                  FROM Medical_Procedure_Plan_All__mdt
                 WHERE ProcedureCode1__c = :procedureCode];
    }

    /** Payer_Factor_mapping__mdt */
    public static Map<String, Payer_Factor_mapping__mdt> obtainPFMapping() {
        Map<String, Payer_Factor_mapping__mdt> pfMapping = new Map<String, Payer_Factor_mapping__mdt>();

        for (Payer_Factor_mapping__mdt mdt_i : Payer_Factor_mapping__mdt.getAll().values()) {
            pfMapping.put(mdt_i.insurerFactor__c, mdt_i);
        }

        return pfMapping;
    }

    /** Referral_Domain_mapping__mdt */
    private static List<Referral_Domain_mapping__mdt> obtainReferralTypes(String domainId) {
        return [SELECT Referral_Types__c
                  FROM Referral_Domain_mapping__mdt
                 WHERE DomainId__c = :domainId
                 LIMIT 1];
    }

    /** Warning_Domain__mdt */
    public static Map<String, String> obtainWarningDomains() {
        Map<String, String> warningDomains = new Map<String, String>();

        for (Warning_Domain__mdt mdt_i : Warning_Domain__mdt.getAll().values()) {
            warningDomains.put(mdt_i.DeveloperName, MSG_DOMAIN_WARNING);
        }

        return warningDomains;
    }

    /** Ensemble_Error_Mapping__mdt */
    public static Map<String, String> obtainEnsembleErrors(String interfaceType) {
        Map<String, String> ensembleErrorMap = new Map<String, String> ();
        for (Ensemble_Error_Mapping__mdt metadata_i : [SELECT ErrorCode__c, ErrorMessage__c FROM Ensemble_Error_Mapping__mdt WHERE InterfaceType__c =: interfaceType]) {
            ensembleErrorMap.put(metadata_i.ErrorCode__c, metadata_i.ErrorMessage__c);
        }

        return ensembleErrorMap;
    }

    /** Filter_Results_Center__mdt */
    public static Filter_Results_Center__mdt obtainFilterResultsCenter(String procedureCode) {
        return (Filter_Results_Center__mdt) getFirstElement([
            SELECT CalendarService__c
                 , MedicalProcedureCode__c
                 , PayarFactor__c
                 , SiteCode__c
              FROM Filter_Results_Center__mdt
             WHERE MedicalProcedureCode__c = :procedureCode
             LIMIT 1]);
    }

    /** Account */
    public static Account obtainAccount(String idNumber, String idType) {
        return (Account) getFirstElement([
            SELECT Phone
                 , LastName
                 , FirstName
                 , PersonBirthdate
                 , PersonOtherPhone
                 , Gender__c
                 , ID_Type__c
                 , ID_Number__c
                 , Age_Number__c
                 , Sabbath_keeping__c
              FROM Account
             WHERE ID_Number__c = :idNumber
               AND ID_Type__c = :idType
             LIMIT 1]);
    }

    /** Appointment__c */
    public static List<Appointment__c> obtainAppointments(List<String> apptIds) {
        return [SELECT Name
                     , RecordTypeId
                     , Site__c
                     , Domain__c
                     , Case_360__c
                     , Calendar__c
                     , SourceSystem__c
                     , PayerFactor__c
                     , need_approval__c
                     , Patient_Account__c
                     , Accession_Number__c
                     , Medical_Procedure__c
                     , Is_Hidden_Appointment__c
                     , Appointment_Date_Time__c
                     , Medical_Procedure_Text__c
                     , Case__r.RecordType.DeveloperName
                     , PayerFactor__r.InsuranceCode__c
                  FROM Appointment__c
                 WHERE Id IN :apptIds];
    }

    public static Appointment__c obtainHiddenAppointment(String apptId) {
        return (Appointment__c) getFirstElement([
            SELECT Name
                 , RecordTypeId
                 , Site__c
                 , Domain__c
                 , Clinic__c
                 , Duration__c
                 , Case_360__c
                 , Calendar__c
                 , PayerFactor__c
                 , SourceSystem__c
                 , need_approval__c
                 , Patient_Account__c
                 , Accession_Number__c
                 , Medical_Procedure__c
                 , Is_Hidden_Appointment__c
                 , Appointment_Date_Time__c
                 , Medical_Procedure_Text__c
                 , Site__r.Name
                 , Medical_Procedure__r.Name
                 , Site__r.Site_Code__c
                 , Calendar__r.ServiceId__c
                 , Site__r.allowed_waiting_list__c
                 , Medical_Procedure__r.Domain__c
                 , Medical_Procedure__r.Waiting_List__c
                 , Medical_Procedure__r.Procedure_Code__c
                 , Medical_Procedure__r.Marketing_Procedure_Name__c
                 , Case__r.RecordType.DeveloperName
                 , Medical_Procedure__r.Domain__r.Name
                 , PayerFactor__r.InsuranceCode__c
                 , after_appointment__r.after_appointment__c
              FROM Appointment__c
             WHERE after_appointment__c = :apptId
               AND Is_Hidden_Appointment__c = true]);
    }

    public static Appointment__c obtainNextAppointment(String apptId) {
        return (Appointment__c) getFirstElement([
            SELECT Id
              FROM Appointment__c
             WHERE after_appointment__c = :apptId
        ]);
    }

    public static List<Appointment__c> obtainCurrentAndNextAppointment(String apptId) {
        return [SELECT Id
                     , RecordTypeId
                     , Clinic__c
                     , Duration__c
                     , SourceSystem__c
                     , Accession_Number__c
                     , Is_Hidden_Appointment__c
                     , Appointment_Date_Time__c
                     , Site__r.Name
                     , Site__r.Site_Code__c
                     , Site__r.allowed_waiting_list__c
                     , Calendar__r.ServiceId__c
                     , Medical_Procedure__r.Name
                     , Medical_Procedure__r.Domain__c
                     , Medical_Procedure__r.Waiting_List__c
                     , Medical_Procedure__r.Procedure_Code__c
                     , Medical_Procedure__r.Marketing_Procedure_Name__c
                     , Medical_Procedure__r.Domain__r.Name
                     , after_appointment__r.after_appointment__c
                     , Case__r.RecordType.DeveloperName
                  FROM Appointment__c
                 WHERE (Id =: apptId AND Is_Hidden_Appointment__c = false)
                    OR (after_appointment__c =: apptId AND Is_Hidden_Appointment__c = true)];
    }

    public static List<Appointment__c> obtainAllValidAppointments(Set<Id> apptIds) {
        return [SELECT Accession_Number__c
                  FROM Appointment__c
                 WHERE Appointment_Status__c != 'WaitingForCanceled'
                   AND Appointment_Status__c != 'Canceled'
                   AND ((Id IN :apptIds AND Is_Hidden_Appointment__c = false) OR (after_appointment__r.Id IN :apptIds AND Is_Hidden_Appointment__c = true))];
    }

    public static List<Appointment__c> obtainExistingAppointments(String caseId) {
        List<Appointment__c> existingAppointments = new List<Appointment__c>();
        for (cases_and_appoitments__c jct_i : obtainCasesAppointments(caseId)) {
            existingAppointments.add(
                new Appointment__c(
                    Id = jct_i.Appointment__c,
                    Site__c = jct_i.Appointment__r.Site__c,
                    Site__r = jct_i.Appointment__r.Site__r,
                    Clinic__c = jct_i.Appointment__r.Clinic__c,
                    Calendar__c = jct_i.Appointment__r.Calendar__c,
                    Calendar__r = jct_i.Appointment__r.Calendar__r,
                    Accession_Number__c = jct_i.Appointment__r.Accession_Number__c,
                    Medical_Procedure__c = jct_i.Appointment__r.Medical_Procedure__c,
                    Medical_Procedure__r = jct_i.Appointment__r.Medical_Procedure__r,
                    Appointment_Date_Time__c = jct_i.Appointment__r.Appointment_Date_Time__c
                )
            );
            //existingAppointments.add(jct_i.Appointment__r);
        }
        return existingAppointments;
    }

    public static List<Appointment__c> obtainSequenceOfAppointments(String appointmentId) {
        List<Appointment__c> apptSequence = new List<Appointment__c>();

        String query = 'SELECT RecordType.DeveloperName'
                          + ', Clinic__c'
                          + ', Duration__c'
                          + ', SourceSystem__c'
                          + ', Accession_Number__c'
                          + ', Appointment_Date_Time__c'
                          + ', Is_Hidden_Appointment__c'
                          + ', Exact_Location_In_Domain__c'
                          + ', Case__r.RecordType.DeveloperName'
                          + ', Calendar__r.ServiceId__c'
                          + ', Site__r.Name'
                          + ', Site__r.Address__c'
                          + ', Site__r.Site_Code__c'
                          + ', Site__r.allowed_waiting_list__c'
                          + ', Medical_Procedure__r.Name'
                          + ', Medical_Procedure__r.Marketing_Procedure_Name__c'
                          + ', Medical_Procedure__r.Procedure_Code__c'
                          + ', Medical_Procedure__r.Waiting_List__c'
                          + ', Medical_Procedure__r.Domain__r.Name'
                          + ', after_appointment__r.after_appointment__c'
                          + ', Guidance_Scenario__r.Guideline1__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline1__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline2__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline2__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline3__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline3__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline4__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline4__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline5__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline5__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline6__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline6__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline7__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline7__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline8__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline8__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline9__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline9__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline10__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline10__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline11__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline11__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline12__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline12__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline13__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline13__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline14__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline14__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline15__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline15__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline16__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline16__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline17__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline17__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline18__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline18__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline19__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline19__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline20__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline20__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline21__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline21__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline22__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline22__r.Required_To_Read__c'
                          + ', Guidance_Scenario__r.Guideline23__r.Guideline_Desc__c'
                          + ', Guidance_Scenario__r.Guideline23__r.Required_To_Read__c'
                      + ' FROM Appointment__c';

        List<Appointment__c> appts = Database.query(query
            + ' WHERE Is_Hidden_Appointment__c = false'
              + ' AND (Id = :appointmentId OR after_appointment__c = :appointmentId OR after_appointment__r.after_appointment__c = :appointmentId)'
         + ' ORDER BY Appointment_Date_Time__c');

        if (!appts.isEmpty()) {
            Appointment__c appt = appts.get(0);
            if (appt.after_appointment__c == null) {
                apptSequence.addAll(appts);
            } else if (appt.after_appointment__r.after_appointment__c == null) {
                apptSequence.addAll((List<Appointment__c>) Database.query(query
                    + ' WHERE Id = \'' + appt.after_appointment__c + '\''
                 + ' ORDER BY Appointment_Date_Time__c'));
                apptSequence.addAll(appts);
            } else {
                apptSequence.addAll((List<Appointment__c>) Database.query(query
                     + ' WHERE Id = \'' + appt.after_appointment__c + '\''
                        + ' OR Id = \'' + appt.after_appointment__r.after_appointment__c + '\''
                  + ' ORDER BY Appointment_Date_Time__c'));
                apptSequence.addAll(appts);
            }
        }

        return apptSequence;
    }

    public static List<Appointment__c> obtainFutureAppointments(Boolean pIsAshdodEmloyee, String pPatientId, String pProcedureCode) {
        Datetime currentDatetime = Datetime.now();

        String query = 'SELECT Id'
                      + ' FROM Appointment__c'
                     + ' WHERE Patient_Account__c = :pPatientId'
                       + ' AND Appointment_Date_Time__c > :currentDatetime'
                       + ' AND Medical_Procedure__r.Procedure_Code__c = :pProcedureCode'
                       + ' AND Appointment_Status__c IN (\'WaitingForAppointment\', \'וידוא הגעה לפגישה\')'
                       + ' AND RecordType.DeveloperName = \'Institutes\'';

        if (pIsAshdodEmloyee) {
            query += ' AND Site_Code__c IN :ASHDOD_SITE_CODES';
        }

        return Database.query(query);
    }

    public static List<Appointment__c> obtainConnectedAppointments(String caseRT, String caseAccountId, String profileId, String keyword, Boolean isRestricted, Boolean isCaseAppButton) {
        keyword = wrap(keyword);
        profileId = wrap(profileId);
        Datetime currentDatetime = Datetime.now();
        String appointmentRT = caseRT == 'DOC_expert'
            ? 'Experts'
            : (caseRT == 'Assuta_360' || caseRT == 'CaseAfterSale')
                ? ''
                : 'Institutes';

        String query = 'SELECT Id'
                          + ', Name'
                          + ', Case__c'
                          + ', Protocol__c'
                          + ', Accession_Number__c'
                          + ', Medical_Procedure__c'
                          + ', after_appointment__c'
                          + ', Is_Hidden_Appointment__c'
                          + ', Appointment_Date_Time__c'
                          + ', Site__r.Name'
                          + ', Calendar__r.Name'
                          + ', Medical_Procedure__r.Name'
                          + ', Site__r.Site_Code__c'
                          + ', Calendar__r.ServiceId__c'
                          + ', Medical_Procedure__r.Domain__c'
                          + ', Medical_Procedure__r.Procedure_Code__c'
                          + ', Medical_Procedure__r.Profile_upd_cncl__c'
                          + ', Medical_Procedure__r.Marketing_Procedure_Name__c'
                          + ', Medical_Procedure__r.Domain__r.Name'
                          + ', Medical_Procedure__r.Domain__r.Profile_upd_cncl__c'
                      + ' FROM Appointment__c'
                     + ' WHERE Name LIKE :keyword'
                       + ' AND Appointment_Status__c != \'Canceled\''
                       + ' AND Patient_Account__c = :caseAccountId'
                       + ' AND Appointment_Date_Time__c > :currentDatetime'
                       + ' AND Is_Hidden_Appointment__c = false';

        if (!String.isBlank(appointmentRT)) {
            query += ' AND RecordType.DeveloperName =: appointmentRT';

            if (isCaseAppButton) {
                query += ' AND ((Medical_Procedure__r.Profile_upd_cncl__c = null OR Medical_Procedure__r.Profile_upd_cncl__c LIKE :profileId) AND (Medical_Procedure__r.Domain__r.Profile_upd_cncl__c = null OR Medical_Procedure__r.Domain__r.Profile_upd_cncl__c LIKE :profileId))';
            }
        } else {
            query += ' AND (RecordType.DeveloperName = \'Institutes\' OR RecordType.DeveloperName = \'Experts\')';
        }

        if (appointmentRT == 'Institutes') {
            query += ' AND Accession_Number__c != null';
        }
        query += ' ORDER BY Appointment_Date_Time__c DESC';

        if(isRestricted) {
            query += ' LIMIT 20';
        }
        return Database.query(query);
    }

    /** Calendar__c */
    public static Calendar__c obtainExcellentCalendar(String calendarIdOrCode) {
        return (Calendar__c) getFirstElement([
            SELECT Name
                 , ServiceId__c
                 , AppointmentSys__c
                 , BranchName__r.Name
                 , BranchName__r.Site_Code__c
                 , BranchName__r.US_Calendar__r.Name
                 , BranchName__r.US_Calendar__r.ServiceId__c
                 , (SELECT Medical_Procedure__r.Name
                         , Medical_Procedure__r.Waiting_List__c
                         , Medical_Procedure__r.Procedure_Code__c
                         , Medical_Procedure__r.Marketing_Procedure_Name__c
                         , Medical_Procedure__r.Domain__r.Name
                      FROM cal_med__r
                  ORDER BY Medical_Procedure__r.Procedure_Code__c)
              FROM Calendar__c
             WHERE (Id = :calendarIdOrCode OR ServiceId__c = :calendarIdOrCode)
               AND Excellent_Clinics__c = true]);
    }

    public static List<Calendar__c> obtainCalendars(List<String> calendarCodes) {
        return [SELECT ServiceId__c
                     , AppointmentSys__c
                  FROM Calendar__c
                 WHERE ServiceId__c IN :calendarCodes
                   AND AppointmentSys__c != null];
    }

    public static List<Calendar__c> obtainCalendarsForced(String procedureCode, List<String> siteCodes) {
        return [SELECT ServiceId__c
                  FROM Calendar__c
                 WHERE Id IN (SELECT Calendar__c
                                FROM calendar_medp__c
                               WHERE Medical_Procedure__r.Procedure_Code__c = :procedureCode)
                   AND BranchName__r.Site_Code__c IN :siteCodes];
    }

    public static List<Calendar__c> searchExcellentCalendars(String doctorId, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Name
                     , ServiceId__c
                  FROM Calendar__c
                 WHERE Name LIKE :keyword
                   AND Doctor__c = :doctorId
                   AND Excellent_Clinics__c = true
                 LIMIT :SEARCH_LIMIT];
    }

    public static List<Calendar__c> searchExpertCalendars(String doctorId, List<String> procedureCodes, String siteCode, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Name
                     , ServiceId__c
                     , BranchName__r.Site_Code__c
                  FROM Calendar__c
                 WHERE Id IN (SELECT Calendar__c
                                FROM calendar_medp__c
                               WHERE Medical_Procedure__r.Procedure_Code__c IN :procedureCodes
                                 AND (Medical_Procedure__r.Status__c = '1' OR Medical_Procedure__r.Status__c = null))
                   AND Name LIKE :keyword
                   AND Doctor__c = :doctorId
                   AND (BranchName__r.Site_Code__c = :siteCode OR CalenderInClinic__r.Clinic__r.Site__r.Site_Code__c = :siteCode)
                 LIMIT :SEARCH_LIMIT];
    }

    public static List<Calendar__c> searchCalendarsForced(String siteCode, String procedureCode, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Name
                     , ServiceId__c
                     , BranchName__r.Site_Code__c
                  FROM Calendar__c
                 WHERE Id IN (SELECT Calendar__c
                                FROM calendar_medp__c
                               WHERE Medical_Procedure__r.Procedure_Code__c = :procedureCode)
                   AND Name LIKE :keyword
                   AND BranchName__r.Site_Code__c = :siteCode
                 LIMIT :SEARCH_LIMIT];
    }

    public static List<Calendar__c> searchQFlowCalendars(String profileName, String siteCode, String procedureCode) {
        String query = 'SELECT Name'
                          + ', ServiceId__c'
                      + ' FROM Calendar__c'
                     + ' WHERE Id IN (SELECT Calendar__c'
                                    + ' FROM calendar_medp__c'
                                   + ' WHERE Medical_Procedure__r.Procedure_Code__c = :procedureCode'
                                     + ' AND (Medical_Procedure__r.Domain__r.Appointment_Coordination_System__c = :QFLOW OR Medical_Procedure__r.ScheduleAppointmentSystem__c = :QFLOW))'
                       + ' AND BranchName__r.Site_Code__c = :siteCode'
                       + ' AND status__c = \'פעיל\'';

        if (profileName == 'Agent') {
            query += ' AND Domain_Only__c != true';
        }

        return Database.query(query + ' LIMIT 25');
    }

    public static Calendar__c obtainExpertCalendar(String doctorId, String calendarCode) {
        return (Calendar__c) getFirstElement(obtainExpertCalendars(doctorId, new List<String> {calendarCode}));
    }

    public static List<Calendar__c> obtainExpertCalendars(String doctorId, List<String> calendarCodes) {
        return [SELECT ServiceId__c
                     , AppointmentSys__c
                  FROM Calendar__c
                 WHERE Doctor__c = :doctorId
                   AND Doctor__c != null
                   AND ServiceId__c IN :calendarCodes];
    }

    /** Calendar1__c */
    public static Integer obtainNumberOfBusinessDays(Date lastDate) {
        return [SELECT COUNT()
                  FROM Calendar1__c
                 WHERE business_day__c = true
                   AND Gregorian_Date__c >= TODAY
                   AND Gregorian_Date__c <= :lastDate];
    }

    public static List<Calendar1__c> obtainDays() {
        return [SELECT Day__c
                     , Weekend__c
                     , Holiday__c
                     , Jewish_date__c
                     , business_day__c
                     , Holiday_type__c
                     , Gregorian_Date__c
                     , Holiday_Description__c
                  FROM Calendar1__c
                 WHERE Gregorian_Date__c >= TODAY
              ORDER BY Gregorian_Date__c];
    }

    /** calendar_medp__c */
    public static List<calendar_medp__c> obtainCalendarToProcedures(String procedureCode) {
        return [SELECT Calendar__r.BranchName__c
                  FROM calendar_medp__c
                 WHERE Medical_Procedure__r.Procedure_Code__c = :procedureCode];
    }

    public static List<calendar_medp__c> obtainCalendarToProcedures(List<String> calendarCodes, List<String> procedureCodes) {
        return [SELECT Medical_Procedure__c
                     , Calendar__r.Name
                     , Medical_Procedure__r.Name
                     , Calendar__r.ServiceId__c
                     , Medical_Procedure__r.Domain__c
                     , Medical_Procedure__r.Waiting_List__c
                     , Medical_Procedure__r.Procedure_Code__c
                     , Medical_Procedure__r.Marketing_Procedure_Name__c
                     , Medical_Procedure__r.Domain__r.Name
                  FROM calendar_medp__c
                 WHERE Calendar__r.ServiceId__c IN :calendarCodes
                   AND Medical_Procedure__r.Procedure_Code__c IN :procedureCodes];
    }

    public static List<calendar_medp__c> obtainCalendarToProcedures(String doctorId, List<String> procedureCodes, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Calendar__r.BranchName__c
                  FROM calendar_medp__c
                 WHERE Calendar__r.Doctor__c = :doctorId
                   AND Calendar__r.BranchName__r.Site_Code__c LIKE :keyword
                   AND Medical_Procedure__r.Procedure_Code__c IN :procedureCodes
                   AND (Medical_Procedure__r.Status__c = '1' OR Medical_Procedure__r.Status__c = null)];
    }

    public static calendar_medp__c obtainCalendarToProcedure(String procedureId, String calendarCode) {
        return (calendar_medp__c) getFirstElement([SELECT Id
                                                        , save_slot__c
                                                     FROM calendar_medp__c
                                                    WHERE Medical_Procedure__c = :procedureId
                                                      AND Calendar__r.ServiceId__c = :calendarCode]);
    }

    public static calendar_medp__c obtainCalendarToProcedureById(String procedureId, String calendarId) {
        return (calendar_medp__c) getFirstElement([SELECT Id
                                                        , save_slot__c
                                                     FROM calendar_medp__c
                                                    WHERE Medical_Procedure__c = :procedureId
                                                      AND Calendar__c = :calendarId]);
    }

    /** Case */
    public static List<Case> obtainCases(List<String> caseIds) {
        return [SELECT Site__c
                     , next_date_for_treatment__c
                  FROM Case
                 WHERE Id IN :caseIds];
    }

    /** cases_and_appoitments__c */
    private static List<cases_and_appoitments__c> obtainCasesAppointments(String caseId) {
        return [SELECT Appointment__r.Clinic__c
                     , Appointment__r.Accession_Number__c
                     , Appointment__r.Appointment_Date_Time__c
                     , Appointment__r.Site__r.Name
                     , Appointment__r.Site__r.Site_Code__c
                     , Appointment__r.Calendar__r.Name
                     , Appointment__r.Calendar__r.ServiceId__c
                     , Appointment__r.Medical_Procedure__r.Name
                     , Appointment__r.Medical_Procedure__r.Protocols__c
                     , Appointment__r.Medical_Procedure__r.Marketing_Procedure_Name__c
                     , Appointment__r.Medical_Procedure__r.Procedure_Code__c
                     , Appointment__r.Medical_Procedure__r.Waiting_List__c
                     , Appointment__r.Medical_Procedure__r.Domain__r.Name
                  FROM cases_and_appoitments__c
                 WHERE Case__c = :caseId];
    }

    /** Clinic__c */
    public static Clinic__c obtainClinic(String clinicId) {
        return (Clinic__c) getFirstElement(obtainClinics(new List<String>{clinicId}));
    }

    public static List<Clinic__c> obtainClinics(List<String> clinicIds) {
        return [SELECT Name
                     , Site__r.Name
                     , Site__r.Site_Code__c
                     , Site__r.US_Calendar__r.Name
                     , Site__r.US_Calendar__r.ServiceId__c
                  FROM Clinic__c
                 WHERE Id IN :clinicIds];
    }

    /** Disabilities__c */
    public static List<Disabilities__c> obtainDisabilities(String accountId) {
        return [SELECT Id
                  FROM Disabilities__c
                 WHERE Patient_Account__c = :accountId
                   AND Type_of_Assist__c INCLUDES ('80')];
    }

    /** Doctor_in_Clinic__c */
    public static Doctor_in_Clinic__c obtainDocInClinic(String docInClinicId) {
        return (Doctor_in_Clinic__c) getFirstElement([
            SELECT Clinic__c
              FROM Doctor_in_Clinic__c
             WHERE Id = :docInClinicId]);
    }

    public static List<Doctor_in_Clinic__c> obtainDocInClinics(String doctorId, Set<String> siteIds) {
        return [SELECT Clinic__r.Name
                     , Clinic__r.Site__r.Site_Code__c
                  FROM Doctor_in_Clinic__c
                 WHERE Doctors__c = :doctorId
                   AND Schedule_System__c = :QFLOW
                   AND Clinic__r.Site__c IN :siteIds
                 LIMIT :SEARCH_LIMIT];
    }

    /** Domain__c */
    public static Domain__c obtainDomain(String domainId) {
        return (Domain__c) getFirstElement([
            SELECT view_calendar__c
                 , MaccabiRefferal__c
              FROM Domain__c
             WHERE Id = :domainId]);
    }

    public static Domain__c obtainDomain(Integer domainCode) {
        return (Domain__c) getFirstElement(obtainDomains(new List<Integer>{domainCode}));
    }

    public static List<Domain__c> obtainDomains(List<Integer> domainCodes) {
        return [SELECT Name
                     , DomainCode__c
                  FROM Domain__c
                 WHERE DomainCode__c IN :domainCodes
                   AND Hide_From_Appointment_Screen__c = false];
    }

    public static List<Domain__c> searchDomains(String screenMode, String keyword) {
        keyword = append(keyword);

        String query = 'SELECT Name'
                          + ', DomainCode__c'
                          + ', view_calendar__c'
                      + ' FROM Domain__c'
                     + ' WHERE Name LIKE :keyword'
                       + ' AND Hide_From_Appointment_Screen__c = false';

        if (screenMode == LIMITED_MODE) {
            query += ' AND DomainCode__c = 504';
        }

        return Database.query(query);
    }

    /** File__c */
    public static File__c obtainMandatoryFile(Appointment__c appt) {
        return obtainMandatoryFile(appt.Patient_Account__c, appt.Domain__c, appt.PayerFactor__c);
    }

    public static File__c obtainMandatoryFile(String patientId, String domainId, String pfIdOrCode) {
        List<Payer_Factor__c> pfList = [
            SELECT Code_Parent_for_Interface__c
              FROM Payer_Factor__c
             WHERE (Id = :pfIdOrCode OR InsuranceCode__c = :pfIdOrCode)
               AND Code_Parent_for_Interface__c = '3'
             LIMIT 1];

        List<Referral_Domain_mapping__mdt> mdtList = obtainReferralTypes(domainId);

        if (pfList.isEmpty() || mdtList.isEmpty()) {
            return null;
        }

        List<String> referralTypes = mdtList.get(0).Referral_Types__c.split(',');

        return (File__c) getFirstElement(obtainFiles(patientId, referralTypes, ''));
    }

    public static List<File__c> searchFiles(String patientId, String domainId, String keyword) {
        List<File__c> files = new List<File__c>();

        List<Referral_Domain_mapping__mdt> mdtList = obtainReferralTypes(domainId);

        if (mdtList.isEmpty()) {
            return files;
        }

        List<String> referralTypes = mdtList.get(0).Referral_Types__c.split(',');

        return obtainFiles(patientId, referralTypes, keyword);
    }

    private static List<File__c> obtainFiles(String patientId, List<String> referralTypes, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Name
                     , ReferralDate__c
                     , (SELECT ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks)
                  FROM File__c
                 WHERE RecordType.DeveloperName = 'Referral'
                   AND Referral_Type__c IN :referralTypes
                   AND Account__c = :patientId
                   AND Name LIKE :keyword
                   AND CreatedDate = LAST_N_DAYS:60
              ORDER BY ReferralDate__c DESC NULLS LAST, CreatedDate DESC];
    }

    /** Medical_Procedure__c */
    public static List<Medical_Procedure__c> obtainProcedures(List<String> procedureIdOrCodeList) {
        return [SELECT Name
                     , Mabar_Code__c
                     , Waiting_List__c
                     , Procedure_Code__c
                     , Marketing_Procedure_Name__c
                     , Order_Centers_For_Ashdod__c
                     , FilterResultsForCenter__c
                     , ScheduleAppointmentSystem__c
                     , Domain__r.Appointment_Coordination_System__c
                  FROM Medical_Procedure__c
                 WHERE Id IN :procedureIdOrCodeList OR Procedure_Code__c IN :procedureIdOrCodeList];
    }

    public static List<Medical_Procedure__c> searchProcedures(Boolean isAshdodEmloyee, String domainId, String screenMode, List<String> procedureCodes, List<String> nextProcedureCodesInSequence, String keyword) {
        keyword = wrap(keyword);

        String query = 'SELECT Name'
                          + ', Protocols__c'
                          + ', Waiting_List__c'
                          + ', Procedure_Code__c'
                          + ', Marketing_Procedure_Name__c'
                          + ', Domain__r.Name'
                      + ' FROM Medical_Procedure__c'
                     + ' WHERE Hide_From_Appointment_Screen__c = false'
                       + ' AND Domain__r.Hide_From_Appointment_Screen__c = false'
                       + ' AND (Status__c = \'1\' OR Status__c = null)'
                       + ' AND (Marketing_Procedure_Name__c LIKE :keyword OR Procedure_Code__c LIKE :keyword)';

        if (screenMode == LIMITED_MODE) {
            query += ' AND Domain__r.DomainCode__c = 504';
        } else if (procedureCodes.isEmpty() && domainId != null) {
            query += ' AND Domain__c = :domainId';
        }
        if (!nextProcedureCodesInSequence.isEmpty()) {
            query += ' AND Procedure_Code__c IN :nextProcedureCodesInSequence';
        }
        if (isAshdodEmloyee) {
            query += ' AND ashdod_not_relevant__c = false';
        }

        return Database.query(query);
    }

    public static List<Medical_Procedure__c> searchExpertProcedures(String calendarCode, List<String> procedureCodes, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Name
                     , Waiting_List__c
                     , Procedure_Code__c
                     , Marketing_Procedure_Name__c
                     , Domain__r.Name
                  FROM Medical_Procedure__c
                 WHERE Id IN (SELECT Medical_Procedure__c
                                FROM calendar_medp__c
                               WHERE Calendar__r.ServiceId__c = :calendarCode)
                   AND Procedure_Code__c IN :procedureCodes
                   AND Marketing_Procedure_Name__c LIKE :keyword
                   AND (Status__c = '1' OR Status__c = null)
              ORDER BY Procedure_Code__c];
    }

    public static List<String> obtainNextProcedureCodesInSequence(Boolean isAshdodEmloyee, List<String> procedureCodes) {
        Set<String> nextProcedureCodesInSequence = new Set<String>();

        if (!procedureCodes.isEmpty()) {
            String query = 'SELECT Procedure_Code_2__c'
                              + ', Procedure_Code_3__c'
                          + ' FROM Sequence__c'
                         + ' WHERE Ashdod__c = :isAshdodEmloyee'
                           + ' AND Procedure_Code_1__c = \'' + procedureCodes.get(0) + '\'';

            if (procedureCodes.size() == 1) {
                for (Sequence__c sequence_i : Database.query(query + ' AND Procedure_Code_2__c != null')) {
                    nextProcedureCodesInSequence.add(sequence_i.Procedure_Code_2__c);
                }
            } else if (procedureCodes.size() == 2) {
                for (Sequence__c sequence_i : Database.query(query + ' AND Procedure_Code_2__c = \'' + procedureCodes.get(1) + '\''
                                                                   + ' AND Procedure_Code_3__c != null')) {
                    nextProcedureCodesInSequence.add(sequence_i.Procedure_Code_3__c);
                }
            }
        }

        return new List<String>(nextProcedureCodesInSequence);
    }

    /** Medical_Procedure_in_Sites__c */
    public static List<AggregateResult> obtainAggSiteCodes(Set<String> uniqueProcedureCodes) {
        return [SELECT Site__r.Site_Code__c siteCode
                  FROM Medical_Procedure_in_Sites__c
                 WHERE Medical_Procedure__r.Procedure_Code__c IN :uniqueProcedureCodes
              GROUP BY Site__r.Site_Code__c
                HAVING COUNT(Medical_Procedure__c) = :uniqueProcedureCodes.size()];
    }

    public static Medical_Procedure_in_Sites__c obtainProcedureInSite(String siteCode, String procedureCode) {
        return (Medical_Procedure_in_Sites__c) getFirstElement(obtainProceduresInSite(new List<String> {siteCode}, new List<String> {procedureCode}));
    }

    public static List<Medical_Procedure_in_Sites__c> obtainProceduresInSite(List<String> siteCodes, List<String> procedureCodes) {
        return [SELECT Site__c
                     , Email__c
                     , Queue__c
                     , Status__c
                     , Protocols__c
                     , Payer_Factor__c
                     , Note_to_screen__c
                     , Medical_Procedure__c
                     , Stop_from_scheduling__c
                     , Transfer_to_department__c
                     , Site__r.Site_Code__c
                     , Medical_Procedure__r.Procedure_code__c
                     , Medical_Procedure__r.ScheduleAppointmentSystem__c
                  FROM Medical_Procedure_in_Sites__c
                 WHERE Site__r.Site_Code__c IN :siteCodes
                   AND Medical_Procedure__r.Procedure_code__c IN :procedureCodes];
    }

    /** MP_combinations_for_technicians__c */
    public static List<MP_combinations_for_technicians__c> obtainTechnicians(String procedureCode) {
        return [SELECT Id
                  FROM MP_combinations_for_technicians__c
                 WHERE leading_MP__r.Procedure_Code__c = :procedureCode
                    OR included_MP__r.Procedure_Code__c = :procedureCode];
    }

    public static List<MP_combinations_for_technicians__c> searchTechnicians(String procedureCode, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Calendar__r.ServiceId__c
                     , Calendar__r.technician1__r.Name
                     , Calendar__r.technician2__r.Name
                     , Calendar__r.technician3__r.Name
                     , Calendar__r.BranchName__r.Name
                     , Calendar__r.BranchName__r.Site_Code__c
                     , Calendar__r.BranchName__r.AppScreen_SiteName__c
                     , leading_MP__r.Procedure_Code__c
                     , included_MP__r.Procedure_Code__c
                  FROM MP_combinations_for_technicians__c
                 WHERE Calendar__r.BranchName__r.Site_Code__c != null
                   AND (Calendar__r.technician1__r.Name LIKE :keyword
                        OR Calendar__r.technician2__r.Name LIKE :keyword
                        OR Calendar__r.technician3__r.Name LIKE :keyword
                        OR Calendar__r.BranchName__r.AppScreen_SiteName__c LIKE :keyword
                        OR (Calendar__r.BranchName__r.AppScreen_SiteName__c = null AND Calendar__r.BranchName__r.Name LIKE :keyword))
                   AND (leading_MP__r.Procedure_Code__c = :procedureCode OR included_MP__r.Procedure_Code__c = :procedureCode)];
    }

    public static List<MP_combinations_for_technicians__c> searchTechnicianProcedures(String techId, String siteCode, String procedureCode, String keyword) {
        keyword = wrap(keyword);

        String query = 'SELECT leading_MP__r.Name' +
                            ', leading_MP__r.Marketing_Procedure_Name__c' +
                            ', leading_MP__r.Procedure_Code__c' +
                            ', leading_MP__r.Protocols__c' +
                            ', leading_MP__r.Waiting_List__c' +
                            ', leading_MP__r.Domain__r.Name' +
                            ', included_MP__r.Name' +
                            ', included_MP__r.Marketing_Procedure_Name__c' +
                            ', included_MP__r.Procedure_Code__c' +
                            ', included_MP__r.Protocols__c' +
                            ', included_MP__r.Waiting_List__c' +
                            ', included_MP__r.Domain__r.Name' +
                            ', Calendar__r.technician1__c' +
                            ', Calendar__r.technician2__c' +
                            ', Calendar__r.technician3__c' +
                            ', Calendar__r.BranchName__r.Site_Code__c' +
                        ' FROM MP_combinations_for_technicians__c' +
                       ' WHERE (leading_MP__r.Marketing_Procedure_Name__c LIKE :keyword'
                         + ' OR leading_MP__r.Procedure_Code__c LIKE :keyword'
                         + ' OR included_MP__r.Marketing_Procedure_Name__c LIKE :keyword'
                         + ' OR included_MP__r.Procedure_Code__c LIKE :keyword)' +
                         ' AND (leading_MP__r.Procedure_Code__c = :procedureCode'
                         + ' OR included_MP__r.Procedure_Code__c = :procedureCode)' +
                         ' AND Calendar__r.BranchName__r.Site_Code__c = :siteCode';

        query += techId == null && siteCode == '84'
            ? ' AND (Calendar__r.technician1__c != null OR Calendar__r.technician2__c != null OR Calendar__r.technician3__c != null)'
            : ' AND (Calendar__r.technician1__c = :techId OR Calendar__r.technician2__c = :techId OR Calendar__r.technician3__c = :techId)';

        return Database.query(query);
    }

    /** Payer_Factor__c */
    public static Payer_Factor__c obtainPF(String pfIdOrCode) {
        return (Payer_Factor__c) getFirstElement(obtainsPFs(new List<String>{pfIdOrCode}));
    }

    public static List<Payer_Factor__c> obtainsPFs(List<String> pfIdOrCodeList) {
        String query = 'SELECT Name'
                          + ', InsuranceCode__c'
                      + ' FROM Payer_Factor__c'
                     + ' WHERE PresentOnSchdeuleScreen__c = true';

        if (pfIdOrCodeList != null) {
            query += ' AND (Id IN :pfIdOrCodeList OR InsuranceCode__c IN :pfIdOrCodeList)';
        }

        return Database.query(query + ' ORDER BY Name');
    }

    /** Related_document__c */
    public static List<Related_document__c> obtainRelatedDocuments(List<String> procedureCodes, String siteName) {
        String query = 'SELECT Id'
                      + ' FROM Related_document__c'
                     + ' WHERE Active__c = true'
                       + ' AND MedicalProcedoreCode__c IN :procedureCodes';

        if (siteName != null) {
            query += ' AND Site__c INCLUDES (\'' + siteName + '\')';
        }

        return Database.query(query + ' LIMIT :SEARCH_LIMIT');
    }

    /** Scheduler_parameters__c */
    public static List<Scheduler_parameters__c> obtainSchedulerParams(Boolean isAshdodEmloyee, Decimal patientAge, String domainId, String procedureCode, String pfCode, String siteCode, String protocol) {
        String query = 'SELECT Site__c'
                          + ', Dust__c'
                          + ', Status__c'
                          + ', Weight__c'
                          + ', Gender__c'
                          + ', Domain__c'
                          + ', Asthma__c'
                          + ', ToHour__c'
                          + ', Protocol__c'
                          + ', From_Age__c'
                          + ', Diabetes__c'
                          + ', FromHour__c'
                          + ', Up_To_Age__c'
                          + ', From_Date__c'
                          + ', Action_Type__c'
                          + ', Preview_Text__c'
                          + ', Payer_Factor__c'
                          + ', Metals_In_Body__c'
                          + ', Medical_Procedure__c'
                          + ', Owner_For_Transfer__c'
                          + ', Iodine_Sensitivity__c'
                          + ', Blood_Thinning_Pills__c'
                          + ', Calendar__r.ServiceId__c'
                      + ' FROM Scheduler_parameters__c'
                     + ' WHERE Status__c = \'פעיל\''
                       + ' AND (Domain__c = null OR Domain__c = \'' + domainId + '\')'
                       + ' AND (From_Age__c = null OR From_Age__c <= ' + patientAge + ')'
                       + ' AND (Up_To_Age__c = null OR Up_To_Age__c >= ' + patientAge + ')'
                       + ' AND (Protocol__c = null OR Protocol__c INCLUDES (\'' + protocol + '\'))'
                       + ' AND (Payer_Factor__c = null OR Payer_Factor__c INCLUDES (\'' + pfCode + '\'))'
                       + ' AND (Medical_Procedure__c = null OR Medical_Procedure__r.Procedure_Code__c = \'' + procedureCode + '\' )';

        query += isAshdodEmloyee
            ? ' AND Site__c INCLUDES (\''+ siteCode + '\')'
            : siteCode.contains(',')
                ? ' AND Site__c = null'
                : ' AND (Site__c = null OR Site__c INCLUDES (\''+ siteCode + '\'))';

        return Database.query(query + ' ORDER BY Action_Type__c');
    }

    /** Sequence__c */
    public static Sequence__c obtainSequence(Boolean isAshdodEmloyee, String siteCode, List<String> procedureCodes) {
        String query = 'SELECT calendar__c'
                          + ', same_day__c'
                          + ', sec_1_to_2__c'
                          + ', sec_2_to_3__c'
                          + ', max_sec_1_to_2__c'
                          + ', max_sec_2_to_3__c'
                      + ' FROM Sequence__c'
                     + ' WHERE Ashdod__c = :isAshdodEmloyee'
                       + ' AND (Site_Codes__c INCLUDES (:siteCode) OR Site_Codes__c = null)'
                       + ' AND first_medical_procedure__r.Procedure_Code__c = \'' + procedureCodes.get(0) + '\''
                       + ' AND second_medical_procedure__r.Procedure_Code__c = \'' + procedureCodes.get(1) + '\'';

        if (procedureCodes.size() == 3) {
            query += ' AND third_medical_procedure__r.Procedure_Code__c = \'' + procedureCodes.get(2) + '\'';
        }

        return (Sequence__c) getFirstElement(Database.query(query + ' ORDER BY IsGeneral__c LIMIT 1'));
    }

    /** Site__c */
    public static Site__c obtainSite(String siteCode) {
        return (Site__c) getFirstElement(obtainSites(new List<String>{siteCode}));
    }

    public static List<Site__c> obtainSites(List<String> siteCodes) {
        return [SELECT Name
                     , Region__c
                     , Site_Code__c
                     , AppScreen_SiteName__c
                  FROM Site__c
                 WHERE Site_Code__c IN :siteCodes];
    }

    public static Map<String, Site__c> obtainSiteMap() {
        Map<String, Site__c> siteMap = new Map<String, Site__c>();

        for (Site__c site_i : [SELECT Name
                                    , Site_Code__c
                                 FROM Site__c
                                WHERE Site_Code__c != null]) {
            siteMap.put(site_i.Site_Code__c, site_i);
        }

        return siteMap;
    }

    public static List<Site__c> searchAshdodSites(String keyword) {
        keyword = wrap(keyword);

        String query = 'SELECT Name'
                          + ', Site_Code__c'
                          + ', AppScreen_SiteName__c'
                      + ' FROM Site__c'
                     + ' WHERE Site_Code__c IN :ASHDOD_SITE_CODES'
                       + ' AND Relevant_for_appointment_screen__c = true'
                       + ' AND (Site_Code__c LIKE :keyword OR AppScreen_SiteName__c LIKE :keyword OR (AppScreen_SiteName__c = null AND Name LIKE :keyword))';

        return Database.query(query);
    }

    public static List<Site__c> searchSites(List<String> siteCodes, List<String> procedureCodes, Boolean skipAshdodSites, String keyword) {
        keyword = wrap(keyword);

        String query = 'SELECT Name'
                          + ', Site_Code__c'
                          + ', AppScreen_SiteName__c'
                      + ' FROM Site__c'
                     + ' WHERE Relevant_for_appointment_screen__c = true'
                       + ' AND (Site_Code__c LIKE :keyword OR AppScreen_SiteName__c LIKE :keyword OR (AppScreen_SiteName__c = null AND Name LIKE :keyword))';

        if (skipAshdodSites) {
            query += ' AND Site_Code__c NOT IN :ASHDOD_SITE_CODES';
        }
        if (siteCodes != null) {
            query += ' AND Site_Code__c IN :siteCodes';
        }
        if (procedureCodes != null) {
            query += ' AND Id IN (SELECT Site__c FROM Medical_Procedure_in_Sites__c WHERE Medical_Procedure__r.Procedure_Code__c IN :procedureCodes)';
        }

        return Database.query(query);
    }

    public static List<Site__c> searchSitesForced(Set<String> siteIds, String keyword) {
        keyword = wrap(keyword);

        return [SELECT Name
                     , Site_Code__c
                  FROM Site__c
                 WHERE Id IN :siteIds
                   AND Relevant_for_appointment_screen__c = true
                   AND (Name LIKE :keyword OR Site_Code__c LIKE :keyword)];
    }
}