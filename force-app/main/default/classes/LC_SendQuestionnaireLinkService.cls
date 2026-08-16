/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Appointment 'Send Questionnaire Link' button Apex Service class to keep main logic
 * 
 * Test                 LC_SendQuestionnaireLinkTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             13-09-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class LC_SendQuestionnaireLinkService {

    public class LC_SendQuestionnaireLinkException extends Exception {}

    private static LC_SendQuestionnaireLinkService instance;

    private Appointment__c appointment;
    private Map<Id, SurveyTaker__c> surveyTakerMap;

    public static LC_SendQuestionnaireLinkService getInstance(String appointmentId) {
        if (instance == null) {
            instance = new LC_SendQuestionnaireLinkService(appointmentId);
        }
        return instance;
    }

    /** CONSTRUCTOR */
    private LC_SendQuestionnaireLinkService(String appointmentId) {
        this.appointment = LC_SendQuestionnaireLinkUtil.obtainAppointment(appointmentId);
        System.debug('appointment: ' + this.appointment);
        this.surveyTakerMap = new Map<Id, SurveyTaker__c>(this.appointment.Surveys_Taken_Appointment__r);

        if (this.appointment.Case__r.SMS_Phone_Number__c == null) {
            throw new LC_SendQuestionnaireLinkException(LC_SendQuestionnaireLinkUtil.ERR_PHONE);
        }
    }

    /** METHODS */
    public List<SurveyTakertWrp> obtainSurveyTakers() {
        List<SurveyTakertWrp> surveyTakers = new List<SurveyTakertWrp>();

        for (SurveyTaker__c surveyTaker_i : this.surveyTakerMap.values()) {
            surveyTakers.add(new SurveyTakertWrp(surveyTaker_i));
        }
        System.debug('surveyTakers: size: ' + surveyTakers.size() + ' value: ' + surveyTakers);

        return surveyTakers;
    }

    public void submit(String surveyTakerId) {
        SurveyTaker__c surveyTaker = this.surveyTakerMap.get(surveyTakerId);
        System.debug('surveyTaker: ' + surveyTaker);

        insert new SMS__c(
            Type__c = 'Outgoing',
            SmsTemplate__c = 'Survey_Taken_Send_Link',
            Automation_name__c = 'LC_SendQuestionnaireLinkService',
            Phone_Number__c = this.appointment.Case__r.SMS_Phone_Number__c,
            ExpectedSendingDateTime__c = Datetime.now(),
            Appointment__c = this.appointment.Id,
            Case__c = this.appointment.Case__c,
            SurveyTaker__c = surveyTaker.Id
        );
    }

    /** WRAPPERS */
    public class SurveyTakertWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String link {get;set;}
        @AuraEnabled
        public Boolean isLocked {get;set;}
        @AuraEnabled
        public Decimal fillPercentage {get;set;}
        @AuraEnabled
        public SurveyWrp survey {get;set;}

        public SurveyTakertWrp(SurveyTaker__c surveyTaker) {
            this.id = surveyTaker.Id;
            this.name = surveyTaker.Name;
            this.link = surveyTaker.Survey_link__c;
            this.isLocked = surveyTaker.IsLocked__c;
            this.fillPercentage = surveyTaker.Fill_Percentage__c;
            this.survey = new SurveyWrp(surveyTaker.Survey__r);
        }
    }

    public class SurveyWrp {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}

        public SurveyWrp(Survey__c survey) {
            this.id = survey.Id;
            this.name = survey.Name;
        }
    }
}