@IsTest
public with sharing class sk4_WholesaleTest {
    private final static String ADMIN_NAME = 'TestAdmin';
    private final static String USER_NAME = 'TestUser';
    private final static String FAMILY_NAME = 'Doe';
    private final static String CHILD0_NAME = 'Joe';
    private final static String CHILD1_NAME = 'Jane';
    private final static String PARENT_NAME = 'Ian';
    @TestSetup
    static void makeData() {
        User u = sk4_TestDataFactory.createSk4rbonkaAdminUser(ADMIN_NAME);
        User uu = sk4_TestDataFactory.createSk4rbonkaUser(USER_NAME);

        List<sk4_family__c> families = sk4_TestDataFactory.createFamilies(FAMILY_NAME, 2);
        insert families;

        List<sk4_child__c> children0 = sk4_TestDataFactory.createChildren(CHILD0_NAME, 4, families[0].Id);
        List<sk4_child__c> children1 = sk4_TestDataFactory.createChildren(CHILD1_NAME, 5, families[1].Id);
        insert children0;
        insert children1;

        sk4_parent__c parent = sk4_TestDataFactory.createParent(PARENT_NAME, families[0].Id);
        parent.sk4_user__c = uu.Id;
        insert parent;
    }

    @IsTest
    static void testGetChildren() {
        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :ADMIN_NAME
        ];

        System.runAs(u) {
            Test.startTest();
            List<sk4_Wholesale.ChildWrapper> children = sk4_Wholesale.getAllChildren();
            Test.stopTest();

            Assert.areEqual(9, children.size());
        }
    }

    @IsTest
    static void testGetChildrenForStdUser() {
        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];

        sk4_family__c family = [
            SELECT Id
            FROM sk4_family__c
            WHERE Name = :FAMILY_NAME + '1'
        ];
        sk4_family__Share share = new sk4_family__Share();
        share.ParentId = family.Id;
        share.UserOrGroupId = u.Id;
        share.AccessLevel = 'Edit';
        share.RowCause = 'Manual';
        insert share;

        System.runAs(u) {
            Test.startTest();
            List<sk4_Wholesale.ChildWrapper> children = sk4_Wholesale.getAllChildren();
            Test.stopTest();

            Assert.areEqual(4, children.size());
        }
    }

    @IsTest
    static void testCreateTransfersForStdUser() {
        User u = [
            SELECT Id
            FROM User
            WHERE LastName = :USER_NAME
        ];

        sk4_family__c family = [
            SELECT Id
            FROM sk4_family__c
            WHERE Name = :FAMILY_NAME + '1'
        ];
        sk4_family__Share share = new sk4_family__Share();
        share.ParentId = family.Id;
        share.UserOrGroupId = u.Id;
        share.AccessLevel = 'Edit';
        share.RowCause = 'Manual';
        insert share;

        System.runAs(u) {
            List<sk4_Wholesale.ChildWrapper> children = sk4_Wholesale.getAllChildren();

            List<sk4_Wholesale.ChildWrapper> wrappers = new List<sk4_Wholesale.ChildWrapper>();

            sk4_Wholesale.ChildWrapper w0 = new sk4_Wholesale.ChildWrapper();
            w0.id = children[0].Id;
            w0.give = 50;

            sk4_Wholesale.ChildWrapper w1 = new sk4_Wholesale.ChildWrapper();
            w1.id = children[1].Id;
            w1.give = 50;

            sk4_Wholesale.ChildWrapper w2 = new sk4_Wholesale.ChildWrapper();
            w2.id = children[2].Id;
            w2.give = 50;

            sk4_Wholesale.ChildWrapper w3 = new sk4_Wholesale.ChildWrapper();
            w3.id = children[3].Id;
            w3.give = 50;

            Test.startTest();
            sk4_Wholesale.saveNewTransfers(new List<sk4_Wholesale.ChildWrapper>{ w0, w1, w2, w3 });
            Test.stopTest();

            List<sk4_transfer__c> transfers = [SELECT Id FROM sk4_transfer__c];

            Assert.areEqual(4, transfers.size());
        }
    }
}
