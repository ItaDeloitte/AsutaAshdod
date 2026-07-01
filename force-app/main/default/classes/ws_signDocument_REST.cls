//ContentDocumentLinkServiceTest
public with sharing class ws_signDocument_REST implements Queueable, Database.AllowsCallouts{
    
    public Id conVersionId;
    private ContentVersion oldCV = null;
    private File__c file = null;

    public ws_signDocument_REST(Id conVersionId) {
        this.conVersionId = conVersionId;
    }

    public void execute(QueueableContext context){
        this.oldCV = [SELECT Id, VersionData, PathOnClient, ContentUrl, Title, PublishStatus, Origin, ContentDocumentId FROM ContentVersion WHERE Id =: this.conVersionId LIMIT 1];
        this.file = [SELECT Id, OriginFileVisible__c FROM File__c WHERE Content_Version_Id__c =:this.oldCV.ContentDocumentId LIMIT 1]; 
        signDocument();
    }

    private void signDocument() {
        String blobDoc = EncodingUtil.base64Encode(this.oldCV.VersionData);
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('Guid', conVersionId);
            gen.writeStringField('CertID', 'itgrdocuusr'); 
            gen.writeStringField('SystemId', '16'); 
            gen.writeStringField('InputFile', blobDoc);
            gen.writeStringField('Page', '1'); 
            gen.writeStringField('X', '380');
            gen.writeStringField('Y', '730');
            gen.writeStringField('Width', '200');
            gen.writeStringField('Height', '80');
            gen.writeStringField('Pincode', 'D0cu@20');                        
            gen.writeStringField('Image', '');
            gen.writeEndObject();
        System.debug('gen.getAsString(): ' + gen.getAsString());

        ENV__c env = ENV__c.getInstance();   
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:Ensemble_Rest_' + env.Env_value__c + '/DocuSign/SignDocument?');               
        request.setBody(gen.getAsString());                

        try {
            HttpResponse response = http.send(request);
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('results: ' + results);
            if ((Boolean)(results.get('success'))) {
                Blob blobOfFile = EncodingUtil.base64Decode(String.ValueOf(results.get('signedFile')));
                insert new ContentVersion(VersionData = blobOfFile
                                              , Title = oldCV.Title
                                              , ContentDocumentId = oldCV.ContentDocumentId
                                              , PathOnClient = oldCV.PathOnClient
                                              , ContentUrl = oldCV.ContentUrl
                                              , Origin = 'H');
                update new File__c(Id = this.file.Id
                                       , SendComSign__c = true
                                       , OriginFileVisible__c = true);
            }
        } catch (exception e) {
            System.debug('Error: An exception has been encountered while calling out to sign Document:  ' + e.getMessage());
        }
    }
}