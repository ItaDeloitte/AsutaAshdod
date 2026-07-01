@isTest
public class fileUploadForFreezingEggsTest {

    @TestSetup
    static void setup() {
        insert TestDataFactory.getENV();
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode('ODUyOTg2MzcxLDA1MC0yMzIyMDg3LCw2Mjg2OTA4NiwwNTQtMjEyMjA3OSwsMTQuMy4yMDE0LDQs'+
        '15zXkAo0MDg4MzMyNCwwNTItMjA1NzA3NiwsMzczNTY0NzQsMDUyLTQ0MDU1ODMsLDExLjYuMjAx'+
        'NCwxLAozMDAwNDgxMTMsMDUwLTIyOTMwMDIsLDQzMTYzNzMyLDA1MC0yMjkzMDAyLCwyOC4xMS4y'+
        'MDE0LDMsCjMyODY3NTY2LDA1NC01MjE1MTMzLCwyNTMzNDI1MSwwNTAtNjQ1ODA4OCwsMTcuOC4y'+
        'MDE0LDksCjM5NjE5NTk4LDA1MC05MTI3OTY0LCwzOTM0ODAyNCwwNTAtOTEyNzk2NCwsMjIuNS4y'+
        'MDE0LDQs15zXkAo=');
        cv.GateScaner_FileScanStatus__c = '2';
        cv.PathOnClient = 'filename.pdf';
        cv.GateScaner_Status__c = '2';
        cv.ContentLocation = 'S';
        cv.Title = 'title';
        cv.Title = 'title';
        insert cv;

        Account patient = TestDataFactory.getAccount(TestDataFactory.ACCT_P_RT_NAME);
        patient.Create_Tafnit_AC__c = true;
        patient.PersonMailingCountry = 'ישראל';
        patient.PersonMailingCity = 'בית שמש'; 
        patient.PersonMailingStreet = 'הכלנית 18';
        patient.Other_Health_Services__c = 'ללא';
        patient.Phone = '0525518922';
        patient.SMS_Phone_Number__c = '0525518983';
        patient.Preferred_Channel__c = 'Whatsapp';
        patient.PersonEmail = 'test1@walla.com';
        patient.Fax = '0525518983';
        insert patient;
    }

    @isTest
    static void importCSVFileTest() {
        Test.setMock(WebServiceMock.class, new AccountDemographyMock());
        Id cvId = [SELECT Id FROM ContentVersion LIMIT 1].Id;
        String siteName = 'Ramat_Hahayal';
        Test.startTest();
        fileUploadForFreezingEggsController.importCSVFile(cvId, siteName);
        Test.stopTest();
    }

}