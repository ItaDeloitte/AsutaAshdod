/**
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Apex Test class for AsyncUtil
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 * @created             09-02-2022             <evgeniy.kravchuk@synebo.io>
 * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
@IsTest
public without sharing class AsyncUtilTest {

    @TestSetup
    static void makeData() {
        insert TestDataFactory.getENV();
    }

    @IsTest
    static void mainTest() {
        List<SObject> records = new List<SObject>{TestDataFactory.getAccountDoctor()};

        Test.startTest();
        Set<Id> ids = AsyncUtil.doInsert(records);
        AsyncUtil.doUpdate(records);
        AsyncUtil.doDelete(records);
        AsyncUtil.doUndelete(records);
        AsyncUtil.doDelete(ids);
        AsyncUtil.doUndelete(ids);
        Test.stopTest();
    }
}