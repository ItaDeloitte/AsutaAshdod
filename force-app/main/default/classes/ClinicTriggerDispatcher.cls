// Test: ClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 31.01.2020
public class ClinicTriggerDispatcher {

    public static void updateDocFields(List<Clinic__c> newList, Map<Id, Clinic__c> oldMap) {
        System.debug('ClinicTriggerDispatcher.updateDocFields...');
        Set<Id> clinicIds = new Set<Id>();

        if (newList != null) { // INSERT, UPDATE
            for (Clinic__c clinic_i : newList) {
                if (oldMap == null || clinic_i.Area__c != oldMap.get(clinic_i.Id).Area__c) {
                    clinicIds.add(clinic_i.Id);
                }
            }
        } else if (newList == null && oldMap != null) { // DELETE
            for (Clinic__c clinic_i : oldMap.values()) {
                clinicIds.add(clinic_i.Id);
            }
        }

        System.debug('clinicIds: size: ' + clinicIds.size() + ' values: ' + clinicIds);
        if (!clinicIds.isEmpty()) {
            ClinicServices.updateDocFields(clinicIds);
        }
    }

    public static void updatePromotedDoctors(List<Clinic__c> newList, Map<Id, Clinic__c> oldMap){
        System.debug('ClinicTriggerDispatcher.updatePromotedDoctors...');
        Set<Id> validClinicsIds = new Set<Id>();
            for (Clinic__c clinic : newList) {
                if (clinic.Promoted_Clinic__c != oldMap.get(clinic.Id).Promoted_Clinic__c) { // compare new list with old map
                    validClinicsIds.add(clinic.id);
                }
            }
        System.debug('doctorIds: size: ' + validClinicsIds.size());
        if (!validClinicsIds.isEmpty()) {
            ClinicServices.updatePromotedDoctors(validClinicsIds);
        }
    }


}