global without sharing class Bot_Response {

    @InvocableVariable(label='is_success' description='Is Sucess?')
    public Boolean isSuccses;
    @InvocableVariable(label='errorText' description='Error if not success')
    public String errorText;
    @InvocableVariable(label='listOfIds' description='List of id from inserted records, if success')
    public List<String> listOfIds;

    public Bot_Response(List<String> incommingList) {
        this.isSuccses = true;
        this.errorText = '';
        this.listOfIds = incommingList;
    }

    public Bot_Response(Exception e) {
        this.isSuccses = false;
        this.errorText = e.getMessage();
        this.listOfIds = null;
    }
}