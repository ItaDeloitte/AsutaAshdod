public class FileUrlDTO {
    public String fileId { get; set; }
    public String fileName { get; set; }
    public String fileUrl { get; set; }

     public FileUrlDTO(String id, String name, String url) {
        this.fileId = id;
        this.fileName = name;
        this.fileUrl = url;        
    }

    // Builder
    public static FileUrlDTO of(String id, String name, String url) {
        return new FileUrlDTO(id, name, url);
    }
}