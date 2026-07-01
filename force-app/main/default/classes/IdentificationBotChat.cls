/*
* @author         Yulia Liberman   <yliberman@deloitte.co.il>
* @Test           
* @modifiedBy     
* @version        1.0
* @created        30-10-2019
* @modified       DD-MM-YYYY
* @description    Get random number for sms verification sending
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public  with sharing class IdentificationBotChat {

    public class RandomNumberOutput{
        @InvocableVariable(required=true)
        public String Random_Number;  
    }
    
  
    @InvocableMethod(label='Get random number for verification')
    public static List<RandomNumberOutput> getRandomNumner() {
        List<RandomNumberOutput> outputParameters = new List<RandomNumberOutput>();       
        RandomNumberOutput outputParameter = new RandomNumberOutput();

        Integer STRING_LENGTH= 5;
        Integer MAX= Integer.valueOf(Math.pow(10, STRING_LENGTH) - 1);
        outputParameter.Random_Number = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH, '0');

        outputParameters.add(outputParameter);
        return outputParameters;
    }

    
}