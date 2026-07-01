public class TriggerSetting {

    // private static variable referencing the class
    private static TriggerSetting instance = null;
    private List<Trigger_Setting__mdt> getTriggerDetails;
    private static Map<String, boolean> triggerNameMap {get;private set;} 

    private TriggerSetting(){
        getTriggerDetails = new List<Trigger_Setting__mdt>([SELECT Id, TriggerName__c, IsActive__c FROM Trigger_Setting__mdt]);
        triggerNameMap = new Map<String, boolean>();
        for(Trigger_Setting__mdt triggerDetails :getTriggerDetails){
            triggerNameMap.put(triggerDetails.TriggerName__c, triggerDetails.IsActive__c);
        }
    }

    public static boolean isTriggerActive(String triggerName){
        System.debug('TriggerSetting.isTriggerActive...');
        return (triggerNameMap.get(triggerName) == null || (!(triggerNameMap.get(triggerName) == null) 
        && triggerNameMap.get(triggerName)));
    }

    // a static method that returns the instance of the map
    public static TriggerSetting getInstance(){
        // load the map - only initialize if it doesn't already exist
        if(instance == null) instance = new TriggerSetting();
        return instance;
    }
}