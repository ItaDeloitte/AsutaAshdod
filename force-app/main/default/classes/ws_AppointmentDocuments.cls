@RestResource(urlMapping='/AppointmentDocuments/*')
global with sharing class ws_AppointmentDocuments {        

    @HttpGet
    global static AppointmentDocumentsResponse getDocumentForApp() {
        RestRequest req = RestContext.request;
        String appointmentId = req.params.get('appointmentId');

        if (String.isBlank(appointmentId)) {
            return AppointmentDocumentsResponse.empty();
        }

        try {
            Appointment__c appointment = [
                SELECT Id, Related_document__c, Guidance_Scenario__c,
                        Guidance_Scenario__r.Guideline1__c,
                        Guidance_Scenario__r.Guideline2__c,
                        Guidance_Scenario__r.Guideline3__c,
                        Guidance_Scenario__r.Guideline4__c,
                        Guidance_Scenario__r.Guideline5__c,
                        Guidance_Scenario__r.Guideline6__c,
                        Guidance_Scenario__r.Guideline7__c,
                        Guidance_Scenario__r.Guideline8__c,
                        Guidance_Scenario__r.Guideline9__c,
                        Guidance_Scenario__r.Guideline10__c,
                        Guidance_Scenario__r.Guideline11__c,
                        Guidance_Scenario__r.Guideline12__c,
                        Guidance_Scenario__r.Guideline13__c,
                        Guidance_Scenario__r.Guideline14__c,
                        Guidance_Scenario__r.Guideline15__c,
                        Guidance_Scenario__r.Guideline16__c,
                        Guidance_Scenario__r.Guideline17__c,
                        Guidance_Scenario__r.Guideline18__c,
                        Guidance_Scenario__r.Guideline19__c,
                        Guidance_Scenario__r.Guideline20__c,
                        Guidance_Scenario__r.Guideline21__c
                FROM Appointment__c
                WHERE Id = :appointmentId
            ];

            return AppointmentDocumentsResponse.empty()
                .addRequiredAll(getRequiredDocuments(appointment))
                .addRelatedAll(getRelatedDocuments(appointment.Related_document__c));

        } catch (QueryException e) {
            System.debug('Appointment not found: ' + e.getMessage());
            return AppointmentDocumentsResponse.empty();
        } catch (Exception e) {
            System.debug('Unexpected error: ' + e.getMessage());
            return AppointmentDocumentsResponse.empty();            
        }
    }
    
    private static List<FileStatusDTO> getRequiredDocuments(Appointment__c appointment) {      
        Set<Id> guidelineIds = new Set<Id>();
        Set<String> requiredDocs = new Set<String>();  
         List<FileStatusDTO> result = new List<FileStatusDTO>();
        Map<String, Boolean> fileTypeMap = new Map<String, Boolean>();        

        for (Schema.SObjectField f : Guidance_Scenario__c.SObjectType.getDescribe().fields.getMap().values()) {
            if (f.getDescribe().getName().startsWith('Guideline') && f.getDescribe().getType() == Schema.DisplayType.Reference) {               
                Id guidId = (Id) appointment.getSObject('Guidance_Scenario__r').get(f.getDescribe().getName());
                if (guidId != null) {
                    guidelineIds.add(guidId);
                }
            }
        }

        System.debug('guidelineIds: ' + guidelineIds);
        if (guidelineIds.isEmpty()) return result;          
        
        for (Guidelines__c guide_i : [SELECT Id, Guideline_Type__c, Required_documents__c
                                        FROM Guidelines__c
                                        WHERE Id IN :guidelineIds
                                        AND Guideline_Type__c = 'D'
                                        AND Required_documents__c != null
        ]) {
            requiredDocs.addAll(guide_i.Required_documents__c.split(';'));                
        }
        
        
        System.debug('requiredDocs: ' + requiredDocs);
        if (requiredDocs.isEmpty()) return result;               
        
        for (AggregateResult ar : [SELECT File_Type__c ftype, COUNT(Id) cnt
                                    FROM File__c
                                    WHERE Appointment__c = :appointment.Id
                                    AND File_Type__c IN :requiredDocs
                                    GROUP BY File_Type__c
        ]) {                
            fileTypeMap.put((String)ar.get('ftype'), ((Integer)ar.get('cnt')) > 0);                
        }
              
        System.debug('fileTypeMap: ' + fileTypeMap);       
        for (String doc : requiredDocs) {
            Boolean found = fileTypeMap.containsKey(doc) && fileTypeMap.get(doc);
            result.add(found == true ? FileStatusDTO.found(doc) : FileStatusDTO.missing(doc));            
        }

        System.debug('result: ' + result);
        return result;
    }

    private static List<FileUrlDTO> getRelatedDocuments(Id relatedDocumentId) {
        List<FileUrlDTO> result = new List<FileUrlDTO>();
        if (relatedDocumentId == null) return result;

        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink link : [SELECT ContentDocumentId
                                         FROM ContentDocumentLink
                                         WHERE LinkedEntityId = :relatedDocumentId
        ]) {
            documentIds.add(link.ContentDocumentId);
        }

        if (documentIds.isEmpty()) return result;
       
        for (ContentVersion cv : [SELECT Id, CommercialName__c, RelatedDocumentUrl__c  
                                 FROM ContentVersion 
                                 WHERE ContentDocumentId IN :documentIds
                                 AND RelatedDocumentUrl__c != null
        ]) {
            result.add(FileUrlDTO.of(cv.Id, cv.CommercialName__c, cv.RelatedDocumentUrl__c));
        }

        return result;
    }    
}