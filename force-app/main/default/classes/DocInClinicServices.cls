// Test: DocInClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 30.01.2020
public class DocInClinicServices {

    public static void updateDocFields(Set<Id> doctorIds) {
        System.debug('DocInClinicServices.updateDocFields...');
        List<Doctor_in_Clinic__c> junctions = [SELECT Id, Doctors__c, Schedule_System__c, Clinic__r.Area__c FROM Doctor_in_Clinic__c WHERE Doctors__c IN: doctorIds AND (Schedule_System__c != null OR Clinic__r.Area__c != null)];
        Map<Id, Set<String>> docToDistricts = new Map<Id, Set<String>>();
        Map<Id, Set<String>> docToSSystems = new Map<Id, Set<String>>();
        List<Account> doctors = new List<Account>();
        doctorIds = new Set<Id>();

        for (Doctor_in_Clinic__c junction_i : junctions) {
            doctorIds.add(junction_i.Doctors__c);
            // populating doctor map with all unique areas
            if (junction_i.Clinic__r.Area__c != null) {
                if (!docToDistricts.containsKey(junction_i.Doctors__c)) {
                    docToDistricts.put(junction_i.Doctors__c, new Set<String>());
                }
                docToDistricts.get(junction_i.Doctors__c).add(junction_i.Clinic__r.Area__c);
            }
            // populating doctor map with all unique schedule systems
            if (junction_i.Schedule_System__c != null) {
                if (!docToSSystems.containsKey(junction_i.Doctors__c)) {
                    docToSSystems.put(junction_i.Doctors__c, new Set<String>());
                }
                docToSSystems.get(junction_i.Doctors__c).add(junction_i.Schedule_System__c);
            }
        }

        for (Id id_i : doctorIds) {
            Account doctor_i = new Account(Id = id_i);
            if (docToSSystems.containsKey(doctor_i.Id)) {
                doctor_i.sched_sys_doc_clinics__c = String.join(new List<String>(docToSSystems.get(doctor_i.Id)), ', ');
            }
            if (docToDistricts.containsKey(doctor_i.Id)) {
                doctor_i.districts__c = String.join(new List<String>(docToDistricts.get(doctor_i.Id)), ', ');
            }
            doctors.add(doctor_i);
        }

        System.debug('doctors: size: ' + doctors.size() + ' values: ' + doctors);
        if (!doctors.isEmpty()) {
            update doctors;
        }
    }
}