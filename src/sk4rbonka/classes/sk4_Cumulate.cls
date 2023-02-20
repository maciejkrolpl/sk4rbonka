public class sk4_Cumulate {
    private static final String CUMULATION_TRANSFER = 'Cumulation';
    public class FlowInput {
        @InvocableVariable(label = 'List of children'required = true)
        public List<sk4_child__c> children;
        @InvocableVariable(label = 'Percent'required = true)
        public Decimal percent;
    }

    @InvocableMethod
    public static void doCumulate(List<FlowInput> inputs) {
        List<sk4_transfer__c> transfers = new List<sk4_transfer__c>();
        Id cumulationId = createCumulation();
        for (sk4_child__c child : inputs[0].children) {
            Decimal transferAmount = child.sk4_balance__c * inputs[0].percent / 100;
            transfers.add(sk4_CreateTransferRecords.createTransfer(CUMULATION_TRANSFER, child.Id, transferAmount, cumulationId));
        }

        sk4_CreateTransferRecords.insertRecords(transfers);
    }


    private static Id createCumulation() {
        sk4_cumulation__c cumulation = new sk4_cumulation__c();
        insert cumulation;
        return cumulation.Id;
    }
}