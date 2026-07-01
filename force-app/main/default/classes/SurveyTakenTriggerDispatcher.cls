//SurveyTakenTriggerTest
public with sharing class SurveyTakenTriggerDispatcher {

    public static void populateUUID(List<SurveyTaker__c> newList){
        for(SurveyTaker__c surv : newList){
            surv.UUID__c = UUID.randomUUID().toString();
        }
    }

    public static void createQuestions(List<SurveyTaker__c> newList){
        // SurveyId -> takerIds
        Map<Id, List<Id>> surveyToTakers = new Map<Id, List<Id>>();
        Set<Id> surveyIds = new Set<Id>();

        for (SurveyTaker__c st : newList) {
            if (st.Survey__c == null) continue;
            surveyIds.add(st.Survey__c);

            if (!surveyToTakers.containsKey(st.Survey__c)){
                surveyToTakers.put(st.Survey__c, new List<Id>());
            }
            surveyToTakers.get(st.Survey__c).add(st.Id);
        }

        if(!surveyIds.isEmpty()) {
            SurveyTakenTriggerService.createQuestions(surveyIds, surveyToTakers);
        }
    }
                
    public static void sendSurveyLinkMessage(List<SurveyTaker__c> newList) {                
        Set<Id> takerIds = new Set<Id>();

        for (SurveyTaker__c st : newList) {
            if (st.Survey__c != null && st.SendByWA__c) {
                takerIds.add(st.Id);
            }
        }

        if (!takerIds.isEmpty()) {
            SurveyTakenTriggerService.sendSurveyLinkMessage(takerIds);
        }       
    }
}