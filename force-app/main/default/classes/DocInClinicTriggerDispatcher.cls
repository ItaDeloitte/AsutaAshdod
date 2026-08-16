// Test: DocInClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 30.01.2020
public class DocInClinicTriggerDispatcher {

    public static void updateDocFields(List<Doctor_in_Clinic__c> newList, Map<Id, Doctor_in_Clinic__c> oldMap) {
        System.debug('DocInClinicTriggerDispatcher.updateDocFields...');
        Set<Id> doctorIds = new Set<Id>();

        if (newList != null) { // INSERT, UPDATE
            for (Doctor_in_Clinic__c junction_i : newList) {
                if (oldMap == null || junction_i.Doctors__c != oldMap.get(junction_i.Id).Doctors__c || junction_i.Clinic__c != oldMap.get(junction_i.Id).Clinic__c || junction_i.Schedule_System__c != oldMap.get(junction_i.Id).Schedule_System__c) {
                    doctorIds.add(junction_i.Doctors__c);
                }
            }
        } else if (newList == null && oldMap != null) { // DELETE
            for (Doctor_in_Clinic__c junction_i : oldMap.values()) {
                doctorIds.add(junction_i.Doctors__c);
            }
        }

        System.debug('doctorIds: size: ' + doctorIds.size() + ' values: ' + doctorIds);
        if (!doctorIds.isEmpty()) {
            DocInClinicServices.updateDocFields(doctorIds);
        }
    }
    
    public static void fillFormtitanId(List<Doctor_in_Clinic__c> newList){
        System.debug('DocInClinicTriggerDispatcher.fillFormtitanId...');
        for (Doctor_in_Clinic__c junction_i : newList) {
            String randomStr = CommonService.generateRandomKey(15);
            junction_i.FormtitanId__c = randomStr;
            System.debug('junction_i.FormtitanId__c ' + junction_i.FormtitanId__c);
        }
    }
}