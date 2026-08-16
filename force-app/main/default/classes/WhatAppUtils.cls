public class WhatAppUtils {

    public static Integer checkBusinessDay(Date pDate) {
        List<Calendar1__c> calendar1List = [
            SELECT Weekend__c
                 , Holiday__c
                 , business_day__c
                 , Holiday_Description__c
              FROM Calendar1__c
             WHERE Gregorian_Date__c = :pDate
             LIMIT 1];
        System.debug('calendar1List [' + calendar1List.size() + ']: ' + calendar1List);

        if (!calendar1List.isEmpty() ) {
            Calendar1__c day = calendar1List.get(0);

            if (day.business_day__c && !day.Weekend__c && (!day.Holiday__c || !day.Holiday_Description__c.contains('ערב'))) {
                return Integer.valueOf(System.Label.ScheduleBusDayFirstRemWA); // 18:00
            }

            if ((day.business_day__c && !day.Holiday__c && day.Weekend__c)
                    || (day.business_day__c && day.Holiday__c && day.Holiday_Description__c.contains('ערב'))) {
                return Integer.valueOf(System.Label.ScheduleHolidayDayFirstRemWA); // 12:00
            }
        }

        return null;
    }

    public static List<MessagingChannel> getMessagingChannel(String developerName) {
        return [SELECT Id 
                       , DeveloperName 
                       , MasterLabel 
                 FROM MessagingChannel 
                WHERE DeveloperName = :developerName]; 
    }

    public static Map<String, Id> getMessagingEndUser(Map<Id, String> recordIdToPhoneNumber, Id channelId) {
        Set<String> errors = new Set<String>();
        Set<Id> messagingEndUserIds = new Set<Id>();
        Set<Decimal> sReminderDomains = new Set<Decimal>();
        Map<String, Id> phoneNumberToEndUser = new Map<String, Id> ();
        List<MessagingEndUser> messagingEndUserToInsert = new List<MessagingEndUser>();

        for (MessagingEndUser endUser_i :[SELECT Id
                                            , MessageType
                                            , MessagingChannelId
                                            , MessagingPlatformKey
                                        FROM MessagingEndUser
                                        WHERE MessagingChannelId = :channelId
                                        AND MessageType = 'WhatsApp'
                                        AND MessagingPlatformKey IN :recordIdToPhoneNumber.values()]) {
            phoneNumberToEndUser.put(endUser_i.MessagingPlatformKey , endUser_i.Id);
        }
        System.debug('phoneNumberToEndUser: size: ' + phoneNumberToEndUser.size() + ' value: ' + phoneNumberToEndUser);

        for (Id recordId_i : recordIdToPhoneNumber.keySet()) {
            if (!phoneNumberToEndUser.containskey(recordIdToPhoneNumber.get(recordId_i))) {
                messagingEndUserToInsert.add(createMessagingEndUser(recordIdToPhoneNumber.get(recordId_i), channelId));
            }
        }

        System.debug('messagingEndUserToInsert: size: ' + messagingEndUserToInsert.size() + ' value: ' + messagingEndUserToInsert);
        if (!messagingEndUserToInsert.isEmpty()) {
            for (Database.SaveResult result_i : Database.insert(messagingEndUserToInsert, false)) {
                if (result_i.isSuccess()) {
                    messagingEndUserIds.add(result_i.getId());
                } else {
                    errors.add(result_i.getId() + ': ' + result_i.getErrors());
                }
            }

            for (MessagingEndUser endUser_i : [SELECT Id, MessagingPlatformKey FROM MessagingEndUser WHERE Id IN: messagingEndUserIds]) {
                phoneNumberToEndUser.put(endUser_i.MessagingPlatformKey , endUser_i.Id);
            }
        }
        return phoneNumberToEndUser;
    }
    
    public static String getValidPhone(String phoneNumber) {
        String phone = validPhoneNumber(phoneNumber);
        return ValidateUtil.isValidIsraeliMobile(phone) ? phone : null;
    }

    public static String validPhoneNumber(String phoneNumber) {
        if (phoneNumber.mid(3,1) == '-') {
            return '972' + phoneNumber.mid(1, 2) + phoneNumber.right(7);
        }
        return '972' + phoneNumber.right(9);
    }

    private static MessagingEndUser createMessagingEndUser(String phoneNumber, Id channelId) {
        return new MessagingEndUser (
            Name = phoneNumber,
            MessageType = 'WhatsApp',
            MessagingChannelId = channelId, 
            MessagingPlatformKey = phoneNumber,
            MessagingConsentStatus = 'ImplicitlyOptedIn'
        );
    }

    public static WhatsApp__c prepareWhatApp(Appointment__c appt, String messTemplate, String autoName, String messagingEndUserId, DateTime sendDate, String channelName, String values4ScheduledWA) {
        return new WhatsApp__c(
            Case__c = appt.Case__c != null ? appt.Case__c : null,           
            Account__c = appt.Patient_Account__c,
            From_Phone__c = channelName,
            Appointment__c = appt.Id,
            Phone_Number__c = appt.Patient_Account__r.SMS_Phone_number__c,
            Messaging_User__c = messagingEndUserId,
            Automation_name__c = autoName,
            Messaging_Template__c = messTemplate,
            Expected_Sending_Date_Time__c = sendDate,
            Values4ScheduledWA__c = values4ScheduledWA);            
    }

    public static WhatsApp__c prepareWhatApp(Id accountId, String messTemplate, String autoName, String messagingEndUserId, DateTime sendDate, String channelName, String phoneNumber) {
        return new WhatsApp__c(               
            Account__c = accountId,
            From_Phone__c = channelName,                                
            Automation_name__c = autoName,
            Messaging_Template__c = messTemplate,
            Messaging_User__c = messagingEndUserId,
            Expected_Sending_Date_Time__c = sendDate,                                  
            Phone_Number__c = phoneNumber        
        );            
    }
}