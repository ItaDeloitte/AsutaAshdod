global with sharing class GeneralResponse {

    webservice Boolean isSuccess { get; set; }
    webservice String message { get; set; }
    
    public GeneralResponse() { }

    public GeneralResponse(Boolean status, String pMessage){
        this.isSuccess = status;
        this.message = pMessage;
    }

    public GeneralResponse(Exception e){
        this.isSuccess = false;

        String respMessage = e.getMessage();
        if (e instanceof DmlException){
            DmlException dmlEx = (DmlException)e;
            respMessage = dmlEx.getDmlMessage(0);
        }
        this.message = respMessage;
    }
}