// Test: AccountServicesTest
public class AccountTriggerHandler {

    public static void handleTrigger(List<Account> newList, Map<Id, Account> oldMap) {
        System.debug('TR Account ...');

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                System.debug('TR Account BEFORE_INSERT');
                AccountTriggerDispatcher.validateIdNumber(newList, null);
                AccountTriggerDispatcher.checkIdNumberUniqueness(newList, null);
                AccountTriggerDispatcher.fillFormtitanId(newList, null);
                AccountTriggerDispatcher.postalCodeFields(newList, null);
                AccountTriggerDispatcher.fill360Coordinator(newList, null);
            }
            when BEFORE_UPDATE {
                System.debug('TR Account BEFORE_UPDATE');
                AccountTriggerDispatcher.validateIdNumber(newList, oldMap);
                AccountTriggerDispatcher.checkIdNumberUniqueness(newList, oldMap);
                AccountTriggerDispatcher.validateSMSPhoneNumber(newList, oldMap);
                AccountTriggerDispatcher.fillFormtitanId(newList, oldMap);
                AccountTriggerDispatcher.checkPromotedDocAdvisorDocAmount(newList,oldMap);
                AccountTriggerDispatcher.postalCodeFields(newList, oldMap);
                AccountTriggerDispatcher.fill360Coordinator(newList, oldMap);
            }
            when AFTER_INSERT {
                System.debug('TR Account AFTER_INSERT');
                AccountTriggerDispatcher.handleCreatePatient(newList, null);
                AccountTriggerDispatcher.handleMailingApproval(newList, oldMap);
                AccountTriggerDispatcher.checkEndUser(newList, null);
                AccountTriggerDispatcher.createSurveyForDoctors(newList);
            }
            when AFTER_UPDATE {
                System.debug('TR Account AFTER_UPDATE');
                AccountTriggerDispatcher.handleCreatePatient(newList, oldMap);
                AccountTriggerDispatcher.updateCasebyAccountFields(newList,oldMap);
                AccountTriggerDispatcher.handleMailingApproval(newList, oldMap);
                AccountTriggerDispatcher.checkEndUser(newList, oldMap);
            }
        }
    }
}