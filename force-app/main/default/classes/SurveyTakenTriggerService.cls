//SurveyTakenTriggerTest
public class SurveyTakenTriggerService {    
    
    public static void createQuestions(Set<Id> surveyIds, Map<Id, List<Id>> surveyToTakers) {
        System.debug('SurveyTakenTriggerService.createQuestions');
        List<SurveyQuestionResponse__c> surveyQuestionToInsert = new List<SurveyQuestionResponse__c>();
        List<Survey_Question__c> questions = [SELECT Survey__c, Survey__r.SurveyCode__c, UnShow__c, IsForAvg__c
                                             FROM Survey_Question__c
                                              WHERE status_question__c = true
                                              AND Survey__c IN :surveyIds
                                              AND Survey__r.SurveyCode__c != 'DocAdvisor'];

        for (Survey_Question__c q : questions) {
            List<Id> takers = surveyToTakers.get(q.Survey__c);
            if (takers == null) continue;

            for (Id takerId : takers) {
                surveyQuestionToInsert.add(new SurveyQuestionResponse__c(
                    IsForAvg__c = (q.Survey__r.SurveyCode__c == 'DocAdvisor') && q.IsForAvg__c,
                    Survey_Question__c = q.Id,
                    SurveyTaker__c = takerId,
                    UnShow__c = q.UnShow__c
                ));
            }
        }

        if (!surveyQuestionToInsert.isEmpty()) {            
            insert surveyQuestionToInsert;
            System.debug('TR SurveyTaken createQuestions ... executed');
        }
    }

    public static void sendSurveyLinkMessage(Set<Id> takerIds) {
        System.debug('SurveyTakenTriggerService.sendSurveyLinkMessage');         
    
        List<SurveyTaker__c> takers = [SELECT Id,
                                            Account__r.SMS_Phone_Number__c,
                                            Account__r.FirstName,
                                            Appointment__c,
                                            Appointment__r.Id,
                                            Appointment__r.Case__c,
                                            Appointment__r.Patient_Account__c,
                                            Appointment__r.Patient_Account__r.SMS_Phone_number__c,
                                            SurveyCode__c,
                                            Survey_link__c
                                        FROM SurveyTaker__c
                                        WHERE Id IN :takerIds
                                       ];                                    

        Map<Id, String> takerIdToPhoneNumber = new  Map<Id, String>();
        for (SurveyTaker__c taker : takers) {
            String phone_i = WhatAppUtils.validPhoneNumber(taker.Account__r.SMS_Phone_Number__c);
            takerIdToPhoneNumber.put(taker.Id, phone_i);
        }

        String channelId;
        String channelName;
        Map<String, Id> phoneNumberToEndUser = new Map<String, Id>();
        
        System.debug('takerIdToPhoneNumber: size: ' + takerIdToPhoneNumber.size() + ' value: ' + takerIdToPhoneNumber);
        if (!takerIdToPhoneNumber.isEmpty()) {
            List<MessagingChannel> mesChannels = WhatAppUtils.getMessagingChannel('Assuta_Enhanced_Bot');
            if (!mesChannels.isEmpty()) {
                channelName = mesChannels.get(0).MasterLabel;
                channelId = mesChannels.get(0).Id;
            }
            phoneNumberToEndUser = WhatAppUtils.getMessagingEndUser(takerIdToPhoneNumber, channelId); 
        }

        List<WhatsApp__c> whatAppToInsert = new List<WhatsApp__c>();
        List<SurveyTaker__c> SurveyTakersToUpdate = new List<SurveyTaker__c>();

        for (SurveyTaker__c taker : takers) { 
            if (taker.Appointment__c == null)  continue;         
            whatAppToInsert.add(WhatAppUtils.prepareWhatApp(taker.Appointment__r 
                                                            , 'generic_survey_template'
                                                            , 'SurveyTakenTriggerService'                                                                                                                     
                                                            , phoneNumberToEndUser.containsKey(takerIdToPhoneNumber.get(taker.Id)) ? phoneNumberToEndUser.get(takerIdToPhoneNumber.get(taker.Id)) : null
                                                            , System.now()
                                                            , channelName
                                                            , 'firstname:' + taker.Account__r.FirstName  + '^link:' + taker.Survey_link__c + '^'));                                                                      
        }

        Set<Id> insertedWAIdSet = AsyncUtil.doInsert(whatAppToInsert);
        System.debug('insertedWAIdSet: size: ' + insertedWAIdSet.size() + ' value: ' + insertedWAIdSet);
        for (WhatsApp__c wa_i : [SELECT Id
                                  , Survey_Taken__c 
                               FROM WhatsApp__c 
                              WHERE Id 
                                 IN :insertedWAIdSet]) {
            SurveyTakersToUpdate.add(new SurveyTaker__c(
                Id = wa_i.Survey_Taken__c,
                IsSent__c  = true,
                SendTime__c = system.now()));
        }
        System.debug('SurveyTakersToUpdate: size: ' + SurveyTakersToUpdate.size() + ' value: ' + SurveyTakersToUpdate);
        AsyncUtil.doUpdate(SurveyTakersToUpdate);
    }   
}