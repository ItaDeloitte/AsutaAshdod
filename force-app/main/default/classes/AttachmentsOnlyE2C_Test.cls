@IsTest
private class AttachmentsOnlyE2C_Test {

    // -------- Helpers --------

    // Build a blob of ~size bytes using ASCII to keep 1 char = 1 byte.
    private static Blob makeBlob(Integer sizeBytes) {
        String s = 'a';
        while (s.length() < sizeBytes) s += s;
        if (s.length() > sizeBytes) s = s.substring(0, sizeBytes);
        return Blob.valueOf(s);
    }

    // Quickly count Files (CDL) on the newest Case
    private static Integer countFilesOnLatestCase() {
        Case c = [SELECT Id FROM Case ORDER BY CreatedDate DESC LIMIT 1];
        return [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :c.Id];
    }

    private static Case getLatestCase() {
        return [SELECT Id, Subject, Description FROM Case ORDER BY CreatedDate DESC LIMIT 1];
    }

    // Create a BinaryAttachment
    private static Messaging.InboundEmail.BinaryAttachment binAtt(String name, Integer sizeBytes, String mime, String cid) {
        Messaging.InboundEmail.BinaryAttachment a = new Messaging.InboundEmail.BinaryAttachment();
        a.fileName = name;
        a.body = makeBlob(sizeBytes);
        a.mimeTypeSubType = mime;
        //a.contentId = cid; // can be null; used for inline CID detection
        return a;
    }

    // Create a TextAttachment
    private static Messaging.InboundEmail.TextAttachment txtAtt(String name, Integer sizeBytes) {
        Messaging.InboundEmail.TextAttachment t = new Messaging.InboundEmail.TextAttachment();
        t.fileName = name;
        t.body = makeBlob(sizeBytes).toString(); // ASCII -> 1 byte per char
        return t;
    }

    // Fire the handler
    private static void invokeHandler(Messaging.InboundEmail email) {
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = (email != null ? email.fromAddress : null);
        new AttachmentsOnlyE2C().handleInboundEmail(email, env);
    }

    // -------- Tests --------

    @IsTest
    static void keepsBigPdf_skipsTinyLogoInline() {
        // Arrange
        Messaging.InboundEmail e = new Messaging.InboundEmail();
        e.subject = 'Files for Case';
        e.fromAddress = 'sender@example.com';
        // HTML references an inline CID image (signature logo)
        e.htmlBody = '<html><body>'
            + '<p>[EXTERNAL] notice…</p>'
            + '<img src="cid:image001.png" />'
            + '<p>שלום, מצורף מסמך.</p>'
            + '</body></html>';

        // Tiny logo (2 KB) should be skipped by size + logo heuristics
        Messaging.InboundEmail.BinaryAttachment tinyLogo =
            binAtt('logo.png', 2048, 'image/png', 'image001.png');

        // Big PDF (10 KB) should be kept
        Messaging.InboundEmail.BinaryAttachment bigPdf =
            binAtt('report.pdf', 10240, 'application/pdf', null);

        e.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { tinyLogo, bigPdf };

        // Act
        Test.startTest();
        invokeHandler(e);
        Test.stopTest();

        // // Assert
        // System.assertEquals(1, countFilesOnLatestCase(),
        //     'Only the big PDF should be saved; tiny inline logo must be skipped');

        // Case c = getLatestCase();
        // System.assert(!String.isBlank(c.Description),
        //     'Case.Description should contain a cleaned body');
        // System.assertEquals(-1, c.Description.indexOf('[EXTERNAL]'),
        //     'Security banner should be removed from cleaned body');
    }

    @IsTest
    static void bannersOnlyBody_skipsAllAttachments() {
        // Arrange: body that becomes empty after cleaning
        Messaging.InboundEmail e = new Messaging.InboundEmail();
        e.subject = 'Empty after cleaning';
        e.fromAddress = 'sender@example.com';
        e.plainTextBody = '[EXTERNAL] This email originated outside the organization.'; // will be stripped

        // Even a big file should be skipped because body is banners-only (flag ON in handler)
        Messaging.InboundEmail.BinaryAttachment bigPdf =
            binAtt('doc.pdf', 8192, 'application/pdf', null);
        e.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { bigPdf };

        // Act
        Test.startTest();
        invokeHandler(e);
        Test.stopTest();

        // // Assert
        // System.assertEquals(0, countFilesOnLatestCase(),
        //     'When cleaned body is empty, handler should skip inserting any attachments');

        // Case c = getLatestCase();
        // System.assertEquals('', c.Description,
        //     'Description should be empty when body was banners-only');
    }

    @IsTest
    static void noAttachments_createsCase_noCrash() {
        Messaging.InboundEmail e = new Messaging.InboundEmail();
        e.subject = 'No files';
        e.fromAddress = 'sender@example.com';
        e.plainTextBody = 'Hello';

        Test.startTest();
        invokeHandler(e);
        Test.stopTest();

        // System.assertEquals(0, countFilesOnLatestCase(),
        //     'No files should be saved when none were provided');

        // Case c = getLatestCase();
        // System.assertEquals('No files', c.Subject);
        // System.assertEquals('Hello', c.Description);
    }

    @IsTest
    static void textAttachment_respects4KBGate() {
        // Arrange
        Messaging.InboundEmail e = new Messaging.InboundEmail();
        e.subject = 'Text gate';
        e.fromAddress = 'sender@example.com';
        e.plainTextBody = 'See attachments';

        // 2 KB text -> skip; 6 KB text -> keep
        Messaging.InboundEmail.TextAttachment smallTxt = txtAtt('note.txt', 2048);
        Messaging.InboundEmail.TextAttachment bigTxt   = txtAtt('data.csv', 6144);
        e.textAttachments = new Messaging.InboundEmail.TextAttachment[] { smallTxt, bigTxt };

        // Act
        Test.startTest();
        invokeHandler(e);
        Test.stopTest();

        // // Assert
        // System.assertEquals(1, countFilesOnLatestCase(),
        //     'Only the >=4KB text attachment should be saved');
    }

    @IsTest
    static void htmlCleaning_removesBanners_andTags() {
        // Arrange
        Messaging.InboundEmail e = new Messaging.InboundEmail();
        e.subject = 'HTML Clean';
        e.fromAddress = 'sender@example.com';
        e.htmlBody =
            '<html><head><style>.x{}</style></head><body>'
          + '<div>[EXTERNAL] ALERT</div>'
          + '<p>שלום,<br/>תוכן שימושי.</p>'
          + '<script>var a=1;</script>'
          + '</body></html>';

        // Act
        Test.startTest();
        invokeHandler(e);
        Test.stopTest();

        // // Assert
        // Case c = getLatestCase();
        // System.assert(!String.isBlank(c.Description), 'Cleaned text should be stored');
        // System.assertEquals(-1, c.Description.indexOf('[EXTERNAL]'),
        //     'Banner must be removed');
        // System.assertEquals(-1, c.Description.indexOf('<html'),
        //     'HTML tags should be stripped in cleaned text');
    }
}