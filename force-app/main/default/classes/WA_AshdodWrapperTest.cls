@IsTest
private class WA_AshdodWrapperTest {

    @TestSetup
    static void setupData() {     
        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);        
        insert pFactor;
        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        insert patient;
        Account doctor = TestDataFactory.getAccount(TestDataFactory.ACCT_D_RT_NAME);
        insert doctor;
        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;
        Case cas = TestDataFactory.getCase(doctor.Id, patient.Id, con.Id, pFactor.Id);
        insert cas;
        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;
        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;
        Domain__c domain = TestDataFactory.getDomain(TestDataFactory.DOMAIN_CODE);       
        insert domain;
        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id, TestDataFactory.PROCEDURE_CODE);       
        procedure.Colonoscopy1DayBeforeLink__c = 'link1';
        procedure.Colonoscopy2DaysBeforeLink__c = 'link2';
        procedure.Colonoscopy3DaysBeforeLink__c = 'link3';
        procedure.Colonoscopy4DaysBeforeLink__c = 'link4';
        procedure.ColonoscopyKid2DaysBeforeLink__c = 'linkKid2';
        procedure.ColonoscopyKid3DaysBeforeLink__c = 'linkKid3';
        procedure.ColonoscopyParent2DaysBeforeLink__c = 'linkParent2';
        procedure.ColonoscopyParent3DaysBeforeLink__c = 'linkParent3';
        insert procedure;
        Calendar__c calendar = TestDataFactory.getCalendar(TestDataFactory.CALENDAR_CODE);
        calendar.ReminderId__c = '12345';
        insert calendar;
        Site__c site = TestDataFactory.getSite(TestDataFactory.SITE_CODE);       
        insert site;
               
        Appointment__c appt = TestDataFactory.getAppointment(TestDataFactory.APPT_I_RT_NAME, procedure.Id, patient.Id, calendar.Id, cas.Id);
        appt.Appointment_Date_Time__c =  Date.today();
        appt.Site__c = site.Id;
        insert appt;    
    }

    @IsTest
    static void setData() {
        Appointment__c appt = [SELECT Id
                                    , day_date_hour__c
                                    , Days_Until_Appointment__c
                                    , formtitan_arrival_link__c
                                    , Site__r.Name
                                    , Patient_Account__r.Id
                                    , Patient_Account__r.FirstName
                                    , Patient_Account__r.SMS_Phone_Number__c 
                                    , Medical_Procedure__r.Name       
                                    , Medical_Procedure__r.Colonoscopy1DayBeforeLink__c
                                    , Medical_Procedure__r.Colonoscopy2DaysBeforeLink__c
                                    , Medical_Procedure__r.Colonoscopy3DaysBeforeLink__c
                                    , Medical_Procedure__r.Colonoscopy4DaysBeforeLink__c
                                    , Medical_Procedure__r.ColonoscopyKid2DaysBeforeLink__c
                                    , Medical_Procedure__r.ColonoscopyKid3DaysBeforeLink__c
                                    , Medical_Procedure__r.ColonoscopyParent2DaysBeforeLink__c 
                                    , Medical_Procedure__r.ColonoscopyParent3DaysBeforeLink__c
                                    FROM Appointment__c];

        WA_AshdodWrapper wrapper = new WA_AshdodWrapper(
            appt,
            null,
            null,
            null,
            'SMS'
        );

        WA_AshdodWrapper wrapper2 = new WA_AshdodWrapper(
            appt,
            'ReminderTemplate',
            'WA_AshdodColonoscopySchedulableBatch',
            'MSG001',
            'WhatsApp'
        );
    }
}