public class MetadataUtility {
    
    public static Set<String> getAllFields(String objType) {
        Set<String> fieldsList = new Set<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objType);
        Map<String,Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
        for(Schema.SObjectField field : fieldMap.values()) {
            fieldsList.add(field.getDescribe().getName());
        }
        return fieldsList;
    }
}