/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Doctor Abandonment Schedule Batch Apex class to check Doctor's surgeries decrease in half year to previous half year period
 *
 * Test                 DoctorAbandonmentScheduleBatchTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             19-08-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global with sharing class DoctorAbandonmentScheduleBatch implements Database.Batchable<sObject>, Schedulable {

    private static final Id MEDICAL_STAFF_RT_ID = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Medical_staff').getRecordTypeId();
    private static final Id DEFAULT_OWNER_ID = [SELECT Id FROM Group WHERE DeveloperName = 'Abandonmentsignal_of_doctors']?.Id;
    private static final Date SPLIT_DATE = Date.today().addMonths(-6).toStartOfMonth();
    private static final String RAW_DESCRIPTION = 'לרופא {0} יש ירידה של {1}% בכמות';
    private static final Decimal PERCENT_THRESHOLD = Decimal.valueOf('30');

    private static final String QUERY =
        'SELECT Name'
           + ', Primary_Site__r.Site_Code__c'
           + ', (SELECT Appointment_Date_time__c'
               + ' FROM Appointments_Doctor__r'
              + ' WHERE Appointment_Status__c != \'Canceled\''
                + ' AND RecordType.DeveloperName = \'Surgeries\''
                + ' AND Appointment_Date_time__c = LAST_N_DAYS:365'
                + ' AND Appointment_Date_time__c != TODAY'
           + ' ORDER BY Appointment_Date_time__c DESC)'
       + ' FROM Account'
      + ' WHERE RecordType.DeveloperName = \'Doctor_Account\''
        + ' AND Id IN (SELECT Doctor_Account__c'
                     + ' FROM Appointment__c'
                    + ' WHERE Doctor_Account__c != null'
                      + ' AND Appointment_Status__c != \'Canceled\''
                      + ' AND RecordType.DeveloperName = \'Surgeries\''
                      + ' AND Appointment_Date_time__c = LAST_N_DAYS:365'
                      + ' AND Appointment_Date_time__c != TODAY)';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DoctorAbandonmentScheduleBatch ... start');
        System.debug('query: ' + QUERY);
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('DoctorAbandonmentScheduleBatch ... execute');
        System.debug('scope: size: ' + scope.size() + ' value: ' + scope);
        List<Case> casesToInsert = new List<Case>();

        Map<String, Id> siteCodeToOwnerIdMap = this.obtainSiteCodeToOwnerIdMap();

        for (Account doctor_i : scope) {
            Statistics statistics_i = new Statistics();

            for (Appointment__c appointment_i : doctor_i.Appointments_Doctor__r) {
                statistics_i.refreshCounters(appointment_i.Appointment_Date_time__c);
            }
            statistics_i.calculateDecrease();
            statistics_i.checkAbandonment();

            if (statistics_i.isAbandoned) {
                Id ownerId_i = this.obtainOwnerId(siteCodeToOwnerIdMap.get(doctor_i.Primary_Site__r.Site_Code__c));
                String description_i = this.obtainDescription(doctor_i.Name, statistics_i.percentDecrease);

                casesToInsert.add(this.prepareCase(doctor_i.Id, ownerId_i, description_i));
            }
        }
        System.debug('casesToInsert: size: ' + casesToInsert.size() + ' value: ' + casesToInsert);

        Set<Id> caseIds = AsyncUtil.doInsert(casesToInsert);
        System.debug('caseIds: size: ' + caseIds.size() + ' value: ' + caseIds);
    }

    private Case prepareCase(Id doctorId, Id ownerId, String description) {
        return new Case(
            OwnerId = ownerId,
            AccountId = doctorId,
            Description = description,
            RecordTypeId = MEDICAL_STAFF_RT_ID,
            Memo_refferal_doctor__c = doctorId,
            Case_subject__c = 'abandonment_signal1',
            sub_case_subject__c = 'decrease_num_surg1'
        );
    }

    private Map<String, Id> obtainSiteCodeToOwnerIdMap() {
        Map<String, Id> siteCodeToOwnerIdMap = new Map<String, Id>();

        for (PrimaryOwnerMapping__mdt mdt_i : PrimaryOwnerMapping__mdt.getAll().values()) {
            siteCodeToOwnerIdMap.put(mdt_i.SiteCode__c, mdt_i.OwnerId__c);
        }
        System.debug('siteCodeToOwnerIdMap: size: ' + siteCodeToOwnerIdMap.size() + ' value: ' + siteCodeToOwnerIdMap);

        return siteCodeToOwnerIdMap;
    }

    private Id obtainOwnerId(Id ownerId) {
        return ownerId == null ? DEFAULT_OWNER_ID : ownerId;
    }

    private String obtainDescription(String doctorName, Decimal percentDecrease) {
        return String.format(RAW_DESCRIPTION, new List<Object>{doctorName, percentDecrease});
    }

    private class Statistics {
        private Integer thisHY {get;set;}
        private Integer lastHY {get;set;}
        private Boolean isAbandoned {get;set;}
        private Decimal percentDecrease {get;set;}

        private Statistics() {
            this.thisHY = 0;
            this.lastHY = 0;
        }

        private void refreshCounters(Datetime appointmentDatetime) {
            if (appointmentDatetime >= SPLIT_DATE) {
                this.thisHY++;
            } else {
                this.lastHY++;
            }
        }

        private void calculateDecrease() {
            this.percentDecrease = (this.lastHY - this.thisHY) * 100 / (this.lastHY == 0 ? 1 : this.lastHY);
        }

        private void checkAbandonment() {
            this.isAbandoned = this.percentDecrease >= PERCENT_THRESHOLD;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('DoctorAbandonmentScheduleBatch ... finish');
        Datetime dt = System.now().addMonths(3);
        String CRONEXP = '' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('Doctor Abandonment Checker #' + dt.getTime(), CRONEXP, new DoctorAbandonmentScheduleBatch());
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        Database.executeBatch(new DoctorAbandonmentScheduleBatch(), 100);
    }
}