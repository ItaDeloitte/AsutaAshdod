// Test: PDFGeneratorTRTest
public class PDFGeneratorTRDispatcher {
    
    public static void createPDF(List<PDFGenerator__e> newList) {
        System.debug('PDFGeneratorTRDispatcher.createPDF...');
        List<String> recordIds = new List<String> ();

        for (PDFGenerator__e pdfGenerator_i : newList) {
            recordIds.add(pdfGenerator_i.RecordId__c);
        }
        System.debug('recordIds: [' + recordIds.size() + '] value: ' + recordIds);

        PDFGeneratorTRService.createPDF(recordIds);
    }
}