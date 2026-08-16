public with sharing class AgentSurveyTriggerDispatcher {

    public static void fillFormtitanId(List<Agent_survey__c> newList, Map<Id, Agent_survey__c> oldMap){

        List<Agent_survey__c> agentSurvToUpdate = new List<Agent_survey__c>();

        for (Agent_survey__c agentServ_i : newList) {
            String randomStr = CommonService.generateRandomKey(15);
            agentServ_i.formtitan_id_2__c = randomStr;
        }
    }

}