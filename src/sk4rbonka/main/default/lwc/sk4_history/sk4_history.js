import { LightningElement, wire, api, track } from 'lwc';
import getTransfersByChildren from '@salesforce/apex/sk4_TransferController.getTransfersByChildren';
import { subscribe, MessageContext } from 'lightning/messageService';
import HISTORY_REFRESH_CHANNEL from '@salesforce/messageChannel/HistoryRefresh__c';
export default class Sk4_history extends LightningElement {
    columns = [
        {
            label: 'Date',
            fieldName: 'dt',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        },
        { label: 'Type', fieldName: 'type' },
        { label: 'Description', fieldName: 'description' },
        {
            label: 'Amount',
            fieldName: 'amount',
            type: 'currency',
            cellAttributes: { class: { fieldName: 'color' } }
        },
        {
            label: 'Balance',
            fieldName: 'total',
            type: 'currency'
        }
    ];

    @api recordId;
    @track transfers;
    rowOffset = 0;

    @wire(MessageContext)
    messageContext;

    subscription;

    subscribeToMessageChannel() {
        this.subscription = subscribe(this.messageContext, HISTORY_REFRESH_CHANNEL, () => this.getRecords());
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.getRecords();
    }

    async getRecords() {
        try {
            const transfers = await getTransfersByChildren({
                childId: this.recordId
            });
            console.log('🚀 ~ Sk4_history ~ connectedCallback ~ transfers:', transfers);
            this.transfers = transfers
                .map(item => ({
                    ...item,
                    color: item.amount < 0 ? 'slds-text-color_error' : ''
                }))
                .reverse();
        } catch (e) {
            console.error(e);
        }
    }
}
