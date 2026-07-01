public class LC_LiveAgentController implements ILCController {
    public class LC_LiveAgentControllerException extends Exception {}
    
    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getFormData' {
                return this.getFormData();
            }
            when else {
                throw new LC_LiveAgentControllerException('UNKNOWN ACTION ' + actionName);
            }
        }
    }
    
    public class FormDataWrapper {
        @AuraEnabled
        public List <RecordTypeWrapper> recordTypesList {get;set;}
        @AuraEnabled
        Map <String, List<PicklistUtil.PicklistValue>> recordTypeToSubjectMap {get;set;}
        @AuraEnabled
        Map <String, List<PicklistUtil.PicklistValue>> subjectToSubSubjectMap {get;set;}

        public FormDataWrapper(){
            this.recordTypesList = new List <RecordTypeWrapper> ();
            this.subjectToSubSubjectMap = new Map <String, List<PicklistUtil.PicklistValue>> ();//recordypeToSubjectMap
            this.recordTypeToSubjectMap = new Map <String, List<PicklistUtil.PicklistValue>> ();
        }
    }

    public class RecordTypeWrapper {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String DeveloperName {get;set;}
        @AuraEnabled
        public String Description {get;set;}
    
        public RecordTypeWrapper (RecordType currentRt){
            this.id = currentRt.id;
            this.Name = currentRt.Name;
            this.DeveloperName = currentRt.DeveloperName;
            this.Description = currentRt.Description;
        }

    }
    
    public Response getFormData(){
        List <RecordType> rtList = [SELECT ID, DeveloperName, Name, Description FROM RecordType WHERE SobjectType = 'Case' AND IsActive = true AND DeveloperName != 'Doctor_Case'AND DeveloperName != 'Assuta_360' ];
        Map <String, List <PicklistUtil.PicklistValue>> rtToSubjectValuesMap = new Map <String, List <PicklistUtil.PicklistValue>> ();
        FormDataWrapper resultWrapper = new FormDataWrapper();
        resultWrapper.recordTypesList = new List <RecordTypeWrapper> ();
        resultWrapper.subjectToSubSubjectMap = PicklistUtil.buildDependedPicklistSchema('Case', 'Case_subject__c', 'sub_case_subject__c');
        
        List <CaseSubject2RTMapping__c> mappingList = [SELECT ID, Name, Name__c, 
                                                         onAppointments__c, onDOC_expert__c, 
                                                         onDoctor_Case__c, onGeneral_Info__c, onSurgery__c 
                                                    FROM CaseSubject2RTMapping__c];

        Map <String, PicklistUtil.PicklistValue> valueToObjectMap = new Map <String, PicklistUtil.PicklistValue> ();
        for (PicklistUtil.PicklistValue util_I : PicklistUtil.buildPickListOptionsBySchema('Case', 'Case_subject__c', false)){
           valueToObjectMap.put(util_I.value, util_I);     
        }

        for (RecordType rt_I : rtList){
            rtToSubjectValuesMap.put(rt_I.Id, new List <PicklistUtil.PicklistValue> ());
            for (CaseSubject2RTMapping__c mapping_i : mappingList){
                if ((Boolean)mapping_i.get('on'+rt_I.DeveloperName+'__c')){
                    rtToSubjectValuesMap.get(rt_I.Id).add(valueToObjectMap.get(mapping_i.Name__c));
                }
            }
        }
        resultWrapper.recordTypeToSubjectMap = rtToSubjectValuesMap;
        for (RecordType rt_I : rtList){
            resultWrapper.recordTypesList.add(new RecordTypeWrapper(rt_I));
        }
        return new Response(resultWrapper);
    }

   
}