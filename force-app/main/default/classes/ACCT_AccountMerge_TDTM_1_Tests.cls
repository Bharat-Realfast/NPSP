
@isTest
private class ACCT_AccountMerge_TDTM_1_Tests {

    @testSetup
    static void makeTestData() {
        // Create two test accounts to simulate account merge scenario
        Account acc1 = new Account(Name='Test Account 1');
        Account acc2 = new Account(Name='Test Account 2');
        insert new List<Account> {acc1, acc2};
    }
    
    // Helper method to bypass the triggers
    private static void bypassTriggers() {
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');
    }
    
    // Test method for simulating the after delete scenario when accounts are merged
    @isTest
    static void testAfterDeleteWithAccountMerge() {
        bypassTriggers();
        
        // Fetch the test accounts and delete one to simulate account merge scenario
        List<Account> accounts = [SELECT Id FROM Account];
        delete accounts[0];

        // Create a simulated list of old accounts as they would appear after a delete triggered by a merge
        Account simulatedOldMergedAccount = new Account(Id=accounts[0].Id, Name='Merged Account');
        List<SObject> oldAccountsList = new List<SObject>{simulatedOldMergedAccount};

        Test.startTest();
        // Instantiate the TDTM handler class and invoke the run method
        ACCT_AccountMerge_TDTM handler = new ACCT_AccountMerge_TDTM();
        handler.run(new List<SObject>(), oldAccountsList, /* Replace with the actual enum for AfterDelete */, Account.SObjectType.getDescribe());
        Test.stopTest();

        // Assert that a future job has been enqueued for the account merge fixups
        System.assertEquals(1, Limits.getFutureCalls(), 'Expected a future job to be enqueued for merge fixups');
    }

    // Test method for scenario where the trigger action is not AfterDelete
    @isTest
    static void testNonAfterDeleteAction() {
        bypassTriggers();

        // Instantiate the TDTM handler class and invoke the run method with a different trigger action
        ACCT_AccountMerge_TDTM handler = new ACCT_AccountMerge_TDTM();
        Test.startTest();
        handler.run(new List<SObject>(), new List<SObject>(), /* Replace with the actual enum for a non-delete action */, Account.SObjectType.getDescribe());
        Test.stopTest();

        // Assert that no future job should be enqueued as the trigger action is not AfterDelete
        System.assertEquals(0, Limits.getFutureCalls(), 'No future job should be enqueued for non-AfterDelete actions');
    }

    // Additional test methods for other scenarios should follow the same pattern
    // ...
}
