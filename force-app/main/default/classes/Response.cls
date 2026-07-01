// Title : Response
// Description : used for return value for most of methods
// 			     
// Parameters :	
// 		- status      - Type: String - 'success', 'error' or 'warning' - used for displaing result of action
// 		- message     - Type: String - contain message about result of action
// 		- responseObj - Type: depend on method - return object that is result of action
global class Response {

    @AuraEnabled
    public Object responseObj {get;set;}
    @AuraEnabled
    public Boolean isSuccess {get;set;}

    public Response() {}

    public Response(Boolean status, String message) {
        this.isSuccess = status;
        this.responseObj = message;
    }

    public Response(Boolean status, Object pResponseObj) {
        this.isSuccess = status;
        this.responseObj = pResponseObj;
    }

    public Response(Object pResponseObj) {
        this(true, pResponseObj);
    }

    public Response(Exception e) {
        String respMessage = e.getMessage();
        if (e instanceof DmlException) {
            DmlException dmlEx = (DmlException) e;
            respMessage = dmlEx.getDmlMessage(0);
        }
        this.isSuccess = false;
        this.responseObj = respMessage;
    }
}