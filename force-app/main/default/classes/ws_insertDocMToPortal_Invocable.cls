global with sharing class ws_insertDocMToPortal_Invocable {

    @InvocableMethod
    global static void runBatchable() {
        ws_insertDocMaccabiToPortalREST b = new ws_insertDocMaccabiToPortalREST(); 
        database.executebatch(b);
    }


}