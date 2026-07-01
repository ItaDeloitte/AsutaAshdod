//Test:SmsHandelingTest
global without sharing class SmsHandeling {

    public class SmsHandelingException extends Exception {}
    
    global class SmsHandelingRequestWrapper {
        @InvocableVariable(label='smsTemplateId' description='SF id of an smsTemplate' required=true)
        public String smsTemplateId;
        @InvocableVariable(label='appointmentId' description='SF id of an appointment' required=true)
        public String appointmentId;
    }
    
    @InvocableMethod(label='create sms content')
    public static List<String> createSmsContent(List<SmsHandelingRequestWrapper> requestList) {
        List<String> contentText = new List<String>();
        try {
            if (requestList.isEmpty()) {
                throw new SmsHandelingException('Params is blank');
            }
            String smsTempId = requestList.get(0).smsTemplateId;
            String appId = requestList.get(0).appointmentId;
            SmsTemplate__c smsTemp = [SELECT Sms_content__c, apiNames__c FROM SmsTemplate__c WHERE id =: smsTempId LIMIT 1];
            String fieldsToQuery = smsTemp.apiNames__c;
            String query = 'SELECT ' + smsTemp.apiNames__c + ' FROM Appointment__c WHERE id =:appId LIMIT 1';
            Appointment__c app = Database.query(query);
            List<String> values = new List<String>();
            for(String apiName : smsTemp.apiNames__c.split(',')){
                if(apiName.contains('.')){
                    SObject relatedObject = app;
                    List<String> relationsList = apiName.split('\\.');
                    for(Integer i=0; i<relationsList.size(); i++){
                        System.debug('relatedObject: ' + relatedObject);
                        if(i < relationsList.size() -1){ //it's still an object
                            relatedObject = relatedObject.getSObject(relationsList[i]);
                        }else{
                            values.add(string.valueOf(relatedObject.get(relationsList[i])));
                        }
                    }
                }else{
                    values.add(string.valueOf(app.get(apiName)));
                }
            }
            System.debug('values: ' + values);
             
            contentText.add(String.format(smsTemp.Sms_content__c, values));
        } catch (Exception e) {
            contentText.add(String.valueOf(e));
        }
        return contentText;
    }
}