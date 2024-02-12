
@isTest
private class CON_DoNotContact_TDTM_4_Tests {

    @testSetup
    static void setup() {
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Doe',
            Do_Not_Contact__c = false  // Assuming this is the correct API name for the custom field
        );
        insert testContact;
    }

    private static void bypassTriggers() {
        // Bypass Account triggers
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('MDTAccountTriggerHandler');
    }

    @isTest
    static void testContactDoNotContactWhenTrue() {
        bypassTriggers();
        
        // Retrieve the test Contact record and set Do_Not_Contact__c to true
        Contact testContact = [SELECT Id, Do_Not_Contact__c FROM Contact LIMIT 1];
        testContact.Do_Not_Contact__c = true;
        
        // Create an instance of CON_DoNotContact_TDTM and call the method
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.markContactDoNotContact(testContact);
        
        // Persist the changes
        update testContact;
        
        // Re-query for updated Contact record
        testContact = [SELECT HasOptedOutOfEmail, DoNotCall FROM Contact WHERE Id = :testContact.Id];
        
        // Assert the expected outcomes
        System.assertEquals(true, testContact.HasOptedOutOfEmail, 'HasOptedOutOfEmail should be true when Do_Not_Contact__c is true.');
        System.assertEquals(true, testContact.DoNotCall, 'DoNotCall should be true when Do_Not_Contact__c is true.');
    }

    @isTest
    static void testContactDoNotContactWhenFalse() {
        bypassTriggers();
        
        // Retrieve the test Contact record and keep Do_Not_Contact__c as false
        Contact testContact = [SELECT Id, Do_Not_Contact__c FROM Contact LIMIT 1];
        
        // Create an instance of CON_DoNotContact_TDTM and call the method
        CON_DoNotContact_TDTM conDoNotContactTDTM = new CON_DoNotContact_TDTM();
        conDoNotContactTDTM.markContactDoNotContact(testContact);
        
        // Persist the changes
        update testContact;
        
        // Re-query for updated Contact record
        testContact = [SELECT HasOptedOutOfEmail, DoNotCall FROM Contact WHERE Id = :testContact.Id];
        
        // Assert the expected outcomes
        System.assertEquals(false, testContact.HasOptedOutOfEmail, 'HasOptedOutOfEmail should be false when Do_Not_Contact__c is false.');
        System.assertEquals(false, testContact.DoNotCall, 'DoNotCall should be false when Do_Not_Contact__c is false.');
    }
}
