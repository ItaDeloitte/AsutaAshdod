// Test: ContactServicesTest
// Created: Evgeniy Kravchuk
// Date: 27.05.2019
public class ContactTriggerDispatcher {
	
    public static Map<String, Schema.RecordTypeInfo> contactRTMap = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
    
    public static void checkIdNumberUniqueness(List<Contact> newList) {
        System.debug('ContactTriggerDispatcher.checkIdNumberUniqueness...');
        Map<String, Contact> idNumbersToContactMap = new Map<String, Contact>();
        Set<String> idNumbersSet = new Set<String>();

        for (Contact contact_i : newList) {
            if (contact_i.ID_Number__c != null) {
                contact_i.ID_Number__c = contact_i.ID_Number__c.length() < 9 ? '000000000'.substring(contact_i.ID_Number__c.length()) + contact_i.ID_Number__c : contact_i.ID_Number__c;
                if (!idNumbersToContactMap.containsKey(contact_i.ID_Number__c + contact_i.ID_Type__c)) {
                    idNumbersToContactMap.put(contact_i.ID_Number__c + contact_i.ID_Type__c, contact_i);
                    idNumbersSet.add(contact_i.ID_Number__c);
                } else {
                    contact_i.addError(System.Label.Id_number_should_be_unique);
                }
            }
        }

        if (!idNumbersToContactMap.isEmpty()) {
            System.debug('idNumbersToContactMap ' + idNumbersToContactMap);
            System.debug('idNumbersSet ' + idNumbersSet);
            ContactServices.checkIdNumberUniqueness(idNumbersToContactMap, idNumbersSet);
        }
    }

    public static void validateIdNumber(List<Contact> newList, Map<Id, Contact> oldMap) {
        System.debug('ContactTriggerDispatcher.validateIdNumber...');
        Map<String, Contact> idNumbersToContactMap = new Map<String, Contact>();

        for (Contact contact_i : newList) {
            if (contact_i.ID_Type__c == '1' && String.isNotBlank(contact_i.ID_Number__c) && (oldMap == null || contact_i.ID_Number__c != oldMap.get(contact_i.Id).ID_Number__c)) {
                String personIdTmp = contact_i.ID_Number__c.length() < 9 ? '000000000'.substring(contact_i.ID_Number__c.length()) + contact_i.ID_Number__c : contact_i.ID_Number__c;
                idNumbersToContactMap.put(personIdTmp, contact_i);
            }
        }

        if (!idNumbersToContactMap.isEmpty()) {
            System.debug('idNumbersToContactMap ' + idNumbersToContactMap);
            ContactServices.validateIdNumber(idNumbersToContactMap);
        }
    }
    
    /**
     * ----------------------------------------------------------------------------------------------------------------------------
     * This method replacing the old PB that responsinle to update a "General Account" as the contact account for all new contacts
     * that are created and dont have any Account linked to them.
     * 
     * Event            BEFORE_INSERT
     *----------------------------------------------------------------------------------------------------------------------------
     * @author           Max Feldman                 <maxf@assuta.co.il>
     * @created          19-08-2021
     * ----------------------------------------------------------------------------------------------------------------------------
     */

    public static void assignGeneralAccount(List<Contact> newList){
        List<Contact> invalidContacts = new List<Contact>(); 
        Id assutaEmpRTId = contactRTMap.get('Assuta_Employee').getRecordTypeId();
        for (Contact contact : newList) {
             if (contact.recordTypeId != assutaEmpRTId && contact.AccountId == null) {
                invalidContacts.add(contact);
            }
        }
        if(!invalidContacts.isEmpty()){
            ContactServices.assignGeneralAccount(invalidContacts);
        }
    }
}