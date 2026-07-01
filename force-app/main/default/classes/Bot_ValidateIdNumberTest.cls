// Created: Evgeniy Kravchuk
// Date: 10.02.2020
// Test for: Bot_ValidateIdNumber
@isTest
public class Bot_ValidateIdNumberTest {

    @isTest
    static void validateIdNumberTest() {
        Bot_ValidateIdNumber.RequestWrapper wrapper = new Bot_ValidateIdNumber.RequestWrapper();
        wrapper.idNumber = '123456789';

        Test.startTest();
        Bot_ValidateIdNumber.validateIdNumber(new List<Bot_ValidateIdNumber.RequestWrapper>{wrapper});
        Test.stopTest();
    }

    @isTest
    static void validateIdNumberExceptionTest() {
        Bot_ValidateIdNumber.RequestWrapper wrapper = new Bot_ValidateIdNumber.RequestWrapper();
        wrapper.idNumber = '';

        Test.startTest();
        try {
            Bot_ValidateIdNumber.validateIdNumber(new List<Bot_ValidateIdNumber.RequestWrapper>{wrapper});
        } catch (Exception e) {}
        Test.stopTest();
    }

    @isTest
    static void validateIdNumberException2Test() {
        Test.startTest();
        try {
            Bot_ValidateIdNumber.validateIdNumber(new List<Bot_ValidateIdNumber.RequestWrapper>());
        } catch (Exception e) {}
        Test.stopTest();
    }
}