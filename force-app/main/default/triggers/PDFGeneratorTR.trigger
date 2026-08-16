trigger PDFGeneratorTR on PDFGenerator__e (after insert) {
	PDFGeneratorTRHandler.handleTrigger(Trigger.new, Trigger.operationType);
}