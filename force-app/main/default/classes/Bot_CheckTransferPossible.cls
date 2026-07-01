global without sharing class Bot_CheckTransferPossible {

    global class BuisnessDayWrapper {
        @InvocableVariable(label='Is_Buisness_day' description='Is Buisness Day?' required=true)
        public Boolean isBuisnessDay;
        @InvocableVariable(label='date' description='Date we are talking about' required=true)
        public Date day;

        public BuisnessDayWrapper() {
            this.isBuisnessDay = false;
            this.day = Date.today();
        }

        public BuisnessDayWrapper(Calendar1__c calendar, Map<String, Bot_Working_Hours__mdt> workingHours) {
            this.day = calendar.Gregorian_Date__c;
            this.isBuisnessDay = false;
            if (calendar.business_day__c) {
                Datetime nowIsrael = System.now();
                String dayOfWeek = nowIsrael.format('EEEE');

                if (workingHours.containsKey(dayOfWeek)) {
                    DateTime startOfDay = DateTime.newInstance(nowIsrael.year(), nowIsrael.month(), nowIsrael.day(), Integer.valueOf(workingHours.get(dayOfWeek).StartHour__c), Integer.valueOf(workingHours.get(dayOfWeek).StartMinute__c), 0);
                    DateTime endOfDay = DateTime.newInstance(nowIsrael.year(), nowIsrael.month(), nowIsrael.day(), Integer.valueOf(workingHours.get(dayOfWeek).EndHour__c), Integer.valueOf(workingHours.get(dayOfWeek).EndMinute__c), 0);

                    if (nowIsrael > startOfDay && nowIsrael < endOfDay) {
                        this.isBuisnessDay = true;
                    }
                }
            }
        }
    }

    @InvocableMethod(label='Check Working Hours')
    public static List<BuisnessDayWrapper> checkBuisnessIfno() {
        Datetime now = System.now();
        List<Calendar1__c> calendars = [SELECT Id, business_day__c, Gregorian_Date__c FROM Calendar1__c WHERE Gregorian_Date__c =: now.date()];

        if (!calendars.isEmpty()) {
            Map<String, Bot_Working_Hours__mdt> workingHours = new Map<String, Bot_Working_Hours__mdt>();
            for (Bot_Working_Hours__mdt metadata_i : [SELECT Id, DeveloperName, StartHour__c, EndHour__c, StartMinute__c, EndMinute__c FROM Bot_Working_Hours__mdt]) {
                workingHours.put(metadata_i.DeveloperName, metadata_i);
            }

            return new List<BuisnessDayWrapper>{new BuisnessDayWrapper(calendars.get(0), workingHours)};
        } else {
            return new List<BuisnessDayWrapper>{new BuisnessDayWrapper()};
        }
    }
}