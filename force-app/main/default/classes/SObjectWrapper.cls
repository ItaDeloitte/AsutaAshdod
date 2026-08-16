/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Apex Wrapper with predefined values for a standard Salesforce creation window
 * 
 * Test                 SObjectWrapperTest
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             14-10-2021             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public inherited sharing class SObjectWrapper {

    @AuraEnabled
    public String objectApiName {get;set;}
    @AuraEnabled
    public String recordTypeId {get;set;}
    @AuraEnabled
    public Map<String, Object> defaultFieldValues {get;set;}
    @AuraEnabled
    public Object customDetails {get;set;}

    public SObjectWrapper(String objectApiName, String recordTypeId, Map<String, Object> defaultFieldValues, Object customDetails) {
        this.objectApiName = objectApiName;
        this.recordTypeId = recordTypeId;
        this.defaultFieldValues = defaultFieldValues;
        this.customDetails = customDetails;
    }

    public SObjectWrapper(String objectApiName, Map<String, Object> defaultFieldValues, Object customDetails) {
        this(objectApiName, null, defaultFieldValues, customDetails);
    }

    public SObjectWrapper(String objectApiName, String recordTypeId, Map<String, Object> defaultFieldValues) {
        this(objectApiName, recordTypeId, defaultFieldValues, null);
    }

    public SObjectWrapper(String objectApiName, Map<String, Object> defaultFieldValues) {
        this(objectApiName, null, defaultFieldValues, null);
    }
}