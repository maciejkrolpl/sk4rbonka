import { LightningElement, wire, api, track } from 'lwc';
import getTransfersByChildren from '@salesforce/apex/sk4_TransferController.getTransfersByChildren';
import getMinusTypes from '@salesforce/apex/sk4_TransferController.getMinusTypes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sk4_history extends LightningElement {
    columns = [
        { label: 'Date', fieldName: 'dt', type: 'date-local' },
        { label: 'Type', fieldName: 'type' },
        { label: 'Description', fieldName: 'description', editable: true },
        {
            label: 'Amount',
            fieldName: 'amount',
            type: 'currency',
            cellAttributes: { class: { fieldName: 'color' } },
            editable: true,
        },
        {
            label: 'Balance',
            fieldName: 'total',
            type: 'currency',
        },
    ];

    @api recordId;
    @track transfers;
    rowOffset = 0;

    displayErrorToast(message) {
        const toast = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message,
        });
        this.dispatchEvent(toast);
    }

    async connectedCallback() {
        const getMinusTypesPromise = getMinusTypes();
        const getTransfersPromise = getTransfersByChildren({
            childId: this.recordId,
        });

        try {
            const [minusTypes, transfers] = await Promise.all([
                getMinusTypesPromise,
                getTransfersPromise,
            ]);
            this.transfers = transfers.map((item) => ({
                ...item,
                amount: minusTypes.includes(item.type)
                    ? item.amount * -1
                    : item.amount,
                color: minusTypes.includes(item.type)
                    ? 'slds-text-color_error'
                    : '',
            }));
        } catch (e) {
            console.error(e);
        }
    }
}
