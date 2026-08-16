public with sharing class RelatedDocumentTriggerDispatcher {
    
    public static void checkDuplicateRecords(List<Related_document__c> newList, Map<Id, Related_document__c> oldMap) {
        System.debug('LOG Related_document__c checkDuplicateRecords2 ... start');
        List<RelatedDocumentTriggerService.RDWR> rdwrs = new List<RelatedDocumentTriggerService.RDWR>();

        for (Related_document__c rd_i : newList) {
            if (rd_i.Active__c && !rd_i.GastroGuidelines__c &&                
                    (oldMap == null ||
                    !oldMap.get(rd_i.Id).Active__c ||
                    oldMap.get(rd_i.Id).Medical_Procedure__c != rd_i.Medical_Procedure__c ||
                    oldMap.get(rd_i.Id).AppointmentRecordType__c != rd_i.AppointmentRecordType__c ||
                    oldMap.get(rd_i.Id).Language__c != rd_i.Language__c ||
                    oldMap.get(rd_i.Id).Site__c != rd_i.Site__c ||
                    oldMap.get(rd_i.Id).Asthma__c != rd_i.Asthma__c ||
                    oldMap.get(rd_i.Id).Iodine_sensitivity__c != rd_i.Iodine_sensitivity__c ||
                    oldMap.get(rd_i.Id).FromHour__c != rd_i.FromHour__c ||
                    oldMap.get(rd_i.Id).ToHour__c != rd_i.ToHour__c)) {
                rdwrs.add(new RelatedDocumentTriggerService.RDWR(rd_i));
            }
        }
        System.debug('rdwrs: size: ' + rdwrs.size() + ' value: ' + rdwrs);

        if (!rdwrs.isEmpty()) {
            RelatedDocumentTriggerService.checkDuplicateRecords(rdwrs);
        }
    }
}