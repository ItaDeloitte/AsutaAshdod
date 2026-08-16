// Test: ContactServicesTest
// Created: Evgeniy Kravchuk
// Date: 27.05.2019
public class ContactServices {

    public static void checkIdNumberUniqueness(Map<String, Contact> idNumbersToContactMap, Set<String> idNumbersSet) {
        System.debug('ContactServices.checkIdNumberUniqueness...');

        List<Contact> contacts = [SELECT Id, ID_Number__c, ID_Type__c FROM Contact
                                  WHERE ID_Number__c IN :idNumbersSet];

        if (!contacts.isEmpty()) {
            System.debug('contacts ' + contacts);
            for (Contact contact_i : contacts) {
                if (idNumbersToContactMap.containsKey(contact_i.ID_Number__c + contact_i.ID_Type__c)) {
                    idNumbersToContactMap.get(contact_i.ID_Number__c + contact_i.ID_Type__c).addError(System.Label.Id_number_should_be_unique);
                }
            }
        }
    }

    public static void validateIdNumber(Map<String, Contact> idNumbersToContactMap) {
        System.debug('ContactServices.validateIdNumber...');

        for (String idNumber_i : idNumbersToContactMap.keySet()) {
            if (!ValidateUtil.isValidIdNumber(idNumber_i)) {
                idNumbersToContactMap.get(idNumber_i).addError(System.Label.Person_Id_is_incorrect);
            }
        }
    }

    public static void assignGeneralAccount(List<Contact> contacts){
        System.debug('ContactServices.assignGeneralAccount...');
        Account generalAccount = [SELECT Id FROM Account WHERE RecordType.Developername = 'General_Account' AND Name='General Account' AND ID_Number__c =null LIMIT 1];
        if(generalAccount!=null){
            for (Contact contact : contacts) {
                contact.AccountId=generalAccount.Id;
            }
        }
        
    }
}