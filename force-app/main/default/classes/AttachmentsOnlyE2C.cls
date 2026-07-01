global class AttachmentsOnlyE2C {//implements Messaging.InboundEmailHandler {
    
    private static final Integer MIN_BYTES = 4096; // 4 KB

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {        
        Messaging.InboundEmailResult res = new Messaging.InboundEmailResult();

        // // 1️⃣ Extract ID number from subject (e.g. "על קלרה חפץ 038500211 איטורו")
        // String subject = email.subject != null ? email.subject : '';

        // List<Account> acc = [SELECT Id FROM Account WHERE PersonEmail = :email.fromAddress LIMIT 1];

        // // 2️⃣ Create case related to the account
        // Case c = new Case(
        //     Origin = 'Email',
        //     Subject = subject,
        //     //Description = 'Files received via email. Body ignored.',
        //     Status = 'New',
        //     AccountId = acc.size() > 0 ? acc[0].Id : null,
        //     SuppliedEmail = email.fromAddress
        // );
        // insert c;

        // List<ContentVersion> cvs = new List<ContentVersion>();

        // // Binary attachments
        // if (email != null && email.binaryAttachments != null) {
        //     for (Messaging.Inboundemail.BinaryAttachment b : email.binaryAttachments) {
        //         if (b == null || b.body == null) continue;
        //         if (b.body.size() < MIN_BYTES) continue; // <-- SKIP <4KB
        //         String fn = String.isBlank(b.fileName) ? 'file' : b.fileName;
        //         cvs.add(new ContentVersion(
        //             Title = fn, PathOnClient = fn, VersionData = b.body, FirstPublishLocationId = c.Id
        //         ));
        //     }
        // }
        // // Text attachments
        // if (email != null && email.textAttachments != null) {
        //     for (Messaging.Inboundemail.TextAttachment t : email.textAttachments) {
        //         if (t == null || t.body == null) continue;
        //         Blob blob_b = Blob.valueOf(t.body);
        //         if (blob_b.size() < MIN_BYTES) continue;   // <-- SKIP <4KB
        //         String fn = String.isBlank(t.fileName) ? 'file.txt' : t.fileName;
        //         cvs.add(new ContentVersion(
        //             Title = fn, PathOnClient = fn, VersionData = blob_b, FirstPublishLocationId = c.Id
        //         ));
        //     }
        // }

        // if (!cvs.isEmpty()) insert cvs;
        res.success = true;
        return res;
    
    }
}