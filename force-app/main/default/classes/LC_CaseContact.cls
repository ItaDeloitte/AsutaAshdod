// Test: LC_CaseContactTest
public class LC_CaseContact implements ILCController {

    public class LC_CaseContactException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainContacts' {
                return this.obtainContacts((String) params.get('caseId'), (String) params.get('contactName'));
            }
            when 'setContact'{
                return this.setContact((String) params.get('caseId'), (String) params.get('contactId'));
            }
            when 'getContact'{
                return this.getContact((String) params.get('caseId'));
            }
            when else {
                throw new LC_CaseContactException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response obtainContacts(String caseId, String contactName) {
        System.debug('LC_CaseContact.obtainContacts...\ncaseId: ' + caseId);
        Set<Id> contactIds = new Set<Id>();
        contactName = contactName + '%';

        Case cas = [SELECT Id, AccountId, Identification_needed__c FROM Case WHERE Id =: caseId];
        System.debug('cas: ' + cas);

        List<Contact> currentContact = [SELECT Id FROM Contact WHERE AccountId =: cas.AccountId];
        if(!currentContact.isEmpty()){
            contactIds.add(currentContact[0].Id);
        }

        if (cas.Identification_needed__c != null) {
            if (cas.Identification_needed__c.contains('0154J000000cXlO') || cas.Identification_needed__c.contains('0154J000000IfAH')) {
                for (AccountContactRelation relation_i : [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: cas.AccountId AND Contact_Not_Active__c = FALSE
                                                          AND (title__c = 'בסיסי' OR title__c = 'רגיל' OR title__c = 'מחמיר') AND status__c = 'מאושר']) {
                    contactIds.add(relation_i.ContactId);
                }
            } else if (cas.Identification_needed__c.contains('0154J000000cXlM') || cas.Identification_needed__c.contains('0154J000000IfAC')) {
                for (AccountContactRelation relation_i : [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: cas.AccountId AND Contact_Not_Active__c = FALSE
                                                          AND (title__c = 'רגיל' OR title__c = 'מחמיר') AND status__c = 'מאושר']) {
                    contactIds.add(relation_i.ContactId);
                }
            } else if (cas.Identification_needed__c.contains('0154J000000cXlN') || cas.Identification_needed__c.contains('0154J000000IfA7')) {
                for (AccountContactRelation relation_i : [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: cas.AccountId AND Contact_Not_Active__c = FALSE
                                                          AND title__c = 'מחמיר' AND status__c = 'מאושר']) {
                    contactIds.add(relation_i.ContactId);
                }
            }
        }

        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id IN: contactIds AND Name LIKE: contactName];
        System.debug('contacts: size: ' + contacts.size() + ' value: ' + contacts);

        return new Response(contacts);
    }

    private Response setContact(String caseId, String contactId) {
        System.debug('LC_CaseContact.setContact...\ncaseId: ' + caseId + ' contactId: ' + contactId);
        Case cas = new Case(Id = caseId);
        cas.ContactId = String.isBlank(contactId) ? null : contactId;
        update cas;
        System.debug('cas: ' + cas);

        return new Response('success');
    }

    private Response getContact(String caseId) {
        System.debug('LC_CaseContact.setContact...\ncaseId: ' + caseId);
        Case cas = [SELECT Id, ContactId, Contact.Name FROM Case WHERE Id =: caseId];
        Contact con = new Contact();
        if (String.isNotBlank(cas.ContactId)) {
            con = [SELECT Id, Name FROM Contact WHERE Id =: cas.ContactId];
        }
        System.debug('con: ' + con);

        return new Response(con);
    }
}