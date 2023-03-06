public with sharing class sk4_CreateTransferRecords {

    public class FlowInput {
        @InvocableVariable(label='Child' required=true)
        public sk4_child__c child;
        @InvocableVariable(label='Parent' required=true)
        public sk4_parent__c parent;
        @InvocableVariable(label='PocketMoney Amount')
        public Decimal pocketMoneyAmount;
        @InvocableVariable(label='Savings Amount')
        public Decimal savingsAmount;
        @InvocableVariable(label='Withdraw Amount')
        public Decimal withdrawAmount;
        @InvocableVariable(label='Deduction Amount')
        public Decimal deductionAmount;
        @InvocableVariable(label='Other Amount')
        public Decimal otherAmount;
        @InvocableVariable(label='Description')
        public String description;
    }

    public class TransferException extends Exception {}

    public class Parameters {
        public String type;
        public Decimal transferAmount;
        public Id childId;
        public Id cumulationId;
        public Id parentId;
        public String description;

        public Parameters(FlowInput input) {
            this.childId = input.child.Id;
            this.parentId = input.parent.Id;
            if (!String.isBlank(input.description)) {
                this.description = input.description;
            }
        }

        public Parameters(){}
    }

    @InvocableMethod
    public static void createRecords(List<FlowInput> inputs) {
        List<sk4_Transfer__c> transfers = new List<sk4_Transfer__c>();

        for (FlowInput input: inputs) {

            if (input.pocketMoneyAmount != null && input.savingsAmount != null) {
                if (input.pocketMoneyAmount < input.savingsAmount) {
                    throw new TransferException('You cannot save more money that is given.');
                }
            }
            if(input.otherAmount != NULL && String.isBlank(input.description)) {
                throw new TransferException('Description must be set in Other Transfer.');
            }

            if (input.pocketMoneyAmount != NULL && input.pocketMoneyAmount > 0) {
                transfers.add(createPocketMoneyTransfer(input));
            }
            if (input.savingsAmount != NULL && input.savingsAmount > 0) {
                transfers.add(createSavingsTransfer(input));
            }
            if(input.withdrawAmount != NULL && input.withdrawAmount > 0) {
                transfers.add(createWithdrawTransfer(input));
            }
            if (input.otherAmount != NULL && input.otherAmount > 0) {
                transfers.add(createOtherTransfer(input));
            }
            if (input.deductionAmount != NULL && input.deductionAmount > 0) {
                transfers.add(createDeductionTransfer(input));
            }
        }

        insertRecords(transfers);
        
    }

    public static void insertRecords(List<sk4_transfer__c> transfers) {
        List<String> errors = new List<String>(); 

        List<Database.SaveResult> srList = Database.insert(transfers, false);
        
        for (Integer i = 0; i < srList.size(); i++) {
            Database.SaveResult sr = srList[i];
            String name = transfers[i].sk4_child__r.Name;
            if (sr.isSuccess()) {
                System.debug('# Successfully inserted transfer for ' + name + '.');
            }
            else {        
                for(Database.Error err : sr.getErrors()) {
                    System.debug('* ***************************************************************');                    
                    System.debug('* The following error has occurred for ' + name + '.');                    
                    System.debug('* ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('* Fields that affected this error: ' + err.getFields());
                    errors.add(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        
        if (errors.size() > 0) {
            throw new TransferException(String.join(errors, '\r\n'));
        }
    } 

    private static sk4_Transfer__c createOtherTransfer(FlowInput input) {
        Parameters p = new Parameters(input);
        p.transferAmount = input.otherAmount;
        p.type = sk4_Const.TRANSFER_TYPE_OTHER;
        return createTransfer(p);
    }

    private static sk4_Transfer__c createPocketMoneyTransfer(FlowInput input) {
        Parameters p = new Parameters(input);
        p.transferAmount = input.pocketMoneyAmount;
        p.type = sk4_Const.TRANSFER_TYPE_POCKETMONEY;
        return createTransfer(p);
    }
    
    private static sk4_Transfer__c createSavingsTransfer(FlowInput input) {
        Parameters p = new Parameters(input);
        p.transferAmount = input.savingsAmount;
        p.type = sk4_Const.TRANSFER_TYPE_SAVINGS;
        return createTransfer(p);
    }
    
    private static sk4_Transfer__c createDeductionTransfer(FlowInput input) {
        Parameters p = new Parameters(input);
        p.transferAmount = input.deductionAmount;
        p.type = sk4_Const.TRANSFER_TYPE_DEDUCTION;
        return createTransfer(p);
    }

    private static sk4_Transfer__c createWithdrawTransfer(FlowInput input) {
        Parameters p = new Parameters(input);
        p.transferAmount = input.withdrawAmount;
        p.type = sk4_Const.TRANSFER_TYPE_WITHDRAW;
        return createTransfer(p);
    }

    public static sk4_transfer__c createTransfer(Parameters p) {
        sk4_transfer__c transfer = new sk4_transfer__c();
        transfer.sk4_type__c = p.type;
        transfer.RecordTypeId = sk4_Const.TYPE_TO_RT_ID.get(p.type);
        transfer.sk4_child__c = p.childId;
        transfer.sk4_parent__c = p.parentId;
        transfer.sk4_transferAmount__c = p.transferAmount;
        transfer.sk4_date__c = Date.today();
        transfer.Name = getName(p.type);
        transfer.sk4_cumulation__c = p.cumulationId;
        transfer.sk4_description__c = p.description;
        return transfer;
    }

    private static String getName(String type) {
        return type + '-' + String.valueOf(Date.today());
    }

}