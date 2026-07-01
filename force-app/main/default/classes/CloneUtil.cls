// Test: CloneUtilTest
public class CloneUtil {

    public class CloneWrapper {
        public String query;
        public List<String> fields;

        public CloneWrapper(String query, List<String> fields) {
            this.query = query;
            this.fields = fields;
        }
    }

    public static CloneWrapper getClone(String sObjectName, String whereCondition) {
        System.debug('CloneUtil.getClone...\nsObjectName: ' + sObjectName + '\nwhereCondition' + whereCondition);
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        List<String> fields = new List<String>();
        String query = 'SELECT';

        for (String field_i : fieldsMap.keySet()) {
            Schema.DescribeFieldResult describe_i = fieldsMap.get(field_i).getDescribe();
            if (describe_i.isCreateable()) {
                fields.add(describe_i.getName());
            }
        }

        for (String name_i : fieldsMap.keySet()) {
            query += ' ' + name_i + ',';
        }
        query = query.removeEnd(',') + ' FROM ' + sObjectName;

        if (String.isNotBlank(whereCondition)) {
            query += ' WHERE ' + whereCondition;
        }
        System.debug('query: ' + query);

        return new CloneWrapper(query, fields);
    }
}