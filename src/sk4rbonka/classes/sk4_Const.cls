public with sharing class sk4_Const {
    
    public final static String TRANSFER_TYPE_POCKETMONEY = 'PocketMoney';
    public final static String TRANSFER_TYPE_SAVINGS = 'Savings';
    public final static String TRANSFER_TYPE_WITHDRAW = 'Withdraw';
    public final static String TRANSFER_TYPE_CUMULATION = 'Cumulation';
    public final static String TRANSFER_TYPE_OTHER = 'Other';

    public final static String TRANSFER_RECORDTYPE_CUMULATION = 'Cumulation';
    public final static String TRANSFER_RECORDTYPE_STANDARD = 'Standard';

    private static final Map<String,Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.sk4_Transfer__c.getRecordTypeInfosByDeveloperName();
    private static final ID STANDARD_RT_ID = recordTypes.get(TRANSFER_RECORDTYPE_STANDARD).getRecordTypeId();
    private static final ID CUMULATION_RT_ID = recordTypes.get(TRANSFER_RECORDTYPE_CUMULATION).getRecordTypeId();
    
    public static final Map<String,String> TYPE_TO_RT_ID = new Map<String, String> {
        TRANSFER_TYPE_SAVINGS => STANDARD_RT_ID,
        TRANSFER_TYPE_POCKETMONEY => STANDARD_RT_ID,
        TRANSFER_TYPE_WITHDRAW => STANDARD_RT_ID,
        TRANSFER_TYPE_OTHER => STANDARD_RT_ID,
        TRANSFER_TYPE_CUMULATION => CUMULATION_RT_ID
    };
}