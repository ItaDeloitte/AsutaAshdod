global class AppointmentDocumentsResponse {
    global List<FileStatusDTO> requiredDocuments {get; set;}
    global List<FileUrlDTO> relatedDocument {get; set;}

    public AppointmentDocumentsResponse() {
        requiredDocuments = new List<FileStatusDTO>();
        relatedDocument   = new List<FileUrlDTO>();
    }

    public static AppointmentDocumentsResponse empty() {
        return new AppointmentDocumentsResponse();
    }

    // Builders
    public AppointmentDocumentsResponse addRequired(FileStatusDTO dto) {
        requiredDocuments.add(dto);
        return this;
    }

    public AppointmentDocumentsResponse addRequiredAll(List<FileStatusDTO> dtos) {
        if (dtos != null) requiredDocuments.addAll(dtos);
        return this;
    }

    public AppointmentDocumentsResponse addRelated(FileUrlDTO dto) {
        relatedDocument.add(dto);
        return this;
    }

    public AppointmentDocumentsResponse addRelatedAll(List<FileUrlDTO> dtos) {
        if (dtos != null) relatedDocument.addAll(dtos);
        return this;
    }
}