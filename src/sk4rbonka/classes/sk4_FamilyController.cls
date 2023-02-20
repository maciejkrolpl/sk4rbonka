@RestResource(urlMapping = '/Family/*')
global with sharing class sk4_FamilyController {
    @HttpGet
    global static List<sk4_family__c> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<sk4_family__c> families = [SELECT Id, Name, sk4_cumulationDay__c, sk4_cumulationPercent__c, sk4_defaultPocketMoneyAmount__c
                                        FROM sk4_family__c];
        return families;
    }

}