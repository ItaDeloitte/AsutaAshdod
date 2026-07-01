// Test: LC_CasePatientAccountTest
// Created: Ortal kazum
// Date: 30.06.2021
public class LC_CasePatientAccount implements ILCController {

    public class LC_CasePatientAccountException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'obtainAccounts' {
                return this.obtainAccounts((String) params.get('caseId'), (String) params.get('accountName'));
            }
            when 'setAccount'{
                return this.setAccount((String) params.get('caseId'), (String) params.get('accountId'));
            }
            when 'getAccount'{
                return this.getAccount((String) params.get('caseId'));
            }
            when else {
                throw new LC_CasePatientAccountException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response obtainAccounts(String caseId, String accountName) {
        System.debug('LC_CasePatientAccount.obtainAccounts...\ncaseId: ' + caseId + '\naccountName: ' + accountName);
        Case cas = [SELECT Id, SuppliedEmail FROM Case WHERE Id =: caseId];
        System.debug('cas: ' + cas);
        accountName = '%' + accountName + '%';
        List<Account> accts = new List<Account>();
    
        if (cas.SuppliedEmail == null) { 
            return new Response(accts);
        }

        String email = cas.SuppliedEmail;
        String query = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = \'PersonAccount\' AND Name LIKE: accountName AND PersonEmail = :email';
        query += ' LIMIT 50';
        System.debug('query' + query);
        accts = Database.query(query);
        System.debug('accts: size: ' + accts.size() + ' value: ' + accts);
        return new Response(accts);
    }

    private Response setAccount(String caseId, String accountId) {
        System.debug('LC_CasePatientAccount.setAccount...\ncaseId: ' + caseId + '\naccountId: ' + accountId);
        Case cas = new Case(Id = caseId, AccountId = String.isBlank(accountId) ? null : accountId);
        update cas;
        System.debug('cas: ' + cas);

        return new Response('success');
    }

    private Response getAccount(String caseId) {
        System.debug('LC_CasePatientAccount.getAccount...\ncaseId: ' + caseId);
        Case cas = [SELECT Id, Account.Name, AccountId FROM Case WHERE Id =: caseId];
        System.debug('cas: ' + cas);
        
        
        if (cas.AccountId == null) {
            Boolean isUpdate = false;
            
            List<Account> accts = (List<Account>) this.obtainAccounts(caseId, '').responseObj;
            // assign account if only single one found
            if (accts.size() == 1) {
                cas.AccountId = accts.get(0).Id;
                isUpdate = true;
            }
            if (isUpdate) {
                update cas;
            }
            if (cas.AccountId == null) {
            	return new Response(new Account());
        	}
        }
        return new Response(new Account(Id = cas.AccountId, Name = cas.Account.Name));
    }
}