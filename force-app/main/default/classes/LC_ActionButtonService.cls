/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Custom Buttons component Apex Service class to keep main logic
 * 
 * Test                 LC_ActionButtonTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             27-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_ActionButtonService {

    public class LC_ActionButtonException extends Exception {}

    private static LC_ActionButtonService instance;

    private User user;
    private SObject record;

    public static LC_ActionButtonService getInstance(String recordId) {
        if (instance == null) {
            instance = new LC_ActionButtonService(recordId);
        }
        return instance;
    }

    /** CONSTRUCTOR */
    private LC_ActionButtonService(String recordId) {
        this.user = LC_ActionButtonUtil.obtainUser();
        System.debug('user: ' + this.user);
        this.record = LC_ActionButtonUtil.obtainRecord(recordId);
        System.debug('record: ' + this.record);
    }

    /** METHODS */
    public RecordWrp obtainButtons() {
        List<ButtonWrp> buttons = new List<ButtonWrp>();

        switch on LC_ActionButtonUtil.getSObjectType(this.record.Id) {
            when 'Account' {
                buttons = this.obtainButtons((Account) this.record);
            }
            when 'Case' {
                buttons = this.obtainButtons((Case) this.record);
            }
            when 'Opportunity' {
                buttons = this.obtainButtons((Opportunity) this.record);
            }
            when 'Appointment__c' {
                buttons = this.obtainButtons((Appointment__c) this.record);
            }
            when 'Recommendations_after_exam__c' {
                buttons = this.obtainButtons((Recommendations_after_exam__c) this.record);
            }
        }
        System.debug('buttons: size: ' + buttons.size() + ' value: ' + buttons);

        return new RecordWrp(this.record, buttons);
    }

    /** Account */
    private List<ButtonWrp> obtainButtons(Account acct) {
        List<ButtonWrp> buttons = new List<ButtonWrp>();

        switch on acct.RecordType.DeveloperName {
            when 'PersonAccount' {
                buttons.add(new ButtonWrp('checkAccountFutureAppointmentButton'));

                if (this.isProfileMaccabi()
                        && acct.ID_Number__c != null
                        && acct.Insurer_factor__c == '2') {
                    buttons.add(new ButtonWrp('portalMaccabiButton'));
                }
            }
        }

        return buttons;
    }

    /** Case */
    private List<ButtonWrp> obtainButtons(Case cas) {
        List<ButtonWrp> buttons = new List<ButtonWrp>();

        switch on cas.RecordType.DeveloperName {
            when 'Appointments' {
                if (!this.isCaseClosed(cas)) {
                    if (this.isPatientActive(cas.Account)
                            && (this.isPatientEntitledToAmbulator(cas.Account) || !this.isAshdodEmployee())
                            && (cas.sub_case_subject__c == 'זימון תור חדש' || cas.sub_case_subject__c == 'זימון תור חדש - פרסונל')
                            && (cas.Case_subject__c.contains('קמפיין') || cas.Case_subject__c == 'זימון תור חדש' || cas.Case_subject__c == 'זימון תור חדש - קורונה')) {
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }

                    if (this.hasFutureAppointments(cas)) {
                        if (this.isPatientActive(cas.Account)) {
                            buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_UPDATE_APPOINTMENT, LC_ActionButtonUtil.UPDATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                        }
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_CANCEL_APPOINTMENT, LC_ActionButtonUtil.CANCEL_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }

                    if (!cas.send_OTP__c) {
                        buttons.add(new ButtonWrp('sendOTPMethod', LC_ActionButtonUtil.LBL_SEND_OTP));
                    }

                    buttons.add(new ButtonWrp('transferToManagerMethod', LC_ActionButtonUtil.LBL_TRANSFER_TO_MANAGER));

                    if (this.isProfileMaccabi()
                            && cas.Account.ID_Number__c != null
                            && cas.Account.Insurer_factor__c == '2') {
                        buttons.add(new ButtonWrp('portalMaccabiButton'));
                    }

                    if (this.hasFutureAppointments(cas)
                            && this.hasDisabilities(cas.Account)) {
                        buttons.add(new ButtonWrp('AppointmentDisabilitiesModal', LC_ActionButtonUtil.LBL_UPDATE_DISABILITIES));
                    }
                }
            }
            when 'Assuta_360' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('transferToManagerMethod', LC_ActionButtonUtil.LBL_TRANSFER_TO_MANAGER));

                    if (this.isPatientActive(cas.Account)) {
                        buttons.add(new ButtonWrp('DocExpertShowButton', LC_ActionButtonUtil.LBL_EXPERTS, LC_ActionButtonUtil.CREATE_MODE));
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }

                    if (this.hasFutureAppointments(cas)) {
                        if (this.isPatientActive(cas.Account)) {
                            buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_UPDATE_APPOINTMENT, LC_ActionButtonUtil.UPDATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                        }
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_CANCEL_APPOINTMENT, LC_ActionButtonUtil.CANCEL_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }

                    if (!cas.send_OTP__c) {
                        buttons.add(new ButtonWrp('sendOTPMethod', LC_ActionButtonUtil.LBL_SEND_OTP));
                    }
                    if (this.hasFutureAppointments(cas)
                            && this.hasDisabilities(cas.Account)) {
                        buttons.add(new ButtonWrp('AppointmentDisabilitiesModal', LC_ActionButtonUtil.LBL_UPDATE_DISABILITIES));
                    }
                }
            }
            when 'YadBeYad_Breast' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    if (this.isPatientActive(cas.Account)) {
                        buttons.add(new ButtonWrp('DocExpertShowButton', LC_ActionButtonUtil.LBL_EXPERTS, LC_ActionButtonUtil.CREATE_MODE));
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }

                    if (this.hasFutureAppointments(cas)) {
                        if (this.isPatientActive(cas.Account)) {
                            buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_UPDATE_APPOINTMENT, LC_ActionButtonUtil.UPDATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                        }
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_CANCEL_APPOINTMENT, LC_ActionButtonUtil.CANCEL_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }
                }
            }
            when 'CaseAfterSale' {
                if (!cas.Medical_Tourism__c) {
                    buttons.add(new ButtonWrp('sendLinkForReferral'));
                }

                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('AutoCreateAppointmentButton', LC_ActionButtonUtil.LBL_SCHEDULE_ANALYSIS_SESSION));

                    if (this.isPatientActive(cas.Account) && !cas.Medical_Tourism__c) {
                        buttons.add(new ButtonWrp('DocExpertShowButton', LC_ActionButtonUtil.LBL_EXPERTS, LC_ActionButtonUtil.CREATE_MODE));
                    }

                    if (this.isPatientActive(cas.Account)) {
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }

                    if (this.hasFutureAppointments(cas)) {
                        if (this.isPatientActive(cas.Account)) {
                            buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_UPDATE_APPOINTMENT, LC_ActionButtonUtil.UPDATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                        }
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_CANCEL_APPOINTMENT, LC_ActionButtonUtil.CANCEL_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }
                }
            }
            when 'DOC_expert' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('transferToManagerMethod', LC_ActionButtonUtil.LBL_TRANSFER_TO_MANAGER));

                    if (this.isPatientActive(cas.Account)
                            && cas.Case_subject__c == 'זימון רופא מומחה'
                            && (cas.sub_case_subject__c == 'המלצה על רופא מומחה' || cas.sub_case_subject__c == 'זימון תור לאחר המלצה' || (cas.sub_case_subject__c == 'זימון תור לרופא מומחה' && cas.Recommended_doc__c != null))) {
                        buttons.add(new ButtonWrp('DocExpertShowButton', LC_ActionButtonUtil.LBL_EXPERTS, LC_ActionButtonUtil.CREATE_MODE));
                    } else if (this.isPatientActive(cas.Account)
                            && this.hasFutureAppointments(cas)
                            && cas.Case_subject__c == 'עדכון תור לרופא'
                            && cas.sub_case_subject__c == 'שינוי מועד התור') {
                        buttons.add(new ButtonWrp('DocExpertShowButton', LC_ActionButtonUtil.LBL_UPDATE_APPOINTMENT, LC_ActionButtonUtil.UPDATE_MODE));
                    } else if (this.hasFutureAppointments(cas)
                            && cas.Case_subject__c == 'עדכון תור לרופא'
                            && cas.sub_case_subject__c == 'ביטול תור קיים') {
                        buttons.add(new ButtonWrp('DocExpertShowButton', LC_ActionButtonUtil.LBL_CANCEL_APPOINTMENT, LC_ActionButtonUtil.CANCEL_MODE));
                    }

                    if (cas.Clinic_Email__c != null
                            && cas.Recommended_doc__c != null
                            && cas.Recommended_doc__r.Experts_center__c) {
                        buttons.add(new ButtonWrp('uploadFilesToClinicMethod', LC_ActionButtonUtil.LBL_UPLOAD_FILES_TO_CLINIC));
                    }

                    if (cas.Case_subject__c == 'עדכון תור קיים' || cas.Case_subject__c == 'עדכון תור לרופא') {
                        buttons.add(new ButtonWrp('AppointmentDisabilitiesModal', LC_ActionButtonUtil.LBL_UPDATE_DISABILITIES));
                    }

                    if (!cas.send_OTP__c) {
                        buttons.add(new ButtonWrp('sendOTPMethod', LC_ActionButtonUtil.LBL_SEND_OTP));
                    }
                }
            }
            when 'General_Info' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    if (cas.ParentId == null && cas.Case_subject__c == 'Yad_Beyad_Candidate') {
                        buttons.add(new ButtonWrp('convertMethod', LC_ActionButtonUtil.LBL_CONVERT_TO_360_CASE));
                    }
                }
            }
            when 'Home_diagnosis' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    if (this.isPatientActive(cas.Account)) {
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }
                }
            }
            when 'Home_Hospitalization' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                }
            }
            when 'IVF_Freezing_Eggs' {
                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('ivfCaseModal', LC_ActionButtonUtil.LBL_SEND_FILE_UPLOADING_LINK));
                }
            }
            when 'PublicInquiries' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('linkToCaseAction', LC_ActionButtonUtil.LBL_LINK_TO_CASE));

                    if (!cas.send_OTP__c) {
                        buttons.add(new ButtonWrp('sendOTPMethod', LC_ActionButtonUtil.LBL_SEND_OTP));
                    }
                }
            }
            when 'Shikum_Bait' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                }
            }
            when 'Surgery' {
                buttons.add(new ButtonWrp('sendLinkForReferral'));

                if (!this.isCaseClosed(cas)) {
                    buttons.add(new ButtonWrp('transferToManagerMethod', LC_ActionButtonUtil.LBL_TRANSFER_TO_MANAGER));
                    buttons.add(new ButtonWrp('AutoCreateAppointmentButton', LC_ActionButtonUtil.LBL_SCHEDULE_ANALYSIS_SESSION));

                    if (!cas.send_OTP__c) {
                        buttons.add(new ButtonWrp('sendOTPMethod', LC_ActionButtonUtil.LBL_SEND_OTP));
                    }
                }
            }
            when else {
                buttons.add(new ButtonWrp('sendLinkForReferral'));
            }
        }

        return buttons;
    }

    /** Opportunity */
    private List<ButtonWrp> obtainButtons(Opportunity oppt) {
        List<ButtonWrp> buttons = new List<ButtonWrp>();

        if (!LC_ActionButtonUtil.OPPORTUNITY_SKIP_STAGES.contains(oppt.StageName) && !oppt.Medical_Tourism__c) {
            buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_APPOINTMENT, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));

            if (oppt.AccountId != null) {
                buttons.add(new ButtonWrp('checkAccountFutureAppointmentButton'));
            }
        }

        if (!oppt.SendOTP__c) {
            buttons.add(new ButtonWrp('sendOTPMethod', LC_ActionButtonUtil.LBL_SEND_OTP));
        }

        return buttons;
    }

    /** Appointment__c */
    private List<ButtonWrp> obtainButtons(Appointment__c appt) {
        List<ButtonWrp> buttons = new List<ButtonWrp>{
            new ButtonWrp('getPricesFromAppointment'),
            new ButtonWrp('getAmbulatoryCommitment'),
            new ButtonWrp('urgentAppointmentButton'),
            new ButtonWrp('createReferralManually'),
            new ButtonWrp('hithaivuyotMaccabi')};

        switch on appt.RecordType.DeveloperName {
            when 'Experts' {
                if (appt.Appointment_Date_Time__c > System.now()
                        && (appt.Appointment_Status__c == 'WaitingForAppointment' || appt.Appointment_Status__c == 'וידוא הגעה לפגישה')
                        && (appt.Medical_procedure__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Profile_upd_cncl__c.contains(this.user.ProfileId))
                        && (appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c.contains(this.user.ProfileId))) {
                    if (this.isPatientActive(appt.Patient_Account__r)) {
                        buttons.add(new ButtonWrp('UpdateAppointmentButton', LC_ActionButtonUtil.LBL_UPDATE_APPOINTMENT, LC_ActionButtonUtil.UPDATE_MODE, LC_ActionButtonUtil.DOCTOR_HEADER_SCREEN));
                    }
                    buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_CANCEL_APPOINTMENT, LC_ActionButtonUtil.CANCEL_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                }

                if (this.isValidForPayment(appt)) {
                    buttons.add(new ButtonWrp('paymentValidationModal', LC_ActionButtonUtil.LBL_MAKE_PAYMENT));
                }
            }
            when 'Institutes' {
                if (appt.Accession_Number__c != null
                        && appt.after_appointment__c == null
                        && appt.Appointment_Date_Time__c > System.now()
                        && (appt.Appointment_Status__c == 'WaitingForAppointment' || appt.Appointment_Status__c == 'וידוא הגעה לפגישה')) {
                    if ((appt.Medical_procedure__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Profile_upd_cncl__c.contains(this.user.ProfileId))
                            && (appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c == null || appt.Medical_procedure__r.Domain__r.Profile_upd_cncl__c.contains(this.user.ProfileId))) {
                        if (this.isPatientActive(appt.Patient_Account__r)) {
                            buttons.add(new ButtonWrp('UpdateAppointmentButton', LC_ActionButtonUtil.LBL_UPDATE_APPOINTMENT, LC_ActionButtonUtil.UPDATE_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                        }
                        buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_CANCEL_APPOINTMENT, LC_ActionButtonUtil.CANCEL_MODE, LC_ActionButtonUtil.FULL_SCREEN));
                    }

                    if (appt.Is_Urgent__c
                            && this.isForcedSlotsAvailable()
                            && this.isCalendarProcedureUrgent(appt)) {
                        buttons.add(new ButtonWrp('C30_SubmitForcedAppointmentModal', LC_ActionButtonUtil.LBL_URGENT_UPDATE));
                    }
                }

                if (appt.Site__r.Site_Code__c == '48') {
                    buttons.add(new ButtonWrp('sendQuestionnaireLinkModal', LC_ActionButtonUtil.LBL_SEND_QUESTIONNAIRE));
                }

                if (this.isValidForPayment(appt)) {
                    buttons.add(new ButtonWrp('paymentValidationModal', LC_ActionButtonUtil.LBL_MAKE_PAYMENT));
                }
            }
            when 'Surgeries' {
                if (this.isPatientActive(appt.Patient_Account__r)
                        && appt.Presurgery_needed1__c) {
                    buttons.add(new ButtonWrp('AppoitmentsShowButton', LC_ActionButtonUtil.LBL_SCHEDULE_PRE_SURGERY, LC_ActionButtonUtil.CREATE_MODE, LC_ActionButtonUtil.LIMITED_PROCEDURES_SCREEN));
                }

                if (this.isValidForPayment(appt)) { // && appt.Spincal__r.tafnitID__c != null
                    buttons.add(new ButtonWrp('paymentValidationModal', LC_ActionButtonUtil.LBL_MAKE_PAYMENT));
                }
            }
        }

        return buttons;
    }

    /** Recommendations_after_exam__c */
    private List<ButtonWrp> obtainButtons(Recommendations_after_exam__c recomm) {
        List<ButtonWrp> buttons = new List<ButtonWrp>();

        switch on recomm.RecordType.DeveloperName {
            when 'Memo' {
                if (recomm.Status_recommendation__c == null || recomm.Status_recommendation__c == 'חדש') {
                    buttons.add(new ButtonWrp('convertMethod', LC_ActionButtonUtil.LBL_CONVERT_TO_360_CASE));
                }
            }
        }

        return buttons;
    }

    /** INNER METHODS */
    private Boolean isCaseClosed(Case cas) {
        return LC_ActionButtonUtil.CASE_SKIP_STATUSES.contains(cas.Status);
    }

    private Boolean hasFutureAppointments(Case cas) {
        return !LC_ActionButtonUtil.obtainFutureAppointments(cas).isEmpty();
    }

    private Boolean isAshdodEmployee() {
        return this.user.Ashdod_employee__c;
    }

    private Boolean isProfileMaccabi() {
        return Label.Portal_Maccabi_Btn_Available_ProfileId.contains(this.user.ProfileId);
    }

    private Boolean isForcedSlotsAvailable() {
        return Label.Forced_slots_available_UserId_ProfileId_RoleId.contains(this.user.Id)
            || Label.Forced_slots_available_UserId_ProfileId_RoleId.contains(this.user.ProfileId)
            || (this.user.UserRoleId != null && Label.Forced_slots_available_UserId_ProfileId_RoleId.contains(this.user.UserRoleId));
    }

    private Boolean isPatientActive(Account patient) {
        return patient != null && !patient.Not_active__c;
    }

    private Boolean isPatientEntitledToAmbulator(Account patient) {
        return patient != null && !patient.Patient_not_entitled_for_ambulatory__c;
    }

    private Boolean hasDisabilities(Account patient) {
        return !LC_ActionButtonUtil.obtainDisabilities(patient).isEmpty();
    }

    private boolean isValidForPayment(Appointment__c appt) {
        return appt.Appointment_Date_Time__c == null
            || (Math.abs(Date.valueOf(appt.Appointment_Date_Time__c).daysBetween(appt.Patient_Account__r.PersonBirthdate)) >= 5 && appt.Appointment_Date_Time__c >= System.now());
    }

    private Boolean isCalendarProcedureUrgent(Appointment__c appt) {
        calendar_medp__c calendarProcedure = LC_ActionButtonUtil.obtainCalendarProcedure(appt);
        return calendarProcedure != null && calendarProcedure.save_slot__c;
    }

    /** WRAPPERS */
    public class RecordWrp {
        @AuraEnabled
        public String sObjectType {get;set;} // without '__c'
        @AuraEnabled
        public List<ButtonWrp> buttons {get;set;}

        public RecordWrp(SObject record, List<ButtonWrp> buttons) {
            this.sObjectType = String.valueOf(record.getSObjectType()).substringBefore('__');
            this.buttons = buttons;
        }
    }

    public class ButtonWrp {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public String mode {get;set;} // create, update, cancel
        @AuraEnabled
        public String screenMode {get;set;} // full, limitedProcedures, doctorHeader

        public ButtonWrp(String value) {
            this.value = value;
        }

        public ButtonWrp(String value, String label) {
            this(value);
            this.label = label;
        }

        public ButtonWrp(String value, String label, String mode) {
            this(value, label);
            this.mode = mode;
        }

        public ButtonWrp(String value, String label,String mode, String screenMode) {
            this(value, label, mode);
            this.screenMode = screenMode;
        }
    }
}