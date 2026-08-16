@IsTest
private class AppointmentDocumentsResponseTest {
    
    @IsTest
    static void testAppointmentDocumentsResponse_AllMethodsAndChaining() {
        FileStatusDTO fileStatus1 = new FileStatusDTO('TYPE_A', true);
        FileStatusDTO fileStatus2 = new FileStatusDTO('TYPE_B', false);
        List<FileStatusDTO> statusList = new List<FileStatusDTO>{fileStatus1, fileStatus2};

        FileUrlDTO fileUrl1 = new FileUrlDTO('001', 'File One', 'https://example.com/1');
        FileUrlDTO fileUrl2 = new FileUrlDTO('002', 'File Two', 'https://example.com/2');
        List<FileUrlDTO> urlList = new List<FileUrlDTO>{fileUrl1, fileUrl2};

        AppointmentDocumentsResponse wrapper = new AppointmentDocumentsResponse();
        System.assertNotEquals(null, wrapper.requiredDocuments, 'requiredDocuments should be initialized');
        System.assertNotEquals(null, wrapper.relatedDocument, 'relatedDocument should be initialized');

        AppointmentDocumentsResponse emptyWrapper = AppointmentDocumentsResponse.empty();
        System.assertEquals(0, emptyWrapper.requiredDocuments.size(), 'empty() should start empty');
        System.assertEquals(0, emptyWrapper.relatedDocument.size(), 'empty() should start empty');

        wrapper.addRequired(fileStatus1);
        System.assertEquals(1, wrapper.requiredDocuments.size(), 'Should contain one required document');
        
        wrapper.addRequiredAll(statusList);
        System.assertEquals(3, wrapper.requiredDocuments.size(), 'Should contain three required documents');

        wrapper.addRelated(fileUrl1);
        System.assertEquals(1, wrapper.relatedDocument.size(), 'Should contain one related document');
        
        wrapper.addRelatedAll(urlList);
        System.assertEquals(3, wrapper.relatedDocument.size(), 'Should contain three related documents');

        wrapper.addRequiredAll(null);
        wrapper.addRelatedAll(null);
        System.assertEquals(3, wrapper.requiredDocuments.size(), 'Null should not affect requiredDocuments');
        System.assertEquals(3, wrapper.relatedDocument.size(), 'Null should not affect relatedDocument');

        AppointmentDocumentsResponse chained = new AppointmentDocumentsResponse()
            .addRequired(fileStatus1)
            .addRequiredAll(statusList)
            .addRelated(fileUrl1)
            .addRelatedAll(urlList);

        System.assertEquals(3, chained.requiredDocuments.size(), 'Chained requiredDocuments count should be correct');
        System.assertEquals(3, chained.relatedDocument.size(), 'Chained relatedDocument count should be correct');

        AppointmentDocumentsResponse sameRef = new AppointmentDocumentsResponse();
        AppointmentDocumentsResponse returned = sameRef.addRequired(fileStatus1);
        System.assertEquals(sameRef, returned, 'addRequired should return the same instance (method chaining supported)');
    }
}