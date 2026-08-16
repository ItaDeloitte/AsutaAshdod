/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Job to trigger the creation of SurveyTaker__c records based on relevant Appointment__c records. When an Appointment__c
 * record is valid, the job will create a new SurveyTaker__c record and initialize all relevant fields and lookup tables.
 * 
 * Test                 DocAdvisorSurveyCreatorTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             05-05-2021             <maxf@assuta.co.il>
 * @modified            27-01-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global class DocAdvisorSurveyCreatorSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    String query = 'SELECT Case__c'
                      + ', Site__c'
                      + ', Clinic__c'
                      + ', Release_Date__c'
                      + ', Doctor_Account__c'
                      + ', Patient_Account__c'
                      + ', Medical_Procedure__c'
                      + ', Medical_Procedure2__c'
                      + ', Medical_Procedure3__c'
                      + ', Medical_Procedure4__c'
                  + ' FROM Appointment__c'
                 + ' WHERE RecordType.DeveloperName = \'Surgeries\''
                   + ' AND Release_Date__c = TODAY'
                   + ' AND Patient_Account__r.ID_Type__c = \'1\''
                   + ' AND Doctor_Account__r.SendSurvey__c = true'
                   + ' AND Medical_Procedure__r.Confidentiality__c != true'
                   + ' AND Medical_Procedure2__r.Confidentiality__c != true'
                   + ' AND Medical_Procedure3__r.Confidentiality__c != true'
                   + ' AND Medical_Procedure4__r.Confidentiality__c != true';

    global DocAdvisorSurveyCreatorSchedulableBatch() {}

    global DocAdvisorSurveyCreatorSchedulableBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DocAdvisorSurveyCreatorSchedulableBatch ... start');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Appointment__c> scope) {
        System.debug('DocAdvisorSurveyCreatorSchedulableBatch ... execute');
        Set<Id> appointmentIdSet = new Set<Id>();
        Set<Id> apptSurveyTakerExist = new Set<Id>();
        List<SurveyTaker__c> surveyTakersToInsert = new List<SurveyTaker__c>();
        List<SurveyQuestionResponse__c> surveyResponsesToInsert = new List<SurveyQuestionResponse__c>();

        Id rtId = SObjectType.SurveyTaker__c.getRecordTypeInfosByDeveloperName().get('Doc_Advisor').getRecordTypeId();
        System.debug('rtId: ' + rtId);

        Integer daysOffset = Integer.valueOf(DocAdvisorSetting__c.getOrgDefaults().Days_From_Release__c);
        System.debug('daysOffset: ' + daysOffset);

        Id surveyId = [
            SELECT Id
              FROM Survey__c
             WHERE SurveyCode__c = 'DocAdvisor'].Id;
        System.debug('surveyId: ' + surveyId);

        for (Appointment__c appt_i : scope) {
            appointmentIdSet.add(appt_i.Id);           
        }
        
        for (SurveyTaker__c surveyTaker_i :[SELECT Id
                                                 , Appointment__c
                                            FROM SurveyTaker__c
                                            WHERE RecordTypeId = :rtId
                                            AND Appointment__c IN : appointmentIdSet]) {
            apptSurveyTakerExist.add(surveyTaker_i.Appointment__c);                                    
        }        
        System.debug('apptSurveyTakerExist: size: ' + apptSurveyTakerExist.size() + ' value: ' + apptSurveyTakerExist);
        
        for (Appointment__c appt_i : scope) {
            if (!apptSurveyTakerExist.contains(appt_i.Id)) surveyTakersToInsert.add(prepareSurveyTaker(surveyId, rtId, appt_i, daysOffset));
        }
    
        System.debug('surveyTakersToInsert: size: ' + surveyTakersToInsert.size() + ' value: ' + surveyTakersToInsert);

        Set<Id> surveyTakerIds = doInsert(surveyTakersToInsert);
        System.debug('surveyTakerIds: size: ' + surveyTakerIds.size() + ' value: ' + surveyTakerIds);

        List<Survey_Question__c> surveyQuestions = [
            SELECT IsForAvg__c
              FROM Survey_Question__c
             WHERE Survey__c = :surveyId];
        System.debug('surveyQuestions: size: ' + surveyQuestions.size() + ' value: ' + surveyQuestions);

        for (Id stId_i : surveyTakerIds) {
            for (Survey_Question__c sq_j : surveyQuestions) {
                surveyResponsesToInsert.add(prepareSurveyResponse(stId_i, sq_j));
            }
        }
        System.debug('surveyResponsesToInsert: size: ' + surveyResponsesToInsert.size() + ' value: ' + surveyResponsesToInsert);

        Set<Id> surveyResponseIds = doInsert(surveyResponsesToInsert);
        System.debug('surveyResponseIds: size: ' + surveyResponseIds.size() + ' value: ' + surveyResponseIds);
    }

    private static SurveyTaker__c prepareSurveyTaker(Id surveyId, Id rtId, Appointment__c appt, Integer daysOffset) {
        return new SurveyTaker__c(
            RecordTypeId = rtId,
            Survey__c = surveyId,
            Appointment__c = appt.Id,
            Account__c  = appt.Patient_Account__c,
            Doctor__c = appt.Doctor_Account__c,
            Case__c = appt.Case__c,
            Site__c = appt.Site__c,
            Medical_Procedure_1__c = appt.Medical_Procedure__c,
            Medical_Procedure_2__c = appt.Medical_Procedure2__c,
            Medical_Procedure_3__c = appt.Medical_Procedure3__c,
            Medical_Procedure_4__c = appt.Medical_Procedure4__c,
            sms_send_time__c = appt.Release_Date__c.addDays(daysOffset));
    }

    private static SurveyQuestionResponse__c prepareSurveyResponse(Id stId, Survey_Question__c sq) {
        return new SurveyQuestionResponse__c(
            IsForAvg__c = sq.IsForAvg__c,
            Survey_Question__c= sq.Id,
            SurveyTaker__c = stId);
    }

    private static Set<Id> doInsert(List<SObject> sobjsToInsert) {
        Set<Id> insertedIds = new Set<Id>();

        if (!sobjsToInsert.isEmpty()) {
            String sobjType = String.valueOf(sobjsToInsert.get(0).getSObjectType());
            for (Database.SaveResult dr_i : Database.insert(sobjsToInsert, false)) {
                if (dr_i.isSuccess()) {
                    insertedIds.add(dr_i.getId());
                } else {
                    System.debug('The following errors have occurred while trying to insert ' + sobjType + ':');
                    for (Database.Error err_i : dr_i.getErrors()) {
                        System.debug(' - ' + err_i.getStatusCode() + ': ' + err_i.getMessage());
                    }
                }
            }
        }

        return insertedIds;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('DocAdvisorSurveyCreatorSchedulableBatch ... finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DocAdvisorSurveyCreatorSchedulableBatch(), 25);
    }
}