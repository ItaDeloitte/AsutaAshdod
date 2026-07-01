// Created: Evgeniy Kravchuk
// Date: 30.08.2019
// Description: search methods for lightning controllers
// Test: LC_SearchUtilsTest, LC_Case360ControllerTest, LC_AppointmentControllerTest, LC_DocExpertiseControllerTest, Bot_ChatbotControllerTest
public with sharing class LC_SearchUtils {

    public static final Integer LIMIT_OF_RECORDS = 10;

    // PROCEDURES SEARCH
    public static Response procedureSearchForDocExpert(String subExpertiseId, String keyWord) {
        System.debug('LC_SearchUtils.procedureSearchForDocExpert...\nsubExpertiseId: ' + subExpertiseId + '\nkeyWord: ' + keyWord);
        keyWord = '%' + keyWord + '%';
        String query = 'SELECT Id, Name, Marketing_Procedure_Name__c, Procedure_Code__c, Waiting_List__c, Sub_Expertise__c, Sub_Expertise__r.Name, Sub_Expertise__r.Expertise__c, Sub_Expertise__r.Expertise__r.Name FROM Medical_Procedure__c WHERE (Marketing_Procedure_Name__c LIKE: keyWord OR Procedure_Code__c LIKE: keyWord) AND (Status__c = \'1\' OR Status__c = null)';
        if (String.isNotBlank(subExpertiseId)) {
            query += ' AND Sub_Expertise__c =: subExpertiseId';
        }
        query += ' LIMIT ' + LIMIT_OF_RECORDS;
        List<Medical_Procedure__c> procedures = Database.query(query);

        System.debug('procedures: size: ' + procedures.size() + ' value: ' + procedures);
        return new Response(procedures);
    }

    // EXPERTISES SEARCH
    public static Response expertiseSearch(String expertiseName) {
        System.debug('LC_SearchUtils.expertiseSearch...\nexpertiseName: ' + expertiseName);
        expertiseName = '%' + expertiseName + '%';
        List<Expertise__c> expertises = [SELECT Id, Name FROM Expertise__c WHERE Status__c = '1' AND Show_on_website__c = true AND Name LIKE :expertiseName LIMIT 10];

        System.debug('expertises: size: ' + expertises.size() + ' value: ' + expertises);
        return new Response(expertises);
    }

    public static Response subExpertiseSearch(String expertiseId, String subExpertiseName) {
        System.debug('LC_SearchUtils.subExpertiseSearch...\nexpertiseId: ' + expertiseId + '\nsubExpertiseName: ' + subExpertiseName);
        subExpertiseName = '%' + subExpertiseName + '%';
        String query = 'SELECT Id, Name, Expertise__c, Expertise__r.Name FROM Sub_Expertise__c WHERE Name LIKE: subExpertiseName AND Status__c = \'1\'';
        if (String.isNotBlank(expertiseId)) {
            query += ' AND Expertise__c =: expertiseId';
        }
        query += ' ORDER BY LastViewedDate DESC';
        query += ' LIMIT ' + LIMIT_OF_RECORDS;

        List<Sub_Expertise__c> subExpertises = Database.query(query);
        System.debug('subExpertises: size: ' + subExpertises.size() + ' value: ' + subExpertises);

        return new Response(subExpertises);
    }

    // DOCTOR SEARCH
    public static Response doctorSearch(String keyWord) {
        System.debug('LC_SearchUtils.doctorSearch...\nkeyWord: ' + keyWord);
        keyWord = keyWord + '%';
        List<Account> doctors = [SELECT Id, Name, Doctor_personal_phone__c, Email__c FROM Account WHERE Name LIKE: keyWord AND RecordType.DeveloperName = 'Doctor_Account' ORDER BY Name];
        System.debug('doctors: size: ' + doctors.size() + ' value: ' + doctors);

        return new Response(doctors);
    }

    public static List<Appointment__c> getConnectedAppointmentsToCase(Case currentCase, String keyWord, Boolean isRestricted, Boolean isCaseAppButton) {
        System.debug('LC_SearchUtils.getConnectedAppointmentsToCase...\ncurrentCase: ' + currentCase + '\nkeyWord: ' + keyWord + '\nisRestricted: ' + isRestricted);
        String keyWordTMP = '%' + keyWord + '%';
        Boolean isFiltrationByKeyRequired = true;
        String appointmentRt = 'Institutes';
        if (currentCase.RecordType.DeveloperName == 'DOC_expert') {
            appointmentRt = 'Experts';
            isFiltrationByKeyRequired = false;
        } else if (currentCase.RecordType.DeveloperName == 'Assuta_360' || currentCase.RecordType.DeveloperName == 'CaseAfterSale') {
            appointmentRt = '';
            isFiltrationByKeyRequired = false;
        }

        Datetime currentDatetime = System.now();
        String accountId = currentCase.AccountId;
        String profileId = '%' + UserInfo.getProfileId() + '%';
        String queryStr = 'SELECT Id, Name, Appointment_Date_Time__c, Medical_Procedure__c, Accession_Number__c, Case__c, ' +
                                 'Medical_Procedure__r.Name, Medical_Procedure__r.Marketing_Procedure_Name__c, Medical_Procedure__r.Id, Medical_Procedure__r.Procedure_Code__c, ' +
                                 'Medical_Procedure__r.Profile_upd_cncl__c, Medical_Procedure__r.Domain__c, Medical_Procedure__r.Domain__r.Name, Medical_Procedure__r.Domain__r.Profile_upd_cncl__c,' +
                                 'Calendar__c, Calendar__r.Id, Calendar__r.Name, Calendar__r.ServiceId__c, Protocol__c, ' +
                                 'Site__c, Site__r.Id, Site__r.Name, Site__r.Site_Code__c, Is_Hidden_Appointment__c, after_appointment__c ' +
                          'FROM Appointment__c ' +
                          'WHERE Name LIKE: keyWordTMP ' +
                            'AND Appointment_Status__c != \'Canceled\' ' +
                            'AND Patient_Account__c =: accountId ' +
                            'AND Appointment_Date_Time__c >: currentDatetime';
        if (String.isNotBlank(appointmentRt)) {
            queryStr += ' AND RecordType.DeveloperName =: appointmentRt';
            if(isCaseAppButton){
                queryStr += ' AND ((Medical_Procedure__r.Profile_upd_cncl__c = null OR Medical_Procedure__r.Profile_upd_cncl__c LIKE :profileId) AND (Medical_Procedure__r.Domain__r.Profile_upd_cncl__c = null OR Medical_Procedure__r.Domain__r.Profile_upd_cncl__c LIKE :profileId))'; 
            }
        } else {
            queryStr += ' AND (RecordType.DeveloperName = \'Institutes\' OR RecordType.DeveloperName = \'Experts\')';
        }
        if (isFiltrationByKeyRequired) {
            queryStr += ' AND Accession_Number__c != null';
        }
        queryStr += ' ORDER BY Appointment_Date_Time__c DESC';
        if (isRestricted) {
            queryStr += ' LIMIT 20';
        }
        System.debug('queryStr: ' + queryStr);

        List<Appointment__c> appList = Database.query(queryStr);
        System.debug('appList: size: ' + appList.size() + ' value: ' + appList);

        return appList;
    }

    // private static List<Appointment__c> removeHiddenAppointments(List<Appointment__c> appointments) {
    //     System.debug('LC_SearchUtils.removeHiddenAppointments...\nappointments: ' + appointments);
    //     List<Appointment__c> resultList = new List<Appointment__c>();

    //     for (Integer i = appointments.size() - 1; i >= 0; i--) {
    //         if (!appointments[i].Is_Hidden_Appointment__c) {
    //             resultList.add(appointments[i]);
    //         }
    //     }

    //     System.debug('resultList: size: ' + resultList.size() + ' value: ' + resultList);
    //     return resultList;
    // }

    // private static List<Appointment__c> changeAppointmentName(List<Appointment__c> appointments) {
    //     System.debug('LC_SearchUtils.changeAppointmentName...\nappointments: ' + appointments);
    //     List<Appointment__c> resultList = new List<Appointment__c>();
    //     Map<Id, Appointment__c> afterToIdMap = new Map<Id, Appointment__c>();

    //     for (Appointment__c appointment_i : appointments) {
    //         if (String.isNotBlank(appointment_i.after_appointment__c)) {
    //             afterToIdMap.put(appointment_i.after_appointment__c, appointment_i);
    //         } else {
    //             resultList.add(appointment_i);
    //         }
    //     }
    //     System.debug('afterToIdMap: size: ' + afterToIdMap.size() + ' value: ' + afterToIdMap);

    //     for (Appointment__c appointment_i : resultList) {
    //         if (afterToIdMap.containsKey(appointment_i.Id)) {
    //             appointment_i.Name += ' -- ' + afterToIdMap.get(appointment_i.Id).Name;
    //             if (afterToIdMap.containsKey(afterToIdMap.get(appointment_i.Id).Id)) {
    //                 appointment_i.Name += ' -- ' + afterToIdMap.get(afterToIdMap.get(appointment_i.Id).Id).Name;
    //             }
    //         }
    //     }
    //     System.debug('resultList: size: ' + resultList.size() + ' value: ' + resultList);

    //     return resultList;
    // }
}