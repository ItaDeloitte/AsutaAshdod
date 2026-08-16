public class CommonService {


    public static String generateRandomKey(Integer keyLength){
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < keyLength) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static String generateRandomNumber(Integer length) {
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, length);
        system.debug('Random Number-' + randomNumber);
        return randomNumber; 
    }

    /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────┐
        * create JsonResponse
        * ──────────────────────────────────────────────────────────────────────────────────────────────
        * @param    success       true/false
        * @param    errorMessage  massage type(OTP/HasPreferredChannel)  or error message string   
        * @return   -----
        * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void createJsonResponse (String success, String errorMessage){
        JSONGenerator jsGen = JSON.createGenerator(true);
        RestContext.response.addHeader('Content-Type', 'application/json');
        // Create a JSONGenerator object
        jsGen.writeStartObject();
            if(errorMessage == 'OTP'){
                jsGen.writeStringField('OTP', success);
            }
            else if(errorMessage == 'HasPreferredChannel'){
                jsGen.writeStringField('HasPreferredChannel', Success);
            }
            else{
                jsGen.writeStringField('Success', success);
                jsGen.writeStringField('ErrorMessage', errorMessage);
            }
            
        jsGen.writeEndObject();
        RestContext.response.responseBody = Blob.valueOf(jsGen.getAsString());
    } 
}