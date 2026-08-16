@isTest
private class ValidateUtilTest {

    @isTest
    static void testValidIdNumberCases() {
        
        String validId = '123456782'; 
        System.assertEquals(true, ValidateUtil.isValidIdNumber(validId), 'ID should be valid');

        String shortId = '12345678';
        System.assertEquals(false, ValidateUtil.isValidIdNumber(shortId), 'Short ID should be invalid');

        String wrongCheckDigit = '123456789';
        System.assertEquals(false, ValidateUtil.isValidIdNumber(wrongCheckDigit), 'Wrong check digit should be invalid');

        String nonDigitId = '12345A782';
        try {
            ValidateUtil.isValidIdNumber(nonDigitId);
            System.assert(false, 'Non-numeric ID should throw an exception');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Invalid'), 'Expected exception for non-numeric ID');
        }

        System.assertEquals(false, ValidateUtil.isValidIdNumber(''), 'Empty ID should be invalid');
    }

    @isTest
    static void testCheckDigitWithinRange() {
        Integer input = 12345678;
        Integer result = ValidateUtil.checkDigit(input);
        System.assert(result >= 0 && result <= 9, 'Check digit should be between 0 and 9');
    }

    @isTest
    static void testValidIsraeliMobileCases() {
        System.assertEquals(true, ValidateUtil.isValidIsraeliMobile('052-1234567'));
        System.assertEquals(true, ValidateUtil.isValidIsraeliMobile('+972-52-123-4567'));
        System.assertEquals(false, ValidateUtil.isValidIsraeliMobile('052123456'));
        System.assertEquals(false, ValidateUtil.isValidIsraeliMobile('0312345678'));
        System.assertEquals(false, ValidateUtil.isValidIsraeliMobile('0561234567'));
        System.assertEquals(true, ValidateUtil.isValidIsraeliMobile(' 052  -  123 4567'));
        System.assertEquals(false, ValidateUtil.isValidIsraeliMobile(''));
        System.assertEquals(false, ValidateUtil.isValidIsraeliMobile(null));
    }
}