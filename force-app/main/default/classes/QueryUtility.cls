public class QueryUtility {
    private static Map<String,Query__mdt> queryData;
    private static Map<String,Set<String>> tagsData;
    private static final AccessLevel DEFAULT_ACCESS_LEVEL = AccessLevel.SYSTEM_MODE;
    
    public static  Map<String,Query__mdt> getAllQueryData() {
        if(queryData == null) {
            for(Query__mdt q : [SELECT Id,MasterLabel,DeveloperName,IsAggregate__c,FieldsCsv__c,Filter__c,Limit__c,OrderyBy__c,ParametersCsv__c,sObject__c,sObject__r.QualifiedApiName,Tags__c FROM Query__mdt]) {
                queryData.put(q.DeveloperName,q);
                if(q.Tags__c != null) {
                    List<String> tagsSplit = q.Tags__c.split(',');
                    for(String t : tagsSplit) {
                        t = t.trim();
                        if(!tagsData.containsKey(t)) tagsData.put(t,new Set<String>());
                        tagsData.get(t).add(q.DeveloperName);
                    }
                }
            }
        }
        return queryData;
    }
    
    public static Query__mdt getQuery(String queryKey) {
        getAllQueryData();
        return queryData.get(queryKey);
    }
	
	//START: BUILD QUERY    
    public static String buildQuery(String queryKey) {
        Query__mdt qData = getQuery(queryKey);
        String query = 'SELECT';
        query += ' ' + buildFieldsList(qData.sObject__r.QualifiedApiName,qData.FieldsCsv__c) + ' ';
        query += ' FROM ';
		query += qData.sObject__r.QualifiedApiName;
		if(qData.Filter__c != null && qData.Filter__c.trim() != '') query += ' WHERE ' + qData.Filter__c + ' ';
		if(qData.OrderyBy__c != null && qData.OrderyBy__c.trim() != '') query += ' ORDER BY ' + qData.OrderyBy__c + ' ';
        query += ' LIMIT ' + (qData.Limit__c != null ? qData.Limit__c : 2000);
        return query;
    }
    
    public static List<sObject> executeQueryFromKey(String key) {
        return executeQuery(buildQuery(key));
    }
    public static List<sObject> executeQuery(String query) {
        return executeQuery(query,null,DEFAULT_ACCESS_LEVEL);
    }
    public static List<sObject> executeQuery(String query,Map<String,Object> inputBindMap) {
        return executeQuery(query,inputBindMap,DEFAULT_ACCESS_LEVEL);
    }
    public static List<sObject> executeQuery(String query,AccessLevel al) {
        return executeQuery(query,null,DEFAULT_ACCESS_LEVEL);
    }
    public static List<sObject> executeQuery(String query,Map<String,Object> inputBindMap,AccessLevel al) {
        if(inputBindMap == null) inputBindMap = new Map<String,Object>();
        if(al == null) al = DEFAULT_ACCESS_LEVEL;
        List<sObject> data;
        try {
            data = Database.queryWithBinds(query,inputBindMap,al);
        } catch(QueryException qe) {
            //TODO
        }
        return data;
    }
    //TODO
    public static List<AggregateResult> executeAggregateQuery() {
        return null;
    }
    
    private static String buildFieldsList(String sObjectName,String fieldsCsv) {
        if(fieldsCsv != NULL && fieldsCsv.trim() == '*') {
            fieldsCsv = String.join(MetadataUtility.getAllFields(sObjectName),',');
        }
        return fieldsCsv;
    }
	//END: BUILD QUERY
	
	
	//START: RUN QUERY  
	//END: RUN QUERY  
}