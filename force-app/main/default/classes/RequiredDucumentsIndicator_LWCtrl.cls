public with sharing class RequiredDucumentsIndicator_LWCtrl {

    @AuraEnabled
    public static String getRequiredDocInfo(String appointmentId){
        
        try {
            List<String> requiredDocs = new List<String>();
            List<String> uploadedDocs = new List<String>();
            Map<String, String> docLabels = getRequiredDocLabels();
            List<Appointment__c> appList = [SELECT Guidance_Scenario__c FROM Appointment__c WHERE Id =:appointmentId];
            Boolean flagToContinue = true;
            if (!appList.isEmpty()) {
                Id guidId = appList[0].Guidance_Scenario__c;
                List<Guidance_Scenario__c> gscenList = [SELECT Guideline1__r.Guideline_Type__c,  Guideline1__r.Required_documents__c,
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
                                                    WHERE Id = :guidId
                                                    LIMIT 1];
                if (gscenList.size() > 0){
                    Guidance_Scenario__c gscen = gscenList[0];
                    for (Integer i = 1; i <= 23; i++) {
                        SObject rel = gscen.getSObject('Guideline' + i + '__r');
                        if (rel == null) continue;

                        String typeVal = (String) rel.get('Guideline_Type__c');
                        if (typeVal == 'D') {
                            String docs = (String) rel.get('Required_documents__c');
                            if (!String.isBlank(docs)) {
                                // multipicklist values come semicolon-delimited; adjust if your field uses commas
                                requiredDocs = docs.split(';');
                            }
                            break;
                        }
                    }   
                    
                    for(File__c file : [SELECT Id, file_type__c FROM File__c WHERE Appointment__c =:appointmentId]){
                        uploadedDocs.add(file.file_type__c);
                    }

                    System.debug('requiredDocs = ' + requiredDocs);
                    System.debug('uploadedDocs = ' + uploadedDocs);

                    List<DocInfo> docsInfoList = new List<DocInfo>();
                    for(String reqDocType : requiredDocs){
                        DocInfo docInfo = new DocInfo();
                        if(!uploadedDocs.contains(reqDocType)){
                        docInfo.docName = docLabels.containsKey(reqDocType) ? docLabels.get(reqDocType) : reqDocType;
                        docInfo.isUploaded = false;
                        } else {
                        docInfo.docName = docLabels.containsKey(reqDocType) ? docLabels.get(reqDocType) : reqDocType;
                        docInfo.isUploaded = true;
                        }
                        System.debug('docInfo = ' + docInfo);

                        docsInfoList.add(docInfo);
                        System.debug('docsInfoList = ' + docsInfoList);
                    }
                    return JSON.serialize(docsInfoList);     
                }
            }               
            return 'There is no required documents for this appointment';
                                                  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, String> getRequiredDocLabels() {
        Map<String, String> labels = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Guidelines__c.Required_documents__c.getDescribe();

        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            labels.put(entry.getValue(), entry.getLabel());
        }
        return labels;
    }

    private class DocInfo{
        public String docName;
        public Boolean isUploaded;
    }
}