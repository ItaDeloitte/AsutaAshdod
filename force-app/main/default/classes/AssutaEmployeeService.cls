// Test: AssutaEmployeeTriggerDispatcherTest
public class AssutaEmployeeService {

    public static void validateIdNumber(Map<String, Assuta_Employee__c> idNumbersToEmployeeMap) {
        System.debug('AssutaEmployeeService.validateIdNumber...');

        for (String idNumber_i : idNumbersToEmployeeMap.keySet()) {
            if (!ValidateUtil.isValidIdNumber(idNumber_i)) {
                idNumbersToEmployeeMap.get(idNumber_i).addError(System.Label.Person_Id_is_incorrect);
            }
        }
    }

    public static void createContact(Map<Id, Assuta_Employee__c> employeeIdsMap) {
        System.debug('AssutaEmployeeService.createContact...');                
        List<Contact> contactToInsert = new List<Contact>();
        List<Contact> contactToUpdate = new List<Contact>();
        Map<String, Id> idEmployeeToContactIdMap = new Map<String, Id>();
        Id assutaEmpRTId = ContactTriggerDispatcher.contactRTMap.get('Assuta_Employee').getRecordTypeId();
        for (Contact cont_i : [SELECT Id, AssutaEmployeeId__c FROM Contact WHERE AssutaEmployeeId__c IN :employeeIdsMap.keySet() AND RecordType.DeveloperName = 'Assuta_Employee']) {
            idEmployeeToContactIdMap.put(cont_i.AssutaEmployeeId__c, cont_i.Id);
        }
        if (!idEmployeeToContactIdMap.isEmpty()) {
            System.debug('idEmployeeToContactIdMap ' + idEmployeeToContactIdMap);
            for(String idEmployee_i : employeeIdsMap.keySet()) {
                if(idEmployeeToContactIdMap.containsKey(idEmployee_i) && idEmployeeToContactIdMap.get(idEmployee_i) != null) {
                   contactToUpdate.add(getContact(employeeIdsMap.get(idEmployee_i),  idEmployeeToContactIdMap.get(idEmployee_i), assutaEmpRTId));
                } else {
                   contactToInsert.add(getContact(employeeIdsMap.get(idEmployee_i), null, assutaEmpRTId)); 
                }                          
            }
        } else {
            for(String idEmployee_i : employeeIdsMap.keySet()) {   
                contactToInsert.add(getContact(employeeIdsMap.get(idEmployee_i), null, assutaEmpRTId));
            }
        }
        if (!contactToInsert.isEmpty()) {
            System.debug('contactToInsert ' + contactToInsert);   
            insert contactToInsert;
        } 
        if (!contactToUpdate.isEmpty()) {
            System.debug('contactToUpdate ' + contactToUpdate);   
            update contactToUpdate;
        }   
    }

    private static contact getContact(Assuta_Employee__c employee, Id contactId, Id assutaEmpRTId) {
        Contact contact = new Contact();
        if (contactId != null) {
            contact.Id = contactId;
        } else {            
            contact.ID_Type__c = '1';
            contact.recordTypeId = assutaEmpRTId;
            contact.AssutaEmployeeId__c = employee.Id;
        }
        contact.Email = employee.Email__c;
        contact.FirstName = employee.First_Name__c;
        contact.LastName = employee.Last_Name__c;
        contact.Status__c = employee.Status__c;
        contact.ID_Number__c = employee.ID_Assuta_Employee__c;
        return contact; 
    }
}