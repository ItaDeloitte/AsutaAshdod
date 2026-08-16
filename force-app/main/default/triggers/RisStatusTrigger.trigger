/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * A trigger responsible for "catching" the events which update on the Ris status . The events are being fired by Ensemble.
 * Test                 
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             12-05-2022             <ortalk@assuta.co.il>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */ 
trigger RisStatusTrigger on RisStatus__e (after insert) {
    TriggerSetting triggerObj = TriggerSetting.getInstance();
    if(TriggerSetting.isTriggerActive('RisStatus__e')){       
        RisStatusTriggerDispatcher.updateStatus(Trigger.new);
    }
}