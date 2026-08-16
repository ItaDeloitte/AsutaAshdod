// Test: PDFGeneratorTRTest
public class PDFGeneratorTRHandler {

    public static void handleTrigger(List<PDFGenerator__e> newList, System.TriggerOperation triggerEvent) {
        System.debug('PDFGeneratorTRHandler.handleTrigger...');

        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                PDFGeneratorTRDispatcher.createPDF(newList);
            }
            when else {
                System.debug('do nothing on others trigger events');
            }
        }
    }
}