// Test: ClinicServicesTest
// Created: Evgeniy Kravchuk
// Date: 31.01.2020
public class ClinicServices {

    public static void updateDocFields(Set<Id> clinicIds) {
        System.debug('ClinicServices.updateDocFields...');
        List<Doctor_in_Clinic__c> junctions = [SELECT Id, Doctors__c FROM Doctor_in_Clinic__c WHERE Clinic__c IN: clinicIds AND Clinic__r.Area__c != null];
        Set<Id> doctorIds = new Set<Id>();

        for (Doctor_in_Clinic__c junction_i : junctions) {
            doctorIds.add(junction_i.Doctors__c);
        }
        System.debug('doctorIds: size: ' + doctorIds.size() + ' values: ' + doctorIds);
        DocInClinicServices.updateDocFields(doctorIds);
    }
	
    @Future
    public static void updatePromotedDoctors(Set<Id> clinicListIds){
        System.debug('ClinicServices.updatePromotedDoctors...');
        Map<Id,Boolean> clinicPromotedMap = new Map<Id,Boolean>();
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> accountsIds = new Set<Id>();
        Map<Id,Id> accountClinicMap = new Map<Id,Id>();
        List<Clinic__c> clinicsList = [SELECT Id,Promoted_Clinic__c FROM Clinic__c WHERE Id IN: clinicListIds];
        for(Clinic__c clinic : clinicsList){
            if(clinic.Promoted_Clinic__c){
                clinicPromotedMap.put(clinic.Id,true);
            }else{
                clinicPromotedMap.put(clinic.Id,false);
            }
        }
        // query junction table to update junction records
        List<Doctor_in_Clinic__c> docClinics = [SELECT id,Doctors__c,Clinic__c FROM Doctor_in_Clinic__c WHERE Clinic__c IN: clinicsList];
        for(Doctor_in_Clinic__c dic : docClinics){
            accountsIds.add(dic.Doctors__c);
            accountClinicMap.put(dic.Doctors__c,dic.Clinic__c);
            dic.Promoted_doctor_clinic__c = clinicPromotedMap.get(dic.Clinic__c);
        }
        List<Account> accounts = [SELECT Id,Promoted_doctor__c FROM Account WHERE Id IN :accountsIds];
        for(Account account : accounts){
            if(account.Promoted_doctor__c!=null){ // manage promoted doctor inside the multiPicklist
                String[] promotedCriterias = account.Promoted_doctor__c.split(';');
                if(clinicPromotedMap.get(accountClinicMap.get(account.id)) && !promotedCriterias.contains('Clinic')){
                    promotedCriterias.add('Clinic');
                    account.Promoted_doctor__c = String.join(promotedCriterias,';');
                    accountsToUpdate.add(account);
                }else if(!clinicPromotedMap.get(accountClinicMap.get(account.id)) && promotedCriterias.contains('Clinic')){
                    promotedCriterias.remove(promotedCriterias.indexOf('Clinic'));
                    account.Promoted_doctor__c = String.join(promotedCriterias,';');
                    accountsToUpdate.add(account);
                }
            }else{
                if(clinicPromotedMap.get(accountClinicMap.get(account.id))){
                    account.Promoted_doctor__c = 'Clinic';
                    accountsToUpdate.add(account);
                }
            }
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
        if(docClinics!=null){
            update docClinics;
        }
    }
}