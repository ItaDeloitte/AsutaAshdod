global without sharing class Bot_BusinessHoursService {

    global class BotRequest {
        @InvocableVariable(required=true)
        public String botName;
    }

    global class BotAvailabilityResult {
        @InvocableVariable
        public Boolean isAvailable;

        @InvocableVariable
        public Date day;

        public BotAvailabilityResult() {
            this.isAvailable = false;
            this.day = System.today();
        }

        public BotAvailabilityResult(Calendar1__c calendar, Bot_Business_Hours__c dbh) {

            this.day = calendar.Gregorian_Date__c;
            this.isAvailable = false;

            if (!calendar.business_day__c || dbh == null || !dbh.Is_active__c) {
                return;
            }

            if (dbh.Business_Hours__c != null &&
                BusinessHours.isWithin(dbh.Business_Hours__c, System.now())) {

                this.isAvailable = true;
            }
        }
    }

    @InvocableMethod(label='Check Bot Availability')
    public static List<BotAvailabilityResult> evaluateBotsAvailability(List<BotRequest> requests) {

        List<BotAvailabilityResult> results = new List<BotAvailabilityResult>();

        if (requests == null || requests.isEmpty()) {
            results.add(new BotAvailabilityResult());
            return results;
        }

        String botName = requests[0].botName;
        Datetime now = System.now();

        Calendar1__c calendar = [
            SELECT Id, business_day__c, Gregorian_Date__c
            FROM Calendar1__c
            WHERE Gregorian_Date__c = :now.date()
            LIMIT 1
        ];
        System.debug('calendar ' + calendar);
        
        Bot_Business_Hours__c dbh;

        List<Bot_Business_Hours__c> dbhList = [
            SELECT Id, Name, Is_active__c, Business_Hours__c
            FROM Bot_Business_Hours__c
            WHERE Name = :botName
            LIMIT 1
        ];
        
        System.debug('dbhList ' + dbhList);
        if (!dbhList.isEmpty()) {
            dbh = dbhList[0];
        }

        results.add(new BotAvailabilityResult(calendar, dbh));

        return results;
    }
}