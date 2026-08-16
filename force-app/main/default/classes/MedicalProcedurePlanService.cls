public with sharing class MedicalProcedurePlanService {

    public static List<MedicalPlanResponse> getMedicalPlanSettings(List<MedicalPlanRequest> requests) {

        Map<String, Boolean> configMap = getMetadata();

        List<MedicalPlanResponse> response = new List<MedicalPlanResponse>();

        for (MedicalPlanRequest req : requests) {
            if (req.procedureCode1 == null && req.procedureCode2 == null) return response;

            MedicalPlanResponse res = new MedicalPlanResponse();
            res.procedureCode = req.procedureCode1 != null ? req.procedureCode1: req.procedureCode2;                        
            res.siteCode = req.siteCode;
            res.found = false;
            res.sendMessage = false;

            String key = req.procedureCode1 != null ? buildKey(req.siteCode, req.procedureCode1)
                                                    : buildKey(req.siteCode, req.procedureCode2);
            if (configMap.containsKey(key)) {                        
                res.sendMessage = configMap.get(key);
                res.found = true;
            }
            response.add(res);
        }
        
        System.debug('response ' + response);
        return response;
    }

    private static Map<String, Boolean> getMetadata() {

        Map<String, Boolean> mapResult = new Map<String, Boolean>();

        for (Medical_Procedure_Plan_All__mdt md : [
            SELECT ProcedureCode1__c,
                   ProcedureCode2__c,                   
                   SiteCode__c,
                   SendMessageMP1__c,
                   SendMessageMP2__c
            FROM Medical_Procedure_Plan_All__mdt
        ]) {
            mapResult.put(
                buildKey(md.SiteCode__c, md.ProcedureCode1__c), md.SendMessageMP1__c
            );
            mapResult.put(
                buildKey(md.SiteCode__c, md.ProcedureCode2__c), md.SendMessageMP2__c
            );
        }
        return mapResult;
    }

    private static String buildKey(String site, String procedure) {
        return site + '|' + procedure;
    }

    public class MedicalPlanRequest {
        @InvocableVariable
        public String procedureCode1;

        @InvocableVariable
        public String procedureCode2;        

        @InvocableVariable(required=true)
        public String siteCode;
    }

    public class MedicalPlanResponse {
        @InvocableVariable 
        public String procedureCode;        
        @InvocableVariable 
        public String siteCode;
        @InvocableVariable 
        public Boolean found;
        @InvocableVariable 
        public Boolean sendMessage;        
    }

    @InvocableMethod(label='Get Medical Procedure Plan Settings')
    public static List<MedicalPlanResponse> getMedicalPlanFLOW(List<MedicalPlanRequest> requests) {
        System.debug('requests ' + requests);
        return getMedicalPlanSettings(requests);
    }
}