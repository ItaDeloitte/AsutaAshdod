public with sharing class RequiredDocuments {

    public static void updateStatus(Set<Id> appointmentIds) {

        Map<Id, Appointment__c> appointments = new Map<Id, Appointment__c>([
            SELECT Id, Guidance_Scenario__c
            FROM Appointment__c
            WHERE Id IN :appointmentIds
        ]);

        Set<Id> scenarioIds = new Set<Id>();
        for (Appointment__c app : appointments.values()) {
            if (app.Guidance_Scenario__c != null) {
                scenarioIds.add(app.Guidance_Scenario__c);
            }
        }
        System.debug('scenarioIds ' + scenarioIds);
        if (scenarioIds.isEmpty()) return;

        List<Guidance_Scenario__c> scenarios = [
            SELECT
                Guideline1__r.Guideline_Type__c,  Guideline1__r.Required_documents__c,
                Guideline2__r.Guideline_Type__c,  Guideline2__r.Required_documents__c,
                Guideline3__r.Guideline_Type__c,  Guideline3__r.Required_documents__c,
                Guideline4__r.Guideline_Type__c,  Guideline4__r.Required_documents__c,
                Guideline5__r.Guideline_Type__c,  Guideline5__r.Required_documents__c,
                Guideline6__r.Guideline_Type__c,  Guideline6__r.Required_documents__c,
                Guideline7__r.Guideline_Type__c,  Guideline7__r.Required_documents__c,
                Guideline8__r.Guideline_Type__c,  Guideline8__r.Required_documents__c,
                Guideline9__r.Guideline_Type__c,  Guideline9__r.Required_documents__c,
                Guideline10__r.Guideline_Type__c, Guideline10__r.Required_documents__c,
                Guideline11__r.Guideline_Type__c, Guideline11__r.Required_documents__c,
                Guideline12__r.Guideline_Type__c, Guideline12__r.Required_documents__c,
                Guideline13__r.Guideline_Type__c, Guideline13__r.Required_documents__c,
                Guideline14__r.Guideline_Type__c, Guideline14__r.Required_documents__c,
                Guideline15__r.Guideline_Type__c, Guideline15__r.Required_documents__c,
                Guideline16__r.Guideline_Type__c, Guideline16__r.Required_documents__c,
                Guideline17__r.Guideline_Type__c, Guideline17__r.Required_documents__c,
                Guideline18__r.Guideline_Type__c, Guideline18__r.Required_documents__c,
                Guideline19__r.Guideline_Type__c, Guideline19__r.Required_documents__c,
                Guideline20__r.Guideline_Type__c, Guideline20__r.Required_documents__c,
                Guideline21__r.Guideline_Type__c, Guideline21__r.Required_documents__c,
                Guideline22__r.Guideline_Type__c, Guideline22__r.Required_documents__c,
                Guideline23__r.Guideline_Type__c, Guideline23__r.Required_documents__c
            FROM Guidance_Scenario__c
            WHERE Id IN :scenarioIds
        ];
        System.debug('scenarios ' + scenarios);
        Map<Id, Set<String>> scenarioToRequiredDocs = new Map<Id, Set<String>>();
        for (Guidance_Scenario__c gs : scenarios) {
            Set<String> requiredDocs = new Set<String>();
            for (Integer i = 1; i <= 23; i++) {
                SObject guideline = gs.getSObject('Guideline' + i + '__r');
                if (guideline == null) continue;
                String type = (String) guideline.get('Guideline_Type__c');
                if (type == 'D') {
                    String docs = (String) guideline.get('Required_documents__c');
                    if (!String.isBlank(docs)) {
                        requiredDocs.addAll(docs.split(';'));
                    }
                }
            }

            if (!requiredDocs.isEmpty()) {
                scenarioToRequiredDocs.put(gs.Id, requiredDocs);
            }
        }
        System.debug('scenarioToRequiredDocs ' + scenarioToRequiredDocs);
        if (scenarioToRequiredDocs.isEmpty()) return;

        Map<Id, Set<String>> uploadedDocs = new Map<Id, Set<String>>();

        for (AggregateResult ar : [
            SELECT Appointment__c appId, File_Type__c ftype
            FROM File__c
            WHERE Appointment__c IN :appointmentIds
            GROUP BY Appointment__c, File_Type__c
        ]) {

            Id appId = (Id) ar.get('appId');
            if (!uploadedDocs.containsKey(appId)) {
                uploadedDocs.put(appId, new Set<String>());
            }
            uploadedDocs.get(appId).add((String) ar.get('ftype'));
        }
        System.debug('uploadedDocs ' + uploadedDocs);
        List<Appointment__c> AppointmentsToUpdate = new List<Appointment__c>();
        for (Appointment__c app : appointments.values()) {
            Set<String> required = scenarioToRequiredDocs.get(app.Guidance_Scenario__c);

            if (required == null || required.isEmpty()) {
                continue;
            }

            Set<String> uploaded = uploadedDocs.get(app.Id);
            if (uploaded == null || uploaded.isEmpty()) {
                AppointmentsToUpdate.add(new Appointment__c(
                    Id = app.Id,
                    Required_documents_status__c = 'AppointmentsToUpdate'
                    ));
            }
            else if (uploaded.containsAll(required)) {
                AppointmentsToUpdate.add(new Appointment__c(
                    Id = app.Id,
                    Required_documents_status__c = 'AllUploaded'
                ));
            }
            else {
                AppointmentsToUpdate.add(new Appointment__c(
                    Id = app.Id,
                    Required_documents_status__c = 'SomeUploaded'
                ));
            }
        }
        System.debug('AppointmentsToUpdate ' + AppointmentsToUpdate);
        if (!AppointmentsToUpdate.isEmpty()) {
            update AppointmentsToUpdate;
        }
    }
}