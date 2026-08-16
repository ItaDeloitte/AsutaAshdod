public with sharing class displayHistoricCalls {

    @AuraEnabled(cacheable=true)
    public static List<dbo_CONV_SF_Activity_Fields_c__x> checkHistoricCalls (Id accountId){
        System.debug('accountId is->' + accountId);
        
        // get the id number from the account
        String accountIdNum = '';
        List<Account> getIdNumber = [SELECT ID_Number__c FROM Account WHERE id =: accountId];
        for(Account acc: getIdNumber){
            accountIdNum = acc.ID_Number__c;

        }
        System.debug('accountIdNum is->' + accountIdNum);
        List<dbo_CONV_SF_Activity_Fields_c__x> bla = new List<dbo_CONV_SF_Activity_Fields_c__x>();
        List<dbo_CONV_SF_Activity_Fields_c__x> displayExternalHistory =[
            SELECT Call_date__c, Call_Results__c, Comments__c,
            Patient_ID__c, Patient_Phone_No__c, Phone_for_callback__c, Callback_status__c,
            Owner__c, Direction__c FROM dbo_CONV_SF_Activity_Fields_c__x WHERE Patient_ID__c =:accountIdNum];
        System.debug('displayExternalHistory' + displayExternalHistory);
            if(displayExternalHistory.size()>0){
                System.debug('there is a result!' +displayExternalHistory);
                return displayExternalHistory;
            }
            else{
                System.debug('no results found....');
                return bla;
            }
    }
}