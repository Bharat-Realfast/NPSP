
@isTest
private class CON_DoNotContact_TDTM_3_Tests {
    
    @testSetup
    static void setup() {
        // Create and insert contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            // Replace the field API names below with the actual field API names from your org
            Deceased__c = false,
            Do_Not_Contact__c = false
        );
        insert testContact;
    }

    @isTest
    static void shouldSetDoNotContactWhenDeceasedOnInsert() {
        // Prepare a new contact marked as deceased
        Contact testContact = new Contact(
            FirstName = 'Deceased',
            LastName = 'Contact',
            // Replace the field API names below with the actual field API names from your org
            Deceased__c = true
        );
        
        // Bypass triggers
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');

        // Start test execution context
        Test.startTest();
        insert testContact; // This should trigger the run method
        Test.stopTest();

        // Fetch the inserted contact record
        Contact insertedContact = [SELECT Deceased__c, Do_Not_Contact__c FROM Contact WHERE Id = :testContact.Id];
        // Verify the Do_Not_Contact__c field is set based on Deceased__c field
        System.assertEquals(true, insertedContact.Do_Not_Contact__c, 'Do_Not_Contact__c should be true when Deceased__c is true');
    }

    @isTest
    static void shouldSetDoNotContactWhenDeceasedOnUpdate() {
        // Retrieve the existing contact from test setup
        Contact testContact = [SELECT Id, Deceased__c FROM Contact LIMIT 1];
        testContact.Deceased__c = true; // Mark the contact as deceased
        
        // Bypass triggers
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');

        // Start test execution context
        Test.startTest();
        update testContact; // This should trigger the run method
        Test.stopTest();

        // Fetch the updated contact record
        Contact updatedContact = [SELECT Deceased__c, Do_Not_Contact__c FROM Contact WHERE Id = :testContact.Id];
        // Verify the Do_Not_Contact__c field is set based on Deceased__c field
        System.assertEquals(true, updatedContact.Do_Not_Contact__c, 'Do_Not_Contact__c should be true when Deceased__c is true');
    }
}
