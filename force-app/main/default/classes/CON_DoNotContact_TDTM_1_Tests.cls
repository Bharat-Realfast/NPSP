
@isTest
public class CON_DoNotContact_TDTM_1_Tests {

    @testSetup
    static void makeTestData() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Contact linked to the Account
        Contact testContact = new Contact(LastName = 'Test', AccountId = testAccount.Id);
        // Add more fields to the Contact as necessary, with their actual API names
        insert testContact;
    }

    private static void disableTriggerHandlers() {
        // Disable or bypass the trigger handlers for the Account and Contact objects
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');
    }

    @isTest
    static void testContactBeforeInsert() {
        disableTriggerHandlers();
        
        // Set up new Contact data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact newContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id,
            DoNotCall = true,
            HasOptedOutOfEmail = true
        );

        Test.startTest();
        // Perform the DML operation that triggers the logic in CON_DoNotContact_TDTM
        insert newContact;
        Test.stopTest();
        
        // Retrieve and assert the changes made by the trigger logic
        Contact retrievedContact = [SELECT Id, DoNotCall, HasOptedOutOfEmail FROM Contact WHERE Id = :newContact.Id];
        System.assertEquals(true, retrievedContact.DoNotCall, 'The contact should have DoNotCall set to true.');
        System.assertEquals(true, retrievedContact.HasOptedOutOfEmail, 'The contact should have HasOptedOutOfEmail set to true.');
    }

    // Additional test methods for other test scenarios should follow a similar pattern
}
