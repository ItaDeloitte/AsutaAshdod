// Test: ExpertProcedureServiceTest
public class ExpertProcedureService {

    private static ExpertProcedureService instance;

    private Map<String, Expert_Procedures__mdt> mdtMap;

    /** INSTANCE */
    public static ExpertProcedureService getInstance() {
        if (instance == null) {
            instance = new ExpertProcedureService();
        }
        return instance;
    }

    /** CONSTRUCTOR */
    private ExpertProcedureService() {
        this.obtainMdtMap();
    }

    /** METHODS */
    public List<String> getAll() {
        return new List<String>(this.mdtMap.keySet());
    }

    public List<String> getAllPublic() {
        List<String> codeList = new List<String>();

        for (Expert_Procedures__mdt mdt_i : this.mdtMap.values()) {
            if (!mdt_i.IsPrivate__c) {
                codeList.add(mdt_i.ProcedureCode__c);
            }
        }

        return codeList;
    }

    public List<String> getAllPrivate() {
        List<String> codeList = new List<String>();

        for (Expert_Procedures__mdt mdt_i : this.mdtMap.values()) {
            if (mdt_i.IsPrivate__c) {
                codeList.add(mdt_i.ProcedureCode__c);
            }
        }

        return codeList;
    }

    public List<String> getPublicDefault() {
        List<String> codeList = new List<String>();

        for (Expert_Procedures__mdt mdt_i : this.mdtMap.values()) {
            if (!mdt_i.IsPrivate__c && mdt_i.IsDefault__c) {
                codeList.add(mdt_i.ProcedureCode__c);
                break;
            }
        }

        return codeList;
    }

    public List<String> getPrivateDefault() {
        List<String> codeList = new List<String>();

        for (Expert_Procedures__mdt mdt_i : this.mdtMap.values()) {
            if (mdt_i.IsPrivate__c && mdt_i.IsDefault__c) {
                codeList.add(mdt_i.ProcedureCode__c);
                break;
            }
        }

        return codeList;
    }

    /** INNER METHODS */
    private void obtainMdtMap() {
        this.mdtMap = new Map<String, Expert_Procedures__mdt>();

        for (Expert_Procedures__mdt mdt_i : Expert_Procedures__mdt.getAll().values()) {
            this.mdtMap.put(mdt_i.ProcedureCode__c, mdt_i);
        }
    }
}