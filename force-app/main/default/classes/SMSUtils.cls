// Test: SMSUtilsTest
public class SMSUtils {

    public static Map<Date, Integer> getBusinessDaysMap() {
        return getBusinessDaysMap(null);
    }

    public static Map<Date, Integer> getBusinessDaysMap(Date untilDate) {
        Map<Date, Integer> businessDaysMap = new Map<Date, Integer>();

        String query = 'SELECT Gregorian_Date__c, business_day__c'
            + ' FROM Calendar1__c'
            + ' WHERE Gregorian_Date__c >= TODAY'
            + (untilDate == null ? '' : ' AND Gregorian_Date__c <=: untilDate')
            + ' ORDER BY Gregorian_Date__c';

        Integer counter = 0;
        for (Calendar1__c day_i : Database.query(query)) {
            businessDaysMap.put(day_i.Gregorian_Date__c, counter);
            if (day_i.business_day__c) {
                counter++;
            }
        }
        System.debug('businessDaysMap: size: ' + businessDaysMap.size() + ' value: ' + businessDaysMap);

        return businessDaysMap;
    }

    public static Boolean checkBusinessDay(Date currentDate) {        
        List<Calendar1__c> businessDay = [SELECT Gregorian_Date__c, business_day__c 
                                            FROM Calendar1__c 
                                           WHERE Gregorian_Date__c = :currentDate
                                           LIMIT 1];

         if(!businessDay.isEmpty()){
            System.debug('businessDay' + businessDay.get(0).business_day__c);
            return businessDay.get(0).business_day__c;
         }
         return false;
    }

    public static SMS__c prepareSMS(Appointment__c appt, String smsTemplate, Boolean isReminder) {
        return prepareSMS(smsTemplate, getPhoneNumber(appt), appt.Id, isReminder);
    }

    public static SMS__c prepareSMS(String smsTemplate, String phoneNumber, String apptId, Boolean isReminder) {
        return new SMS__c(
            Type__c = 'Outgoing',            
            Appointment__c = apptId,
            Phone_Number__c = phoneNumber,
            status__c = isReminder ? '2' : '1',
            question_type__c = isReminder ? 'אישור תור' : null,
            Sent_with_SMS_Settings__c = isReminder ? false : true,
            smsTemplate__c = smsTemplate,
            ExpectedSendingDateTime__c = Datetime.now()
        );
    }

    public static String getDomainCode(Appointment__c appt) {
        String code;
        if (appt.Medical_Procedure__r.Domain__c != null && appt.Medical_Procedure__r.Domain__r.DomainCode__c != null) {
            code = String.valueOf(Integer.valueOf(appt.Medical_Procedure__r.Domain__r.DomainCode__c));
        } else if (appt.Domain__c != null && appt.Domain__r.DomainCode__c != null) {
            code = String.valueOf(Integer.valueOf(appt.Domain__r.DomainCode__c));
        }
        return code;
    }

    public static String getPhoneNumber(Appointment__c appt) {
        String phone = appt.Case__c != null && appt.Case__r.SMS_Phone_Number__c != null
            ? appt.Case__r.SMS_Phone_Number__c
            : appt.Patient_Account__r.SMS_Phone_number__c;
        return phone;
    }

    public static String getTemplate(Appointment__c appt, String smsTemplate) {       
        return appt.Site__r.Site_Code__c == '33' ? smsTemplate + '_Ashdod': smsTemplate;
                            
    }
}