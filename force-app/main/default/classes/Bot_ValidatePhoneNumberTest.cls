// Created: Evgeniy Kravchuk
// Date: 13.02.2020
// Test for: Bot_ValidatePhoneNumber
@isTest
public class Bot_ValidatePhoneNumberTest {

    @isTest
    static void testBlankParamsException() {
        Test.startTest();
        try {
            Bot_ValidatePhoneNumber.validatePhoneNumber(new List<Bot_ValidatePhoneNumber.RequestWrapper>());
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void testBlankPhone() {
        Bot_ValidatePhoneNumber.RequestWrapper wrapper = new Bot_ValidatePhoneNumber.RequestWrapper();
        wrapper.phoneNumber = '';
        wrapper.isSMSNumber = 'true';

        Test.startTest();
        Bot_ValidatePhoneNumber.validatePhoneNumber(new List<Bot_ValidatePhoneNumber.RequestWrapper>{wrapper});
        Test.stopTest();
    }
    
    @isTest
    static void testSpecifiedPhoneCode() {
        Bot_ValidatePhoneNumber.RequestWrapper wrapper = new Bot_ValidatePhoneNumber.RequestWrapper();
        wrapper.phoneNumber = '0534177777';
        wrapper.isSMSNumber = 'true';

        Test.startTest();
        Bot_ValidatePhoneNumber.validatePhoneNumber(new List<Bot_ValidatePhoneNumber.RequestWrapper>{wrapper});
        Test.stopTest();
    }
    
    @isTest
    static void testNineDigitsPhone() {
        Bot_ValidatePhoneNumber.RequestWrapper wrapper = new Bot_ValidatePhoneNumber.RequestWrapper();
        wrapper.phoneNumber = '777777777';
        wrapper.isSMSNumber = 'false';

        Test.startTest();
        Bot_ValidatePhoneNumber.validatePhoneNumber(new List<Bot_ValidatePhoneNumber.RequestWrapper>{wrapper});
        Test.stopTest();
    }

    @isTest
    static void testTenDigitsPhone() {
        Bot_ValidatePhoneNumber.RequestWrapper wrapper = new Bot_ValidatePhoneNumber.RequestWrapper();
        wrapper.phoneNumber = '7777777777';
        wrapper.isSMSNumber = 'false';

        Test.startTest();
        Bot_ValidatePhoneNumber.validatePhoneNumber(new List<Bot_ValidatePhoneNumber.RequestWrapper>{wrapper});
        Test.stopTest();
    }
}