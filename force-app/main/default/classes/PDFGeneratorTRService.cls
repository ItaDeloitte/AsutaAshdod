// Test: PDFGeneratorTRTest
public class PDFGeneratorTRService {
	
    private static FTDocGen__c docGen = FTDocGen__c.getInstance();
    
    @future(callout=true)
    public static void createPDF(List<String> recordIds) {
        System.debug('PDFGeneratorTRService.createPDF...');          
        String response = Form_Builder.FTDocGen.execute(recordIds, docGen.FTFormHash__c, docGen.FTApiKey__c); 
        System.debug('response: ' + response);       
    }
}