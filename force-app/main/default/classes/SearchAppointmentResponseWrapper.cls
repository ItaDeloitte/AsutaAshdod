global without sharing class SearchAppointmentResponseWrapper {
     
        @InvocableVariable(label='is_success' description='Is Sucess?')
        public Boolean isSuccses;
        @InvocableVariable(label='errorText' description='Error if not success')
        public String errorText;
        @InvocableVariable(label='listOfIds' description='List of id from inserted records, if success')
        public List <String> listOfIds;

        public SearchAppointmentResponseWrapper(List <String> incommingList){
            this.isSuccses = true;
            this.errorText = '';
            this.listOfIds = incommingList;
        }

        public SearchAppointmentResponseWrapper(Exception e){
            this.isSuccses = false;
            this.errorText = e.getMessage();
            this.listOfIds = null;
        }
    
}