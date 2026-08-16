/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Doctor Scheduling Screen Apex Util class to keep some static methods and data
 *
 * Test                 LC_DoctorScreenTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             05-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_DoctorScreenUtil {

    /** MESSAGES */
    public static final String MSG_SUCCESS = 'success';
    public static final String MSG_RECOMMENDED = Label.Recommendations_accepted;

    /** ERRORS */
    public static final String ERR_CASE = Label.Check_case_before_doc_screen;
    public static final String ERR_CLINIC = Label.No_clinics_for_this_doctor;
    public static final String ERR_IFACTOR = Label.Fill_patient_insurer_factor;
    public static final String ERR_PFACTOR = Label.Fill_payer_factor;
    public static final String ERR_ARRANGEMENT = Label.Fill_Arrangement;

    /** LABELS */
    public static final String LBL_ALL = Label.All;

    /** VALUES */
    public static final String BY_DOCTOR = 'by doctor';
    public static final String FOR_THIS_WEEK = 'for this week';
    public static final String BY_SPECIALIZATION = 'by specialization';
    public static final Map<String, RecordTypeInfo> APPT_RT_MAP = SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName();

    private static final String ZERO_OR_MORE_CHARACTERS = '%';
    private static final Integer SEARCH_LIMIT = 10;

    /** METHODS */
    public static Case obtainCase(String caseId) {
        return (Case) getFirstElement([
            SELECT RecordType.DeveloperName
                 , Channel__c
                 , Patient__c
                 , Opportunity__c
                 , Case_subject__c
                 , Send_DocAdvisor__c
                 , sub_case_subject__c
                 , Doctor_Arrangement__c
                 , Account.Area__c
                 , Account.ID_Type__c
                 , Account.Insurer_factor__c
                 , Expertise__r.Name
                 , Agreement__r.PayerFactor__r.InsuranceCode__c
                 , PayerFactor__r.InsuranceCode__c
                 , Sub_Expertise__r.Name
                 , Sub_Expertise__r.Expertise__r.Name
                 , surgeon_doctor__r.Experts_center__c
                 , Contact_doctor__r.Experts_center__c
                 , Recommended_doc__r.Experts_center__c
                 , Medical_Procedure__r.Name
                 , Medical_Procedure__r.Procedure_Code__c
                 , Medical_Procedure__r.Marketing_Procedure_Name__c
                 , Medical_Procedure__r.Sub_Expertise__r.Name
                 , Medical_Procedure__r.Sub_Expertise__r.Expertise__r.Name
              FROM Case
             WHERE Id = :caseId]);
    }

    public static String wrap(String keyword) {
        return ZERO_OR_MORE_CHARACTERS + keyword + ZERO_OR_MORE_CHARACTERS;
    }

    private static Object getFirstElement(List<Object> objs) {
        return objs.isEmpty() ? null : objs.get(0);
    }

    public static String prettifyTime(Datetime dt) {
        return dt.format('תור קרוב: dd/MM/yyyy בשעה HH:mm');
    }

    /** Expertise__c */
    public static Expertise__c obtainExpertise(String expertiseId) {
        return (Expertise__c) getFirstElement([
            SELECT Expertise_Code__c
              FROM Expertise__c
             WHERE Id = :expertiseId]);
    }

    public static List<Expertise__c> obtainExpertises(String keyword) {
        keyword = wrap(keyword);

        return [SELECT Name
                  FROM Expertise__c
                 WHERE Status__c = '1'
                   AND Show_on_website__c = true
                   AND Name LIKE :keyword
                 LIMIT :SEARCH_LIMIT];
    }

    /** Sub_Expertise__c */
    public static Sub_Expertise__c obtainSubExpertise(String subExpertiseId) {
        return (Sub_Expertise__c) getFirstElement([
            SELECT Sub_expertise_code__c
              FROM Sub_Expertise__c
             WHERE Id = :subExpertiseId]);
    }

    public static List<Sub_Expertise__c> obtainSubExpertises(String expertiseId, String keyword) {
        keyword = wrap(keyword);

        String query = 'SELECT Name'
                          + ', Expertise__r.Name'
                      + ' FROM Sub_Expertise__c'
                     + ' WHERE Name LIKE :keyword'
                       + ' AND Status__c = \'1\'';

        if (expertiseId != null) {
            query += ' AND Expertise__c = :expertiseId';
        }

        return Database.query(query + ' ORDER BY LastViewedDate DESC LIMIT :SEARCH_LIMIT');
    }

    /** settlement__c */
    public static List<AggregateResult> obtainARSettlements() {
        return [SELECT Area__c
                  FROM settlement__c
                 WHERE Area__c != null
              GROUP BY Area__c
              ORDER BY Area__c];
    }

    /** Payer_Factor__c */
    public static List<Payer_Factor__c> obtainPFs() {
        return [SELECT Name
                     , InsuranceCode__c
                  FROM Payer_Factor__c
                 WHERE InsuranceCode__c != null];
    }

    /** Arrangements__c */
    public static List<Arrangements__c> obtainArrangements(Boolean isPrivate) {
        return [SELECT Name
                  FROM Arrangements__c
                 WHERE PrivateArrangement__c = :isPrivate
              ORDER BY PayerFactor__r.InsuranceCode__c NULLS LAST];
    }

    /** Doctor_arrangement__c */
    public static Doctor_arrangement__c obtainDoctorArrangement(String doctorId, String arrangementIdOrPFCode) {
        return (Doctor_arrangement__c) getFirstElement([
            SELECT Arrangement__r.PayerFactor__r.InsuranceCode__c
              FROM Doctor_arrangement__c
             WHERE Doctor__c = :doctorId
               AND (Arrangement__c = :arrangementIdOrPFCode OR Arrangement__r.PayerFactor__r.InsuranceCode__c = :arrangementIdOrPFCode)
             LIMIT 1]);
    }

    public static List<Doctor_arrangement__c> obtainDoctorArrangements(Set<String> doctorIds, List<String> arrangements) {
        String query = 'SELECT Doctor__c'
                          + ', self_payment__c'
                          + ', SurgeryArrangement__c'
                          + ', StatusTafnitIsActiveSurg__c'
                          + ', Arrangement__r.Name'
                          + ', Arrangement__r.PayerFactor__r.InsuranceCode__c'
                      + ' FROM Doctor_arrangement__c'
                     + ' WHERE Id != null';

        if (doctorIds != null) {
            query += ' AND Doctor__c IN :doctorIds';
        }
        if (arrangements != null) {
            query += ' AND Arrangement__c IN :arrangements';
        }

        return Database.query(query);
    }

    /** doctor_rank__c */
    public static List<doctor_rank__c> obtainDoctorRanks(Set<String> doctorIds) {
        return [SELECT doctor__c
                     , rank_value__c
                  FROM doctor_rank__c
                 WHERE Doctor__c IN :doctorIds
                   AND rank_type__c = 'כללי'];
    }

    /** Doctor_in_site__c */
    public static List<Doctor_in_site__c> obtainDoctorSites(Set<String> doctorIds) {
        return [SELECT Account__c
                     , Site__r.Name
                     , Site__r.Site_Code__c
                  FROM Doctor_in_site__c
                 WHERE Account__c IN :doctorIds];
    }

    /** Doctor_in_Clinic__c */
    public static Doctor_in_Clinic__c obtainDoctorClinic(String docClinicId) {
        return (Doctor_in_Clinic__c) getFirstElement(obtainDoctorClinics(docClinicId, null));
    }

    public static List<Doctor_in_Clinic__c> obtainDoctorClinics(String doctorId) {
        return obtainDoctorClinics(null, doctorId);
    }

    private static List<Doctor_in_Clinic__c> obtainDoctorClinics(String docClinicId, String doctorId) {
        String query = 'SELECT Phone__c'
                          + ', Doctors__c'
                          + ', Working_Hours__c'
                          + ', Schedule_System__c'
                          + ', PayerFactorMulti__c'
                          + ', Clinic__r.Name'
                          + ', Clinic__r.Area__c'
                          + ', Clinic__r.Address__c'
                          + ', Clinic__r.street_address__c'
                          + ', Clinic__r.Site__r.Name'
                          + ', Clinic__r.Site__r.Site_Code__c'
                      + ' FROM Doctor_in_Clinic__c';

        if (docClinicId != null) {
            query += ' WHERE Id = :docClinicId';
        } else if (doctorId != null) {
            query += ' WHERE Doctors__c = :doctorId';
        }

        return Database.query(query);
    }

    /** Doctor_Medical_Procedure__c */
    public static List<Doctor_Medical_Procedure__c> obtainDoctorProcedures(Set<String> doctorIds, String procedureId) {
        String query = 'SELECT Doctor__c'
                      + ' FROM Doctor_Medical_Procedure__c'
                     + ' WHERE Medical_Procedure__c = :procedureId';

        if (!doctorIds.isEmpty()) {
            query += ' AND Doctor__c IN :doctorIds';
        }

        return Database.query(query);
    }

    /** Calendar__c */
    public static Calendar__c obtainExcellentCalendar(String calendarId) {
        return (Calendar__c) getFirstElement(obtainExcellentCalendars(calendarId, null));
    }

    public static List<Calendar__c> obtainExcellentCalendars(String doctorId) {
        return obtainExcellentCalendars(null, doctorId);
    }

    private static List<Calendar__c> obtainExcellentCalendars(String calendarId, String doctorId) {
        String query = 'SELECT Name'
                          + ', Doctor__c'
                          + ', AppointmentSys__c'
                          + ', BranchName__r.Name'
                          + ', BranchName__r.Site_Code__c'
                      + ' FROM Calendar__c'
                     + ' WHERE Excellent_Clinics__c = true';

        if (calendarId != null) {
            query += ' AND Id = :calendarId';
        } else if (doctorId != null) {
            query += ' AND Doctor__c = :doctorId';
        }

        return Database.query(query);
    }

    /** calendar_medp__c */
    public static List<calendar_medp__c> obtainCalendarProcedures(String doctorId, Set<String> siteIds, List<String> procedureCodes) {
        return [SELECT Calendar__r.BranchName__c
                     , Calendar__r.CalenderInClinic__r.Clinic__r.Site__c
                  FROM calendar_medp__c
                 WHERE Calendar__r.Doctor__c = :doctorId
                   AND (Calendar__r.BranchName__c IN :siteIds
                            OR Calendar__r.CalenderInClinic__r.Clinic__r.Site__c IN :siteIds)
                   AND Medical_Procedure__r.Procedure_Code__c IN :procedureCodes
                   AND (Medical_Procedure__r.Status__c = null OR Medical_Procedure__r.Status__c = '1')];
    }

    public static List<calendar_medp__c> obtainExcellentCalendarProcedures(String procedureId) {
        return [SELECT Calendar__r.Doctor__c
                  FROM calendar_medp__c
                 WHERE Medical_Procedure__c = :procedureId
                   AND Calendar__r.Excellent_Clinics__c = true];
    }

    public static List<String> obtainExcellentProcedureCodes() {
        List<String> procedureCodes = new List<String>();

        for (AggregateResult ar_i : [SELECT Medical_Procedure__r.Procedure_Code__c procedureCode
                                       FROM calendar_medp__c
                                      WHERE Calendar__r.Excellent_Clinics__c = true
                                   GROUP BY Medical_Procedure__r.Procedure_Code__c]) {
            procedureCodes.add((String) ar_i.get('procedureCode'));
        }

        return procedureCodes;
    }

    /** Medical_Procedure__c */
    public static Medical_Procedure__c obtainProcedure(String procedureIdOrCode) {
        /** single first procedure by id or code */
        return (Medical_Procedure__c) getFirstElement(obtainProcedures(new Set<String>{procedureIdOrCode}));
    }

    public static Medical_Procedure__c obtainProcedure(List<String> procedureIdsOrCodes) {
        /** single first procedure by list of ids or codes */
        return (Medical_Procedure__c) getFirstElement(obtainProcedures(new Set<String>(procedureIdsOrCodes)));
    }

    public static Medical_Procedure__c obtainProcedure(Set<String> procedureIdsOrCodes) {
        /** single first procedure by set of ids or codes */
        return (Medical_Procedure__c) getFirstElement(obtainProcedures(procedureIdsOrCodes));
    }

    public static List<Medical_Procedure__c> obtainProcedures(List<String> procedureIdsOrCodes) {
        /** procedures by list of ids or codes */
        return obtainProcedures(new Set<String>(procedureIdsOrCodes));
    }

    public static List<Medical_Procedure__c> obtainProcedures(Set<String> procedureIdsOrCodes) {
        /** procedures by set of ids or codes */
        String query = 'SELECT Name'
                          + ', Procedure_Code__c'
                          + ', Marketing_Procedure_Name__c'
                          + ', Sub_Expertise__r.Name'
                          + ', Sub_Expertise__r.Expertise__r.Name'
                      + ' FROM Medical_Procedure__c ';

        if (procedureIdsOrCodes != null) {
            query += ' WHERE (Id IN :procedureIdsOrCodes OR Procedure_Code__c IN :procedureIdsOrCodes)';
        }

        return Database.query(query);
    }

    public static List<Medical_Procedure__c> obtainProcedures(List<String> procedureCodes, String subExpertiseId, String keyword) {
        keyword = wrap(keyword);

        String query = 'SELECT Name'
                          + ', Procedure_Code__c'
                          + ', Marketing_Procedure_Name__c'
                          + ', Sub_Expertise__r.Name'
                          + ', Sub_Expertise__r.Expertise__r.Name'
                      + ' FROM Medical_Procedure__c'
                     + ' WHERE (Marketing_Procedure_Name__c LIKE :keyword OR Procedure_Code__c LIKE :keyword)'
                       + ' AND (Status__c = \'1\' OR Status__c = null)'
                       + ' AND Procedure_Code__c IN :procedureCodes';

        if (subExpertiseId != null) {
            query += ' AND Sub_Expertise__c = :subExpertiseId';
        }

        return Database.query(query + ' LIMIT :SEARCH_LIMIT');
    }

    /** Case_Recommended_Doctor__c */
    public static List<Case_Recommended_Doctor__c> obtainRecommendations(String caseId) {
        return [SELECT Doctor__c
                  FROM Case_Recommended_Doctor__c
                 WHERE Case__c = :caseId];
    }

    /** Account */
    public static List<Account> obtainDoctors(Set<String> doctorIds, String doctorName, String procedureId, String subExpertiseId, String settlementCondition, Boolean onlyRecommended, Boolean skipArrangement, Boolean skipSettlement) {
        String query = 'SELECT Name'
                          + ', Gender__c'
                          + ', districts__c'
                          + ', Picture_URL__c'
                          + ', Doctor_Code__c'
                          + ', doctor_degree__c'
                          + ', Experts_center__c'
                          + ', Insurer_factor__c'
                          + ', All_medical_procedures_ids__c'
                          + ', Counting_Promoted_doctor_values__c'
                          + ', Expertise_1__r.Name'
                          + ', Expertise_2__r.Name'
                          + ', (SELECT Id FROM Calendars__r WHERE Excellent_Clinics__c = true)'
                      + ' FROM Account'
                     + ' WHERE RecordType.DeveloperName = \'Doctor_Account\''
                       + ' AND Status__c = \'פ\'';

        if (onlyRecommended || !skipArrangement || procedureId != null) {
            query += ' AND Id IN :doctorIds';
        }

        if (String.isNotBlank(doctorName)) {
            doctorName = wrap(doctorName);
            query += ' AND Name LIKE :doctorName';
        }

        if (!onlyRecommended && !skipSettlement) {
            query += ' AND ' + settlementCondition;
        }

        if (!onlyRecommended && procedureId == null && subExpertiseId != null) {
            query += ' AND Id IN (SELECT Account__c FROM Doctor_Sub_Expertise__c WHERE SubExpertise__c = :subExpertiseId AND Status__c = \'פעיל\')';
            // query += ' AND Sub_Expertise__c = :subExpertiseId';
        }

        return Database.query(query + ' ORDER BY Counting_Promoted_doctor_values__c DESC');
    }

    public static List<Account> obtainDoctors(Set<String> doctorIds) {
        return [SELECT Doctor_Code__c
                  FROM Account
                 WHERE Id IN :doctorIds];
    }

    /** Doctors_Statistics__c */
    public static List<Doctors_Statistics__c> obtainDoctorStatistics(Set<String> doctorIds, String procedureId, String expertiseId) {
        Datetime searchDate = Datetime.now().addMonths(-6);

        String query = 'SELECT Total__c'
                          + ', Doctor_Account__c'
                          + ', Medical_Procedure__r.Sub_Expertise__c'
                          + ', Medical_Procedure__r.Marketing_Procedure_Name__c'
                      + ' FROM Doctors_Statistics__c'
                     + ' WHERE Doctor_Account__c IN :doctorIds'
                       + ' AND CreatedDate > :searchDate'
                       + ' AND Total__c != null';

        if (procedureId != null) {
            query += ' AND Medical_Procedure__c = :procedureId';
        } else {
            query += ' AND Medical_Procedure__r.Sub_Expertise__r.Expertise__c = :expertiseId';
        }

        return Database.query(query + ' ORDER BY Total__c DESC');
    }
}