public with sharing class ShowDocFromPortal {

    public static String urlJSON {get; private set;}
    public static String idNumberJSON {get; private set;}

    public ShowDocFromPortal(ApexPages.StandardController stdController) {
        File__c file = [SELECT Id, URL__c, Account__c, Case__c FROM File__c WHERE Id=:stdController.getRecord().Id];
        System.debug('file: '+file); 
        if(file.Account__c != null && file.URL__c != null){
            List<Account> acc = [SELECT Id, ID_Number__c FROM Account WHERE Id=:file.Account__c];
            idNumberJSON = JSON.serialize(acc[0].ID_Number__c);
            urlJSON = JSON.serialize(file.URL__c);
        } else if(file.Case__c != null && file.URL__c != null){
            String accNumber = [SELECT Id, AccountId, Patient_ID__c FROM Case WHERE Id=:file.Case__c].Patient_ID__c;
            idNumberJSON = JSON.serialize(accNumber);
            urlJSON = JSON.serialize(file.URL__c);
        }
    }


    @RemoteAction
    public static String getPDF(String url, String idNumber) {
        String base = ws_DocumentsSyncPortalREST.portalGetDocument(url, idNumber);    
        return base;
    }

    

}