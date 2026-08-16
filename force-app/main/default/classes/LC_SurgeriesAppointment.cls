// Test : LC_SurgeriesAppointmentTest
public with sharing class LC_SurgeriesAppointment implements ILCController {

    public class LC_SurgeriesAppointmentException extends Exception {}

    public static final Map<String, Schema.RecordTypeInfo> APPT_RT_MAP = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName();
    public static final Map<String, Schema.RecordTypeInfo> CASE_RT_MAP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

    public Response executeAction (Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'isAvailable' {
                return this.isAvailable(
                    (String) params.get('caseId'));
            }
            when 'prepopulateField' {
                return this.prepopulateField(
                    (String) params.get('caseId'));
            }
            when else {
                throw new LC_SurgeriesAppointmentException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    public Response isAvailable(String caseId) {
        Id surgeryRTId = CASE_RT_MAP.get('Surgery').getRecordTypeId();
        Id caseAfterSaleRTId = CASE_RT_MAP.get('CaseAfterSale').getRecordTypeId();

        List<Case> caseList = [
            SELECT Id
              FROM Case
             WHERE Id =: caseId
               AND (RecordTypeId =: caseAfterSaleRTId OR RecordTypeId =: surgeryRTId)];
        System.debug('caseList: size: ' + caseList.size() + ' value: ' + caseList);

        return new Response(!caseList.isEmpty());
    }

    public Response prepopulateField(String caseId) {
        Id surgeriesRTId = APPT_RT_MAP.get('Surgeries').getRecordTypeId();
        Id caseAfterSaleRTId = CASE_RT_MAP.get('CaseAfterSale').getRecordTypeId();

        Case cas = [
            SELECT Id
                 , AccountId
                 , RecordTypeId
              FROM Case
             WHERE Id =: caseId];
        System.debug('cas: ' + cas);

        Appointment__c appt = new Appointment__c(
            Patient_Account__c = cas.AccountId,
            RecordTypeId = surgeriesRTId,
            Case__c = cas.Id,
            Name = 'פגישה חדשה',
            SourceSystem__c = 'Manual');

        if (cas.RecordTypeId == caseAfterSaleRTId) {
            Opportunity oppt = [
                SELECT Id
                  FROM Opportunity
                 WHERE Case__c =: cas.Id
                 LIMIT 1];
            appt.Opportunity__c = oppt.Id;
        }
        System.debug('appt: ' + appt);

        return new Response(appt);
    }
}