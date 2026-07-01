// Created: Evgeniy Kravchuk
// Date: 15.01.2020
// Test: Bot_CreateCaseTest
global without sharing class Bot_CreateCase {

    public class Bot_CreateCaseException extends Exception {}

    global class CreateCaseRequestWrapper {
        @InvocableVariable(label='accountId' description='SF id of an account' required=true)
        public String accountId;
        @InvocableVariable(label='recordTypeId' description='SF id of a record type' required=true)
        public String recordTypeId;
        @InvocableVariable(label='contactId' description='SF id of a contact' required=true)
        public String contactId;
    }

    @InvocableMethod(label='Create case')
    public static List<Bot_Response> createCase(List<CreateCaseRequestWrapper> inList) {
        List<Bot_Response> responseList = new List<Bot_Response>();
        try {
            if (inList.isEmpty()) {
                throw new Bot_CreateCaseException('Params is blank');
            }

            Case cas = new Case(
                RecordTypeId = inList.get(0).recordTypeId,
                AccountId = inList.get(0).accountId,
                ContactId = inList.get(0).contactId,
                Origin = 'Chat'
            );
            insert cas;
            responseList.add(new Bot_Response(new List<String>{cas.Id}));
        } catch (Exception e) {
            responseList.add(new Bot_Response(e));
        }
        return responseList;
    }
}