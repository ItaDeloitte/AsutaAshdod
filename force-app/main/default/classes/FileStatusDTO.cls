public class FileStatusDTO {
    public String fileType { get; set; }
    public String fileName { get; set; }
    public String status   { get; set; }

    private static Map<String, PicklistUtil.PicklistValue> picklistMap =
        PicklistUtil.buildPicklistMapping('File__c', 'File_Type__c');

    public FileStatusDTO(String fileType, Boolean found) {
        this.fileType = fileType;
        this.fileName = picklistMap.containsKey(fileType) ? picklistMap.get(fileType).label : fileType;
        this.status   = found ? 'Found' : 'Missing';
    }

    public static FileStatusDTO found(String fileType) {
        return new FileStatusDTO(fileType, true);
    }

    public static FileStatusDTO missing(String fileType) {
        return new FileStatusDTO(fileType, false);
    }
}