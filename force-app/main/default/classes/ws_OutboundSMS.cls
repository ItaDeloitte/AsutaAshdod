public class ws_OutboundSMS {

    public class SendText {
        public Boolean Success;
        public String  ErrorMessage;
    }

    public class SMSRequest {
        public String ToPhone;
        public String MessageText;
        public String SystemID;
        public String CurrentDate;
        public String CurrentTime;
        public String DefaultStartTime;
        public String DefaultEndTime;
        public String DefaultHolidayEndTime;
        public String Type;
        public String FromNumber;
    }

    public class AssutaSMSService {

        private final String  ENDPOINT   = 'callout:Ensemble_SMS_Test/rest/sms/SendSMS';
        private final Integer TIMEOUT_MS = 120000;

        public ws_OutboundSMS.SendText SendSMS(
            String  ToPhone,
            String  MessageText,
            Long    SystemID,
            String  FromNumber
        ) {
            SMSRequest requestBody = new SMSRequest();
            requestBody.ToPhone      = ToPhone;
            requestBody.MessageText  = MessageText;
            requestBody.SystemID     = String.valueOf(SystemID);
            requestBody.FromNumber   = String.isNotBlank(FromNumber) ? FromNumber : '';
            requestBody.Type         = '';

            HttpResponse res = RestApiCallout.sendRequest(
                ENDPOINT,
                'POST',
                JSON.serialize(requestBody),
                TIMEOUT_MS
            );

            return parseResponse(res);
        }

        private ws_OutboundSMS.SendText parseResponse(HttpResponse res) {
            ws_OutboundSMS.SendText result = new ws_OutboundSMS.SendText();

            if (res.getStatusCode() == 200) {
                try {
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    result.Success      = (Boolean) m.get('Success');
                    result.ErrorMessage = (String)  m.get('ErrorMessage');
                } catch (Exception e) {
                    result.Success      = false;
                    result.ErrorMessage = 'Failed to parse SMS response: ' + e.getMessage();
                }
            } else {
                result.Success      = false;
                result.ErrorMessage = 'HTTP ' + res.getStatusCode() + ': ' + res.getStatus();
            }

            return result;
        }
    }
}
