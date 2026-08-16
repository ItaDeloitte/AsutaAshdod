/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Test                 UpdateDoctorsScheduleBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @modified            20-04-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class UpdateDoctorsScheduleBatch implements Database.Batchable<SObject>, Schedulable {

    global String query = 'SELECT OnlineSummon__c'
                             + ', AreaFromSiteAndClinic__c'
                             + ', CityFromSiteAndClinic__c'
                         + ' FROM Account'
                        + ' WHERE Status__c = \'פ\''
                          + ' AND (Show_in_website__c = true OR Show_in_Docadvisor__c = true)'
                          + ' AND RecordType.DeveloperName = \'Doctor_Account\'';

    global UpdateDoctorsScheduleBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('UpdateDoctorsScheduleBatch.start ...');
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('UpdateDoctorsScheduleBatch.execute ...');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        Map<Id, Set<String>> docIdToClinicCitiesMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> docIdToSiteCitiesMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> docIdToClinicAreasMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> docIdToSiteAreasMap = new Map<Id, Set<String>>();
        List<Account> doctorsToUpdate = new List<Account>();

        for (Account doctor_i : scope) {
            docIdToClinicCitiesMap.put(doctor_i.Id, new Set<String>());
            docIdToSiteCitiesMap.put(doctor_i.Id, new Set<String>());
            docIdToClinicAreasMap.put(doctor_i.Id, new Set<String>());
            docIdToSiteAreasMap.put(doctor_i.Id, new Set<String>());
        }

        for (Doctor_in_Clinic__c docInClinic_i : [SELECT Doctors__c
                                                       , Clinic__r.settlement__r.Name
                                                       , Clinic__r.settlement__r.district__c
                                                    FROM Doctor_in_Clinic__c
                                                   WHERE Doctors__c IN :scope]) {
            if (docInClinic_i.Clinic__r.settlement__r.Name != null) {
                docIdToClinicCitiesMap.get(docInClinic_i.Doctors__c).add(docInClinic_i.Clinic__r.settlement__r.Name);
            }
            if (docInClinic_i.Clinic__r.settlement__r.district__c != null) {
                docIdToClinicAreasMap.get(docInClinic_i.Doctors__c).add(docInClinic_i.Clinic__r.settlement__r.district__c);
            }
        }
        System.debug('docIdToClinicCitiesMap: size: ' + docIdToClinicCitiesMap.size() + ' value: ' + docIdToClinicCitiesMap);
        System.debug('docIdToClinicAreasMap: size: ' + docIdToClinicAreasMap.size() + ' value: ' + docIdToClinicAreasMap);

        for (Doctor_in_site__c docInSite_i : [SELECT Account__c
                                                   , Site__r.settlement__r.Name
                                                   , Site__r.settlement__r.district__c 
                                                FROM Doctor_in_site__c
                                               WHERE Account__c IN :scope]) {
            if (docInSite_i.Site__r.settlement__r.Name != null) {
                docIdToSiteCitiesMap.get(docInSite_i.Account__c).add(docInSite_i.Site__r.settlement__r.Name);
            }
            if (docInSite_i.Site__r.settlement__r.district__c != null) {
                docIdToSiteAreasMap.get(docInSite_i.Account__c).add(docInSite_i.Site__r.settlement__r.district__c);
            }
        }
        System.debug('docIdToSiteCitiesMap: size: ' + docIdToSiteCitiesMap.size() + ' value: ' + docIdToSiteCitiesMap);
        System.debug('docIdToSiteAreasMap: size: ' + docIdToSiteAreasMap.size() + ' value: ' + docIdToSiteAreasMap);

        for (Account doctor_i : scope) {
            Set<String> validCities_i = new Set<String>();
            Set<String> validAreas_i = new Set<String>();

            validCities_i.addAll(docIdToClinicCitiesMap.get(doctor_i.Id));
            validAreas_i.addAll(docIdToClinicAreasMap.get(doctor_i.Id));

            if (!doctor_i.OnlineSummon__c) {
                validCities_i.addAll(docIdToSiteCitiesMap.get(doctor_i.Id));
                validAreas_i.addAll(docIdToSiteAreasMap.get(doctor_i.Id));
            }

            String cities_i = String.join(new List<String>(validCities_i), ';');
            String areas_i = String.join(new List<String>(validAreas_i), ';');

            if ((String.isNotBlank(cities_i) && cities_i != doctor_i.CityFromSiteAndClinic__c) ||
                    (String.isNotBlank(areas_i) != null && areas_i != doctor_i.AreaFromSiteAndClinic__c)) {
                doctor_i.CityFromSiteAndClinic__c = cities_i;
                doctor_i.AreaFromSiteAndClinic__c = areas_i;
                doctorsToUpdate.add(doctor_i);
            }
        }
        System.debug('doctorsToUpdate: size: ' + doctorsToUpdate.size() + ' value: ' + doctorsToUpdate);

        Set<Id> doctorIds = AsyncUtil.doUpdate(doctorsToUpdate);
        System.debug('doctorIds: size: ' + doctorIds.size() + ' value: ' + doctorIds);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('UpdateDoctorsScheduleBatch.finish ...');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateDoctorsScheduleBatch(), 25);
    }
}