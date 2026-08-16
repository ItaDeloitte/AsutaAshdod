public class AssutaEmployeeTriggerDispatcher {
	
	public static void fillFormtitanId(List<Assuta_Employee__c> newList){
        System.debug('AssutaEmployeeTriggerDispatcher.fillFormtitanId...');
        for (Assuta_Employee__c emp_i : newList) {
            String randomStr = CommonService.generateRandomKey(15);
            emp_i.FormtitanId__c = randomStr;
            System.debug('emp_i.FormtitanId__c ' + emp_i.FormtitanId__c);
        }
    }

    public static void validateIdNumber(List<Assuta_Employee__c> newList, Map<Id, Assuta_Employee__c> oldMap) {
        System.debug('AssutaEmployeeTriggerDispatcher.validateIdNumber...');
        Map<String, Assuta_Employee__c> idNumbersToEmployeeMap = new Map<String, Assuta_Employee__c>();

        for (Assuta_Employee__c employee_i : newList) {
            if (String.isNotBlank(employee_i.ID_Assuta_Employee__c) && (oldMap == null || employee_i.ID_Assuta_Employee__c != oldMap.get(employee_i.Id).ID_Assuta_Employee__c)) {
                String personIdTmp = employee_i.ID_Assuta_Employee__c.length() < 9 ? '000000000'.substring(employee_i.ID_Assuta_Employee__c.length()) + employee_i.ID_Assuta_Employee__c : employee_i.ID_Assuta_Employee__c;
                idNumbersToEmployeeMap.put(personIdTmp, employee_i);
            }
        }

        if (!idNumbersToEmployeeMap.isEmpty()) {
            System.debug('idNumbersToEmployeeMap ' + idNumbersToEmployeeMap);
            AssutaEmployeeService.validateIdNumber(idNumbersToEmployeeMap);
        }
    }

    public static void createContact(List<Assuta_Employee__c> newList, Map<Id, Assuta_Employee__c> oldMap) {
        System.debug('AssutaEmployeeTriggerDispatcher.createContact...');
        Map<Id, Assuta_Employee__c> employeeIdsMap = new Map<Id, Assuta_Employee__c>();

        for (Assuta_Employee__c employee_i : newList) {
            if (oldMap == null || 
                employee_i.Email__c != oldMap.get(employee_i.Id).Email__c ||
                employee_i.Last_Name__c != oldMap.get(employee_i.Id).Last_Name__c ||
                employee_i.First_Name__c != oldMap.get(employee_i.Id).First_Name__c ||
                employee_i.Status__c != oldMap.get(employee_i.Id).Status__c ||
                employee_i.ID_Assuta_Employee__c != oldMap.get(employee_i.Id).ID_Assuta_Employee__c) {
                    employeeIdsMap.put(employee_i.Id, employee_i);
            }
        }

        if (!employeeIdsMap.isEmpty()) {
            System.debug('employeeIdsMap ' + employeeIdsMap);
            AssutaEmployeeService.createContact(employeeIdsMap);
        }
    }
}