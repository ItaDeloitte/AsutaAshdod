/*
    * @author           Ortal Kazum         <ortalk@assuta.co.il>
    * @Test             fileUploadForFreezingEggsControllerTest
    * @modifiedBy
    * @version          1.0
    * @created          06-06-2021
    * @modified         DD-MM-YYYY
    * @description      
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class fileUploadForFreezingEggsController {
    
    @AuraEnabled(cacheable=false)
    public static void importCSVFile(Id cVersionId, String siteName){
        try{
            ContentVersion conVersion = [SELECT VersionData, ContentDocumentId FROM ContentVersion WHERE Id =: cVersionId LIMIT 1];
            Id LinkedEntityId = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = : conVersion.ContentDocumentId LIMIT 1].LinkedEntityId;
            //Id recordId = [SELECT Id, Account__c FROM File__c WHERE Id = :LinkedEntityId].Account__c;
            Id recordId = LinkedEntityId;
            Blob csvFileBody = conVersion.VersionData;
            System.debug('***csvFileBody   '+ csvFileBody);
            // Read CSV file body and store it in variable
            String csvAsString = csvFileBody.toString();
            // Split CSV String to lines
            String [] csvFileLines = csvAsString.split('\n');
            List<recordDetails> wrapList = new List<recordDetails>();
            List<Log__c> logs = LogSettingService.getInstance().prepareLog('fileUploadForFreezingEggsController', 'importCSVFile', recordId);
            Log__c log = logs.get(0);
            insert log;
            for (String line :csvFileLines) {
                recordDetails wrap = new recordDetails();
                List<String> csvRecordData = line.split(',');
                System.debug('csvRecordData ' +  csvRecordData);
                System.debug('csvRecordData size ' +  csvRecordData.size()); 
                
                wrap.accId = csvRecordData.get(0).Trim().length() < = 9 ? completeTZ(csvRecordData.get(0)): csvRecordData.get(0);
                wrap.accPhone = csvRecordData.get(1);
                wrap.accEmail = csvRecordData.get(2);
                wrap.partnerName = csvRecordData.get(3) != '' && csvRecordData.get(3).Trim().length() < 9 ? completeTZ(csvRecordData.get(3)): csvRecordData.get(3);
                wrap.partnerPhone = csvRecordData.get(4);
                wrap.partnerEmail = csvRecordData.get(5);
                wrap.previousDate = setStringToDateFormat(csvRecordData.get(6));
                wrap.amount = Integer.valueOf(csvRecordData.get(7));
                if(csvRecordData.size() == 9){
                    wrap.isDonating = (csvRecordData.get(8) != null) ? Boolean.valueOf(csvRecordData.get(8)) : false;
                }
                wrapList.add(wrap);
            }

            System.debug('wrapList.Size() ' +  wrapList.size() + 'values ' + wrapList);
            System.enqueueJob(new fileUploadForFreezingEggsQueueable(wrapList, siteName, log.Id));
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
    }

    private static Date setStringToDateFormat(String myDate) {
        String[] strDate = myDate.split('\\.');
        Integer myIntDate = Integer.valueOf(strDate[0]);
        Integer myIntMonth = Integer.valueOf(strDate[1]);
        Integer myIntYear = Integer.valueOf(strDate[2]);
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
        return d;
     }

    private static String completeTZ (String accNumber){       
        return '000000000'.substring(accNumber.length()) + accNumber;
    }

      /* Wrapper Class */
    public class recordDetails{
        public String accId{get;set;}
        public String accPhone{get;set;}
        public String accEmail{get;set;}
        public String partnerName{get;set;}
        public String partnerPhone{get;set;}
        public String partnerEmail{get;set;}
        public Date previousDate{get;set;}
        public Integer amount{get;set;}
        public Boolean isDonating{get;set;}
    } 
}