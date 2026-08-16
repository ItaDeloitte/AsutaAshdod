@IsTest
public class WhatAppUtilsTest {

    @TestSetup
    static void makeData() {
        Calendar1__c businessDay1 = TestDataFactory.getCalendar1();
        businessDay1.Weekend__c = true;
        businessDay1.Holiday__c = false;
        businessDay1.business_day__c = true;
        insert businessDay1;
    }

    @IsTest
    static void checkBusinessDayTest() {
        Date today = Date.today();

        Test.startTest();
        Integer result = WhatAppUtils.checkBusinessDay(today);
        Test.stopTest();

        System.assertEquals(Integer.valueOf(System.Label.ScheduleHolidayDayFirstRemWA), result, 'Should return business day label value');
    }

    @IsTest
    static void getMessagingChannelTest() {
        String channelName = [SELECT DeveloperName FROM MessagingChannel LIMIT 1].DeveloperName;

        Test.startTest();
        List<MessagingChannel> channels = WhatAppUtils.getMessagingChannel(channelName);
        Test.stopTest();

        System.assertEquals(1, channels.size(), 'Should return one MessagingChannel');
        System.assertEquals(channelName, channels[0].DeveloperName, 'DeveloperName should match');
    }

    @IsTest
    static void getMessagingEndUserTest() {
        Map<Id, String> appIdToPhoneNumber = new Map<Id, String>();
        appIdToPhoneNumber.put('001000000000001', '00000000000');

        Id channelId = [SELECT Id FROM MessagingChannel LIMIT 1].Id;

        Test.startTest();
        Map<String, Id> result = WhatAppUtils.getMessagingEndUser(appIdToPhoneNumber, channelId);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one end user');
    }

    @IsTest
    static void testValidPhoneNumber() {
        String phoneNumber = '05-1234567';
        Test.startTest();
        String formattedNumber = WhatAppUtils.validPhoneNumber(phoneNumber);
        Test.stopTest();

        System.assertEquals('9725-1234567', formattedNumber, 'Phone number should be correctly formatted');
    }

    @IsTest
    static void testValidPhone() {
        String phoneNumber = '050-1234567';
        Test.startTest();
        String formattedNumber = WhatAppUtils.getValidPhone(phoneNumber);
        Test.stopTest();

        System.assertEquals('972501234567', formattedNumber, 'Phone number should be correctly formatted');
    }


    @IsTest
    static void testPrepareWhatApp() {
        // Prepare test Appointment__c
        Account patient1 = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient1.Create_Source_System__c = false;
        patient1.ID_Number__c = '852986371';
        insert patient1;

        Account doctor = TestDataFactory.getAccountDoctor();
        insert doctor;

        Contact con = TestDataFactory.getContact(doctor.Id);
        insert con;

        Payer_Factor__c pFactor = TestDataFactory.getPFactor(TestDataFactory.PFACTOR_CODE);
        insert pFactor;

        Case cas = TestDataFactory.getCase(doctor.Id, patient1.Id, con.Id, pFactor.Id);
        insert cas;

        Domain__c domain = TestDataFactory.getDomain();
        insert domain;

        Expertise__c expertise = TestDataFactory.getExpertise();
        insert expertise;

        Sub_Expertise__c subExpertise = TestDataFactory.getSubExpertise(expertise.Id);
        insert subExpertise;

        Medical_Procedure__c procedure = TestDataFactory.getProcedure(domain.Id, subExpertise.Id);
        insert procedure;
        
        Calendar__c calendar = TestDataFactory.getCalendar();
        insert calendar;

        Appointment__c appt = TestDataFactory.getAppointment('Closedins', procedure.Id, patient1.Id, calendar.Id, cas.Id);
        insert appt;

        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];

        // Create MessagingEndUser test data for getMessagingEndUser method
        MessagingEndUser endUser = new MessagingEndUser(
            Name = '00000000000',
            MessageType = 'WhatsApp',
            MessagingChannelId = channel.Id,
            MessagingPlatformKey = '00000000000',
            MessagingConsentStatus = 'ImplicitlyOptedIn'
        );
        insert endUser;

        String messTemplate = 'TestTemplate';
        String autoName = 'Automation1';
        String content = 'Test Content';
        String messagingEndUserId = endUser.Id;
        DateTime sendDate = DateTime.now();
        String channelName = 'Facebook';

        Test.startTest();
        WhatsApp__c waForAppointment = WhatAppUtils.prepareWhatApp(appt, messTemplate, autoName, messagingEndUserId, sendDate, channelName, null);
        WhatsApp__c waForAccount = WhatAppUtils.prepareWhatApp(doctor.Id, messTemplate, autoName, messagingEndUserId, sendDate, channelName, null);
        Test.stopTest();

        System.assertEquals(appt.Case__c, waForAppointment.Case__c, 'Case__c should match');
        System.assertEquals(messTemplate, waForAppointment.Messaging_Template__c, 'Messaging_Template__c should match');
    }
}