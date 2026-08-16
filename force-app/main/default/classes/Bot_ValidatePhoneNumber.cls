// Created: Evgeniy Kravchuk
// Date: 13.02.2020
// Test: Bot_ValidatePhoneNumberTest
global without sharing class Bot_ValidatePhoneNumber {

    public class Bot_ValidatePhoneNumberException extends Exception {}

    global class RequestWrapper {
        @InvocableVariable(label='phoneNumber' description='Phone Number' required=true)
        public String phoneNumber;
        @InvocableVariable(label='isSMSNumber' description='Is it number for SMS?' required=true)
        public String isSMSNumber;
    }

    global class ResponseWrapper {
        @InvocableVariable(label='is_success' description='Is Sucess?')
        public Boolean isSuccses;
        @InvocableVariable(label='errorText' description='Error if not success')
        public String errorText;
        @InvocableVariable(label='isValid' description='Is valid Phone Number?')
        public Boolean isValid;

        public ResponseWrapper(Boolean isValid) {
            this.isSuccses = true;
            this.errorText = '';
            this.isValid = isValid;
        }

        public ResponseWrapper(Exception e) {
            this.isSuccses = false;
            this.errorText = e.getMessage() + ' line: ' + e.getLineNumber();
            this.isValid = false;
        }
    }

    @InvocableMethod(label='Validate Phone Number')
    public static List<ResponseWrapper> validatePhoneNumber(List<RequestWrapper> inList) {
        List<ResponseWrapper> responseList = new List<ResponseWrapper>();
        try {
            if (inList.isEmpty()) {
                throw new Bot_ValidatePhoneNumberException('Params is blank');
            }
            Boolean isValid = true;
            String phone = inList.get(0).phoneNumber;
            Boolean isSMS = Boolean.valueOf(inList.get(0).isSMSNumber);

            if (String.isBlank(phone)) {
                isValid = false;
            } else if (
                          isSMS &&
                          (
                              phone.length() != 10 ||
                              phone.left(1) != '0' ||
                              phone.left(5) == '05041' ||
                              phone.left(5) == '05271' ||
                              phone.left(5) == '05276' ||
                              phone.left(5) == '05484' ||
                              phone.left(5) == '05485' ||
                              phone.left(5) == '05832' ||
                              phone.left(5) == '05567' ||
                              phone.left(5) == '05331' ||
                              phone.left(5) == '05341'
                          )
                      ) {
                isValid = false;
            } else if (
                          !isSMS &&
                          (
                              !(
                                  phone.length() == 9 ||
                                  phone.length() == 10
                              ) ||
                              (
                                  phone.length() == 9 &&
                                  !(
                                      phone.left(2) == '02' ||
                                      phone.left(2) == '03' ||
                                      phone.left(2) == '04' ||
                                      phone.left(2) == '08' ||
                                      phone.left(2) == '09'
                                  )
                              ) ||
                              (
                                  phone.length() == 10 &&
                                  !(
                                      phone.left(2) == '05' ||
                                      phone.left(2) == '07'
                                  )
                              )
                          )
                      ) {
                isValid = false;
            }

            responseList.add(new ResponseWrapper(isValid));
        } catch (Exception e) {
            responseList.add(new ResponseWrapper(e));
        }
        return responseList;
    }
}