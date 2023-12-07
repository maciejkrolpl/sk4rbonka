public with sharing class sk4_TestDataFactory {
    private static Id STANDARD_TRANSFER_RT_ID = Schema.SObjectType.sk4_transfer__c.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId();

    public static User createSk4rbonkaAdminUser(String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(
            Alias = 'tst',
            Email = 'test@sk4rbon.ka',
            EmailEncodingKey = 'UTF-8',
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test@sk4rbon.ka'
        );
        insert u;
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'sk4_admin'
        ];

        System.runAs(u) {
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        }

        return u;
    }
    public static User createSk4rbonkaUser(String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(
            Alias = 'tst',
            Email = 'testuser@sk4rbon.ka',
            EmailEncodingKey = 'UTF-8',
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = lastName + '@sk4rbon.ka'
        );
        insert u;
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'sk4_user'
        ];

        System.runAs(u) {
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        }

        return u;
    }

    public static List<sk4_family__c> createFamilies(String namePrefix, Integer size) {
        List<sk4_family__c> families = new List<sk4_family__c>();
        for (Integer i = 1; i <= size; i++) {
            sk4_family__c family = new sk4_family__c();
            family.Name = namePrefix + i;
            families.add(family);
        }

        return families;
    }

    public static List<sk4_child__c> createChildren(String namePrefix, Integer size, Id familyId) {
        List<sk4_child__c> children = new List<sk4_child__c>();
        for (Integer i = 1; i <= size; i++) {
            sk4_child__c child = new sk4_child__c();
            child.Name = namePrefix + i;
            child.sk4_family__c = familyId;
            children.add(child);
        }
        return children;
    }

    public static sk4_parent__c createParent(String name, Id familyId) {
        sk4_parent__c parent = new sk4_parent__c();
        parent.Name = name;
        parent.sk4_family__c = familyId;
        return parent;
    }

    public static sk4_transfer__c createStandardTransfer(String type, Decimal amount, Id childId, Id parentId) {
        sk4_transfer__c transfer = new sk4_transfer__c();
        transfer.sk4_type__c = type;
        transfer.sk4_transferAmount__c = amount;
        transfer.sk4_child__c = childId;
        transfer.sk4_parent__c = parentId;
        return transfer;
    }

    public static sk4_transfer__c createStandardTransfer(String type, Decimal amount) {
        sk4_transfer__c transfer = new sk4_transfer__c();
        transfer.sk4_type__c = type;
        transfer.sk4_transferAmount__c = amount;
        return transfer;
    }

    public static sk4_cumulation__c createCumulation(Date cumulationDate, Id familyId) {
        sk4_cumulation__c cumulation = new sk4_cumulation__c();
        cumulation.sk4_cumulationDate__c = cumulationDate;
        cumulation.sk4_family__c = familyId;
        return cumulation;
    }
}
