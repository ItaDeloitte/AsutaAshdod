// Test: DoctorSummaryReportBatchTest
global class DoctorSummaryReportBatch implements Database.Batchable<sObject>, Schedulable {

    Boolean setDatetime = true;
    String query = 'SELECT Id'
                      + ', Name'
                      + ', Doctor_marketing_email__c'
                      + ', Date_Of_Sending_Monthly_Report__c'
                  + ' FROM Account'
                 + ' WHERE RecordType.DeveloperName = \'Doctor_Account\''
                   + ' AND Experts_Center__c = true'
                   + ' AND Status__c = \'פ\''
                   + ' AND Doctor_marketing_email__c != null';

    global DoctorSummaryReportBatch() {
        this.query += ' AND Dont_Send_Monthly_Summary__c = false';
    }

    global DoctorSummaryReportBatch(String doctorId) {
        this.query += ' AND Id = \'' + doctorId + '\'';
        this.setDatetime = false;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        EmailTemplate template = [SELECT Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Doctors_Summary_Report'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Account> doctors = new List<Account>();
        Map<Id, Account> doctorsMap = new Map<Id, Account>();

        for (Account doctor_i : scope) {
            mails.add(prepareMail(doctor_i, template));
        }
        System.debug('mails: size: ' + mails.size());

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails, false);
        for (Messaging.SendEmailResult result_i : results) {
            if (result_i.isSuccess() && this.setDatetime) {
                Account doctor_i = scope.get(results.indexOf(result_i));
                doctor_i.Date_Of_Sending_Monthly_Report__c = System.now();
                doctors.add(doctor_i);
            }
        }
        System.debug('doctors: size: ' + doctors.size() + ' value: ' + doctors);

        if (!doctors.isEmpty()) {
            update doctors;
        }
    }

    private static Messaging.SingleEmailMessage prepareMail(Account doctor, EmailTemplate template) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{doctor.Doctor_marketing_email__c});
        mail.setSenderDisplayName('Assuta No-Reply');
        mail.setReplyTo('nonreply@assuta.co.il');
        mail.setHtmlBody(template.HtmlValue);
        mail.setPlainTextBody(template.Body);
        mail.setTreatBodiesAsTemplate(true);
        mail.setSubject(template.Subject);
        mail.setWhatId(doctor.Id);
        return mail;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DoctorSummaryReportBatch(), 1);
    }
}