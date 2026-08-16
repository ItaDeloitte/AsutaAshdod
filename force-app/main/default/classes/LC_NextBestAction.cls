// Test: LC_NextBestActionTest
public class LC_NextBestAction implements ILCController {

    public class LC_NextBestActionException extends Exception {}

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        switch on actionName {
            when 'getFields' {
                return this.getFields((String) params.get('recordId'), (String) params.get('apiNames'));
            }
            when else {
                throw new LC_NextBestActionException('UNKNOWN ACTION ' + actionName);
            }
        }
    }

    private Response getFields(String recordId, String apiNames) {
        System.debug('LC_NextBestAction.getFields...\nrecordId: ' + recordId + ' apiNames: ' + apiNames);
        if (String.isBlank(apiNames)) {
            throw new LC_NextBestActionException ('There are no api names is empty.');
        }
        List<String> resultList = new List<String>();
        String query = 'SELECT ' + apiNames + ' FROM ' + Id.valueOf(recordId).getSobjectType() + ' WHERE Id =: recordId';
        System.debug('query ' + query);

        SObject obj = Database.query(query);
        apiNames = apiNames.deleteWhitespace();
        for (String apiName_i : apiNames.split(',')) {
            if (String.isNotBlank(String.valueOf(obj.get(apiName_i)))) {
                resultList.add(String.valueOf(obj.get(apiName_i)));
            }
        }
        System.debug('success\nresultList: ' + resultList);
        return new Response(resultList);
    }
}