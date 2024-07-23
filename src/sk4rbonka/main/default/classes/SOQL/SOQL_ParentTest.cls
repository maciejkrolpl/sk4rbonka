@IsTest
public with sharing class SOQL_ParentTest {
    @TestSetup
    static void makeData() {
        User user1 = sk4_TestDataFactory.createSk4rbonkaUser('John');
        User user2 = sk4_TestDataFactory.createSk4rbonkaUser('Jane');

        sk4_family__c family = sk4_TestDataFactory.createFamilies('Doe', 1)[0];
        insert family;

        sk4_parent__c parent1 = sk4_TestDataFactory.createParent('John', family.Id);
        sk4_parent__c parent2 = sk4_TestDataFactory.createParent('Jane', family.Id);
        parent1.sk4_user__c = user1.Id;
        parent2.sk4_user__c = user2.Id;
        insert new List<sk4_parent__c>{ parent1, parent2 };
    }

    @IsTest
    static void testGetByCurrentUser() {
        User u = [SELECT Id FROM User WHERE LastName = 'John'];
        System.runAs(u) {
            Test.startTest();
            sk4_parent__c parent = (sk4_parent__c) SOQL_Parent.query()
                .byCurrentUser()
                .with(sk4_parent__c.Name)
                .toObject();
            Test.stopTest();

            Assert.areEqual('John', parent.Name);
        }
    }
}
