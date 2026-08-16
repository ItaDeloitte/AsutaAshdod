//A trigger responsible for "catching" the events which update on the hopitalization status of patients. The events are being fired by Ensemble.
//Test: HospitalizationStatusTest
trigger HospitalizationStatusTrigger on Hospitalization_Status__e (after insert) {

    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('Hospitalization_Status__e')){
        HopitalizationStatusTriggerDispatcher.updateStatus(trigger.New);
    }
}