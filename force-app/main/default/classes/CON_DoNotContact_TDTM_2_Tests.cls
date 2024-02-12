
@isTest
private class CON_DoNotContact_TDTM_2_Tests {

    @testSetup
    static void setup() {
        // Create test data with the correct field API names or standard Salesforce fields
        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;

        // Use a standard field or the correct API name of your custom "Deceased" field
        Contact testContact = new Contact(
            LastName = 'TestContact',
            AccountId = testAccount.Id,
            HasOptedOutOfEmail = false, // Assuming this represents "Do Not Contact"
            IsDeceased__c = false // Replace with the correct API name if different
        );
        insert testContact;
    }

    // Happy Path Test
    @isTest
    static void testMarkContactDeceasedWithAccount() {
        // Bypass triggers
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');

        // Prepare test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id, HasOptedOutOfEmail FROM Contact LIMIT 1];
        testContact.IsDeceased__c = true; // Replace with the correct API name if different

        CON_DoNotContact_TDTM handler = new CON_DoNotContact_TDTM();

        // Execute the method within Test context
        Test.startTest();
        handler.markContactDeceased(testContact, testAccount);
        Test.stopTest();

        // Query for results and assert
        Contact updatedContact = [SELECT HasOptedOutOfEmail FROM Contact WHERE Id = :testContact.Id];
        Account updatedAccount = [SELECT npe01__One2OneContact__c FROM Account WHERE Id = :testAccount.Id];

        // Assertions
        System.assertEquals(true, updatedContact.HasOptedOutOfEmail, 'Contact should be marked as Do Not Contact');
        System.assertNotEquals(null, updatedAccount.npe01__One2OneContact__c, 'The one-to-one contact should be set');
    }

    // Sad Path Test
    @isTest
    static void testMarkContactDeceasedWithNoAccount() {
        // Bypass triggers
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');

        // Prepare test data
        Contact testContact = [SELECT Id, HasOptedOutOfEmail FROM Contact LIMIT 1];
        testContact.IsDeceased__c = true; // Replace with the correct API name if different

        CON_DoNotContact_TDTM handler = new CON_DoNotContact_TDTM();

        // Execute the method within Test context
        Test.startTest();
        handler.markContactDeceased(testContact, null);
        Test.stopTest();

        // Query for results and assert
        Contact updatedContact = [SELECT HasOptedOutOfEmail FROM Contact WHERE Id = :testContact.Id];
        
        // Assertions
        System.assertEquals(true, updatedContact.HasOptedOutOfEmail, 'Contact should be marked as Do Not Contact');
    }

    // Exceptional Path Test
    @isTest
    static void testMarkContactNotDeceased() {
        // Bypass triggers
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');

        // Prepare test data
        Contact testContact = [SELECT Id, HasOptedOutOfEmail FROM Contact LIMIT 1];

        CON_DoNotContact_TDTM handler = new CON_DoNotContact_TDTM();

        // Execute the method within Test context
        Test.startTest();
        handler.markContactDeceased(testContact, null);
        Test.stopTest();

        // Query for results and assert
        Contact updatedContact = [SELECT HasOptedOutOfEmail FROM Contact WHERE Id = :testContact.Id];

        // Assertions
        System.assertEquals(false, updatedContact.HasOptedOutOfEmail, 'Contact should not be marked as Do Not Contact');
    }
}
