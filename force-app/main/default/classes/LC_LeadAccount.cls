// Test: LC_LeadAccountTest
// Created: Ortal kazum
// Date: 13.01.2021
public class LC_LeadAccount implements ILCController {

    public class LC_LeadAccountException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainAccounts' {
                return this.obtainAccounts((String) params.get('leadId'), (String) params.get('accountName'));
            }
            when 'setAccount'{
                return this.setAccount((String) params.get('leadId'), (String) params.get('accountId'));
            }
            when 'getAccount'{
                return this.getAccount((String) params.get('leadId'));
            }
            when else {
                throw new LC_LeadAccountException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response obtainAccounts(String leadId, String accountName) {
        System.debug('LC_LeadAccount.obtainAccounts...\nleadId: ' + leadId + '\naccountName: ' + accountName);
        Lead lead = [SELECT Id, Email, Phone, LastName, FirstName FROM Lead WHERE Id =: leadId];
        System.debug('lead: ' + lead);
        accountName = '%' + accountName + '%';
        List<Account> accts = new List<Account>();
    
        if (lead.Phone == null && lead.Email == null) { 
            return new Response(accts);
        }

        String phone = lead.Phone;
        String email = lead.Email;
        String lastName = lead.LastName;
        String firstName = lead.FirstName;
       
        String query = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = \'PersonAccount\' AND Name LIKE: accountName AND LastName =: lastName AND FirstName = :firstName';
        if(lead.Phone != null && lead.Email != null){
            query += ' AND (Phone = :phone OR PersonEmail = :email)';
        }else if(lead.Phone != null){
            query += ' AND Phone = :phone';
        }else{
            query += ' AND PersonEmail = :email';
        }
        query += ' LIMIT 50';
        System.debug('query' + query);
        accts = Database.query(query);
        System.debug('accts: size: ' + accts.size() + ' value: ' + accts);
        return new Response(accts);
    }

    private Response setAccount(String leadId, String accountId) {
        System.debug('LC_LeadAccount.setAccount...\nleadId: ' + leadId + '\naccountId: ' + accountId);
        Lead lead = new Lead(Id = leadId, ExistingAccount__c = String.isBlank(accountId) ? null : accountId);
        update lead;
        System.debug('lead: ' + lead);

        return new Response('success');
    }

    private Response getAccount(String leadId) {
        System.debug('LC_LeadAccount.getAccount...\nleadId: ' + leadId);
        Lead lead = [SELECT Id, ExistingAccount__r.Name, ExistingAccount__c FROM Lead WHERE Id =: leadId];
        System.debug('lead: ' + lead);
        Boolean isUpdate = false;

        List<Account> accts = (List<Account>) this.obtainAccounts(leadId, '').responseObj;
        // assign account if only single one found
        if (accts.size() == 1) {
            lead.ExistingAccount__c = accts.get(0).Id;
            lead.ExistingAccount__r = accts.get(0);
            isUpdate = true;
        }
        if (isUpdate) {
            update lead;
        }

        if (lead.ExistingAccount__c == null) {
            return new Response(new Account());
        }

        return new Response(new Account(Id = lead.ExistingAccount__c, Name = lead.ExistingAccount__r.Name));
    }
}