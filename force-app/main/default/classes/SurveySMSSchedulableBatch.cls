global class SurveySMSSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    public static Map<String, Schema.RecordTypeInfo> SurveyTakerRTMap = Schema.SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName();
    Id docAdvisorRTId = SurveyTakerRTMap.get('Doc_Advisor').getRecordTypeId();
    Id digiFormsRTId = SurveyTakerRTMap.get('Digital_Forms').getRecordTypeId();
    DocAdvisorSetting__c docAdvDaysOffset = DocAdvisorSetting__c.getOrgDefaults(); 
    Integer docAdvReminderOffset = Integer.valueOf(docAdvDaysOffset.Days_Reminder_Offset__c);
    Boolean runNextJob = false;
    Datetime currDatetime = Datetime.now();
    String currDatetimeStr = currDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    String query = 'SELECT Id'
                      + ', Account__c'
                      + ', Account__r.Phone'
                      + ', Appointment__c '
                      + ', Case__c'
        			  + ', survey_link__c '
                      + ', RecordTypeid '
                      + ', sms_send_time__c '
                + ' FROM SurveyTaker__c'
                + ' WHERE (Taken__c != \'true\' OR Fill_Percentage__c = 0)'
                    + ' AND ((SendTime__c = null'
                    + ' AND is_sms_sent__c != true'
                    + ' AND (sms_send_time__c = LAST_N_DAYS:6)'
                    + ' AND Account__r.Phone != null'
                    + ' AND visit_date__c >'+currDatetimeStr
                    + ' AND Appointment__r.Appointment_Status__c != \'Canceled\''
                    + ' AND RecordType.DeveloperName = \'Digital_Forms\')'
                + ' OR (((is_sms_sent__c != true AND sms_send_time__c = TODAY)'
                    + ' OR (is_sms_sent__c = true AND IsReminderSent__c !=true AND Taken__c != \'true\' AND sms_send_time__c = LAST_N_DAYS:'+docAdvReminderOffset+' AND sms_send_time__c != LAST_N_DAYS:'+(Integer.valueOf(docAdvReminderOffset)-1)+' AND sms_send_time__c!= TODAY))'
                    + ' AND Account__r.Phone != null'
                    + ' AND (Account__r.Preferred_Channel__c = \'SMS\' OR Account__r.Preferred_Channel__c = \'Whatsapp\' OR Account__r.Preferred_Channel__c = \'Phone\')'
                    + ' AND RecordType.DeveloperName = \'Doc_Advisor\'))';

    global  SurveySMSSchedulableBatch() {
    }

    global SurveySMSSchedulableBatch(Boolean runNextJob) {
        this.runNextJob = runNextJob;
    }

    global SurveySMSSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query fields: ' + query.substringBefore('WHERE'));
        System.debug('query conditions: ' + query.substringAfter('SurveyTaker__c'));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<SurveyTaker__c> surveyTakers){
        List<SMS__c> smsList = new List<SMS__c>();
        Set<String> errors = new Set<String>();
        Set<Id> smsIds = new Set<Id>();
        for (SurveyTaker__c st : surveyTakers) {
            smsList.add(createSMS(st.RecordTypeid ==  digiFormsRTId ? 'Survey_Link' : 'Doc_Advisor_Link',st));
        }
        System.debug('smsList: size: ' + smsList.size() + ' value: ' + smsList);
        for (Database.SaveResult result_i : Database.insert(smsList, false)) {
            if (result_i.isSuccess()) {
                smsIds.add(result_i.getId());
            } else {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        for (SurveyTaker__c st : surveyTakers) {
            st.is_sms_sent__c=true;
            if(st.RecordTypeid ==  docAdvisorRTId && st.sms_send_time__c.day() !=currDatetime.day()){
                st.IsReminderSent__c=true;
            }
        }
        for (Database.SaveResult result_i : Database.update(surveyTakers, false)) {
            if (!result_i.isSuccess()) {
                errors.add(result_i.getId() + ': ' + result_i.getErrors());
            }
        }
        System.debug('errors: ' + JSON.serialize(errors));
    } 

    private SMS__c createSMS(String context,SurveyTaker__c st){
        return new SMS__c(
                    status__c = '1',
                    Type__c = 'Outgoing',
                    Template_Text__c = getTemplate(st,context),
                    Phone_Number__c = st.Account__r.Phone,
                    Event_Name__c = context,
                    Account__c = st.Account__c,
                    Case__c = st.Case__c,
                    Appointment__c  = st.Appointment__c
                );
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
        System.debug('runNextJob: ' + runNextJob);
        if(runNextJob) {
            Database.executeBatch(new SurveySMSSchedulableBatch(true), 25);
        }
    }
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new SurveySMSSchedulableBatch(runNextJob), 25);
    }

    private String getTemplate(SurveyTaker__c st, String smsName) {
        String template = smsName + ',' + st.survey_link__c ;
        return template;
    }
}