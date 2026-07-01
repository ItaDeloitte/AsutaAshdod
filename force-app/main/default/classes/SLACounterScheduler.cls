// Test: SLACounterSchedulerTest
global class SLACounterScheduler implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('SLACounterScheduler.start...');
        String query = 'SELECT Id, OwnerId, Related_User__c, Target_date_qa__c FROM QualityControl__c WHERE Status_QA__c != \'בוצע משוב\' AND Status_QA__c != \'לא נמצא כטעות\' AND Status_QA__c != \'לא רלוונטי\' AND Related_User__c != null AND SLA_start_date__c < YESTERDAY AND Target_date_qa__c >= YESTERDAY';
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<QualityControl__c> scope) {
        System.debug('SLACounterScheduler.execute...');
        System.debug('scope.size ' + scope.size());

        Calendar_Alert_Setting__mdt metadata = [SELECT Id, NumberOfDays__c, ToAddresses__c, Subject__c, PlainTextBody__c, AddLastDate__c FROM Calendar_Alert_Setting__mdt LIMIT 1];
        List<QualityControl__c> scopeToUpdate = new List<QualityControl__c>();
        Integer numberOfDays = Integer.valueOf(metadata.NumberOfDays__c);
        System.debug('metadata: ' + metadata);

        List<Calendar1__c> days = [SELECT Id, Gregorian_Date__c, business_day__c FROM Calendar1__c WHERE Gregorian_Date__c >= YESTERDAY ORDER BY Gregorian_Date__c LIMIT: numberOfDays]; // TODAY for testing
        Calendar1__c yesterday = days.get(0);
        Calendar1__c nextDay;
        for (Integer i = 1; i < days.size(); i++) {
            if (days.get(i).business_day__c) {
                nextDay = days.get(i);
                break;
            }
        }
        System.debug('days: size: ' + days.size() + ' value: ' + days);
        System.debug('yesterday: ' + yesterday);
        System.debug('nextDay: ' + nextDay);

        if (days.size() < numberOfDays) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = metadata.ToAddresses__c.split(',');
            message.subject = metadata.Subject__c;
            message.plainTextBody = metadata.PlainTextBody__c;
            if (metadata.AddLastDate__c) {
                message.plainTextBody += '\nThe last calendar date is ' + String.valueOf(days.get(days.size() - 1).Gregorian_Date__c) + '.';
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
        }

        if (yesterday.business_day__c) {
            Set<Id> userIds = new Set<Id>();
            Set<Id> loggedUserIds = new Set<Id>();

            for (QualityControl__c qualityControl_i : scope) {
                userIds.add(qualityControl_i.OwnerId);
                userIds.add(qualityControl_i.Related_User__c);
            }

            for (LoginHistory loginHistory_i : [SELECT Id, UserId FROM LoginHistory WHERE UserId IN: userIds AND LoginTime = YESTERDAY]) { // TODAY for testing
                loggedUserIds.add(loginHistory_i.UserId);
            }

            System.debug('userIds: size: ' + userIds.size() + ' value: ' + userIds);
            System.debug('loggedUserIds: size: ' + loggedUserIds.size() + ' value: ' + loggedUserIds);

            for (QualityControl__c qualityControl_i : scope) {
                if (!loggedUserIds.contains(qualityControl_i.OwnerId) || !loggedUserIds.contains(qualityControl_i.Related_User__c)) {
                    qualityControl_i.Target_date_qa__c = nextDay.Gregorian_Date__c;
                    scopeToUpdate.add(qualityControl_i);
                }
            }
        }

        update scopeToUpdate;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('SLACounterScheduler.finish...');
    }

    global void execute(SchedulableContext SC) {
        System.debug('SLACounterScheduler.execute...');
        Database.executeBatch(new SLACounterScheduler());
    }
}