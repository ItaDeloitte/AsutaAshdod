//Test: ResetAmbulatoryLimitationScheduleTest
global class ResetAmbulatoryLimitationScheduleBatch implements Database.Batchable<SObject> {    

    public ResetAmbulatoryLimitationScheduleBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('ResetAmbulatoryLimitationScheduleBatch.start ...'); 
        Date today = Date.today();
        Date tomorrow = today.addDays(1);
        List<Date> dates = new List<Date> {today, tomorrow};
        return Database.getQueryLocator([
            SELECT Id                  
                  , List_of_Prohibitions__c
                  , AmbulatoryLimitationEndDate__c
                  , Patient_not_entitled_for_ambulatory__c
            FROM Account
             WHERE AmbulatoryLimitationEndDate__c IN :dates
              AND (Patient_not_entitled_for_ambulatory__c = TRUE 
                   OR List_of_Prohibitions__c != null)
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('ResetAmbulatoryLimitationScheduleBatch.execute ...');
        Date today = Date.today();
        List<Account> accountToUpdateList = new List<Account>();
        List<EmailMessage> emailMessageToInsertList = new List<EmailMessage>(); 
        EmailTemplate ambulatoryLimitationTemplate = obtainEmailTemplate();        
        String emailAddress = System.Label.Ambulatory_Limitation_Email_Address;
        List<String> toAddress = emailAddress.split(',');

        for (Account acc_i : scope) {
            if (acc_i.AmbulatoryLimitationEndDate__c == today) {            
                accountToUpdateList.add(new Account(Id = acc_i.Id
                                                    , Patient_not_entitled_for_ambulatory__c = false
                                                    , List_of_Prohibitions__c = null));
            } else if(acc_i.AmbulatoryLimitationEndDate__c == today.addDays(1)) {                
                if (ambulatoryLimitationTemplate == null) {
                    continue;
                }            
                emailMessageToInsertList.add(prepareEmailMessage(acc_i, ambulatoryLimitationTemplate, toAddress.get(0)));
                emailMessageToInsertList.add(prepareEmailMessage(acc_i, ambulatoryLimitationTemplate, toAddress.get(1)));
            }         
        }
        
        System.debug('accountToUpdateList: size: ' + accountToUpdateList.size() + ' value: ' + accountToUpdateList);
        if (!accountToUpdateList.isEmpty()) {
            update accountToUpdateList;
        }  
        
        System.debug('emailMessageToInsertList: size: ' + emailMessageToInsertList.size() + ' value: ' + emailMessageToInsertList);
        if (!emailMessageToInsertList.isEmpty()) {
            AsyncUtil.doInsert(emailMessageToInsertList);
        }
    }

    private EmailTemplate obtainEmailTemplate() {
        List<EmailTemplate> emailTemplateList = [SELECT Id
                                                      , DeveloperName 
                                                   FROM EmailTemplate 
                                                  WHERE DeveloperName = 'ambulatoryLimitation'];

        return emailTemplateList.isEmpty() ? null : emailTemplateList.get(0);
    }

    private static EmailMessage prepareEmailMessage(Account account, EmailTemplate template, String toAddress) {
        return new EmailMessage(            
            EmailTemplateId = template.Id,
            ToAddress = toAddress,
            FromAddress = 'nonreply@assuta.co.il',
            AccountId__c = account.Id,
            TemplateMergeField__c = 'AccountId__c',
            ExpectedSendingDateTime__c = Datetime.now(),
            EmailTemplateDeveloperName__c = template.DeveloperName,
            Automation_name__c = 'ResetAmbulatoryLimitationScheduleBatch');
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('ResetAmbulatoryLimitationScheduleBatch.finish ...');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new ResetAmbulatoryLimitationScheduleBatch(), 25);
    }  
}