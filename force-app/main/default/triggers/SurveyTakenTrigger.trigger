trigger SurveyTakenTrigger on SurveyTaker__c (before insert, after insert) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Survey')){
        SurveyTakenTriggerHandler.handleTrigger(Trigger.new, Trigger.operationType);
    }

}