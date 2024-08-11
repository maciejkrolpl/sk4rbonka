public with sharing class sk4_CumulateTriggerHandler {
    public static void beforeInsert(List<sk4_cumulation__c> cumulations) {
        checkIsCumulationInCurrentMonth(cumulations);
    }

    public static void beforeUpdate(List<sk4_cumulation__c> cumulations) {
        preventUpdating(cumulations);
    }

    public static void beforeDelete(Map<Id, sk4_cumulation__c> cumulations) {
        deleteTransfers(cumulations.keySet());
    }

    public static void afterInsert(List<sk4_cumulation__c> cumulations) {
        createCumulationTransfers(cumulations);
    }

    private static void deleteTransfers(Set<Id> cumulationIds) {
        delete SOQL_Transfer.query().byCumulationIds(cumulationIds).toList();
    }

    private static void preventUpdating(List<sk4_cumulation__c> cumulations) {
        for (sk4_cumulation__c c : cumulations) {
            c.addError('Editing is not allowed. Delete cumulation and create new one.');
        }
    }

    private static void createCumulationTransfers(List<sk4_cumulation__c> cumulations) {
        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>();
        Map<Id, sk4_cumulation__c> familyToCumulation = new Map<Id, sk4_cumulation__c>();

        for (sk4_cumulation__c c : cumulations) {
            familyToCumulation.put(c.sk4_family__c, c);
        }

        List<sk4_child__c> children = SOQL_Child.query()
            .byFamilyIds(familyToCumulation.keySet())
            .with(sk4_child__c.sk4_balance2__c, sk4_child__c.sk4_family__c)
            .with(
                'sk4_family__r',
                new List<SObjectField>{
                    sk4_family__c.sk4_cumulationPercent__c,
                    sk4_family__c.sk4_cumulationUpperTreshold__c,
                    sk4_family__c.sk4_cumulationLowerTreshold__c
                }
            )
            .preview()
            .toList();

        for (sk4_child__c child : children) {
            sk4_transfer__c transfer = sk4_CreateTransfers.createCumulationTransfer(child) ;
            transfer.sk4_cumulation__c = familyToCumulation.get(child.sk4_family__c).Id;
            transfers.add(transfer);
        }

        insert transfers;
    }

    private static void checkIsCumulationInCurrentMonth(List<sk4_cumulation__c> cumulations) {
        Map<Id, List<sk4_cumulation__c>> familyToCumulation = new Map<Id, List<sk4_cumulation__c>>();

        for (sk4_cumulation__c c : (List<sk4_cumulation__c>) SOQL_Cumulation.query().toList()) {
            List<sk4_cumulation__c> familiesCumuls = new List<sk4_cumulation__c>();
            if (familyToCumulation.get(c.sk4_family__c) != null) {
                familiesCumuls = familyToCumulation.get(c.sk4_family__c);
            }
            familiesCumuls.add(c);
            familyToCumulation.put(c.sk4_family__c, familiesCumuls);
        }

        for (sk4_cumulation__c c : cumulations) {
            List<sk4_cumulation__c> relatedCumuls = familyToCumulation.get(c.sk4_family__c);

            if (relatedCumuls != null) {
                for (sk4_cumulation__c relC : relatedCumuls) {
                    if (
                        c.sk4_cumulationMonth__c == relC.sk4_cumulationMonth__c &&
                        c.sk4_cumulationYear__c == relC.sk4_cumulationYear__c
                    ) {
                        c.addError('You cannot perform two cumulations per month!');
                    }
                }
            }
        }
    }
}
