// Test: LC_FillAccountTest
public with sharing class LC_FillAccountUtil {

    public class LC_FillAccountException extends Exception {}

    public static Opportunity obtainOpportunityDetails(String opptId) {
        Opportunity oppt;

        List<Opportunity> opptList = [
            SELECT Id
                 , Name
                 , AccountId
              FROM Opportunity
             WHERE Id =: opptId
             LIMIT 1];

        if (!opptList.isEmpty()) {
            oppt = opptList.get(0);
        }

        return oppt;
    }

    public static Account obtainAccountDetails(String acctId) {
        Account acct;

        List<Account> acctList = [
            SELECT Id
                 , Phone
                 , LastName
                 , FirstName
                 , PersonBirthdate
                 , Gender__c
                 , ID_Type__c
                 , ID_Number__c
                 , AccountStatus__c
                 , Insurer_factor__c
                 , Mailing_approval__c
                 , Other_Health_Services__c
              FROM Account
             WHERE Id =: acctId
             LIMIT 1];

        if (!acctList.isEmpty()) {
            acct = acctList.get(0);
        }

        return acct;
    }
}