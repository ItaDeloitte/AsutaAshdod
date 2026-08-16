public class SurveyTakenTriggerHandler {
    public static void handleTrigger(List<SurveyTaker__c> newList, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                SurveyTakenTriggerDispatcher.populateUUID(newList);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                SurveyTakenTriggerDispatcher.createQuestions(newList);
                SurveyTakenTriggerDispatcher.sendSurveyLinkMessage(newList);
                
            }
            when else {
                System.debug('do nothing on other trigger events');
            }
        }
    }
}