// Created: Evgeniy Kravchuk
// Date: 10.02.2020
// Test: Bot_ValidateIdNumberTest
global without sharing class Bot_ValidateIdNumber {

    public class Bot_ValidateIdNumberException extends Exception {}

    global class RequestWrapper {
        @InvocableVariable(label='idNumber' description='Israeli Id Number' required=true)
        public String idNumber;
    }

    global class ResponseWrapper {
        @InvocableVariable(label='is_success' description='Is Sucess?')
        public Boolean isSuccses;
        @InvocableVariable(label='errorText' description='Error if not success')
        public String errorText;
        @InvocableVariable(label='isValid' description='Is valid Id Number?')
        public Boolean isValid;

        public ResponseWrapper(Boolean isValid) {
            this.isSuccses = true;
            this.errorText = '';
            this.isValid = isValid;
        }

        public ResponseWrapper(Exception e) {
            this.isSuccses = false;
            this.errorText = e.getMessage();
            this.isValid = false;
        }
    }

    @InvocableMethod(label='Validate Id Number')
    public static List<ResponseWrapper> validateIdNumber(List<RequestWrapper> inList) {
        List<ResponseWrapper> responseList = new List<ResponseWrapper>();
        try {
            if (inList.isEmpty()) {
                throw new Bot_ValidateIdNumberException('Params is blank');
            }

            Boolean isValid = ValidateUtil.isValidIdNumber(inList.get(0).idNumber);

            responseList.add(new ResponseWrapper(isValid));
        } catch (Exception e) {
            responseList.add(new ResponseWrapper(e));
        }
        return responseList;
    }
}