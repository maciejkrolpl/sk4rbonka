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

    displayErrorToast(message) {
        const toast = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message,
        });
        this.dispatchEvent(toast);
    }

    connectedCallback() {
        const getMinusTypesPromise = getMinusTypes();
        const getTransfersPromise = getTransfersByChildren({
            childId: this.recordId,
        });
        Promise.all([getMinusTypesPromise, getTransfersPromise]).then(
            ([minusTypes, transfers]) => {
                this.transfers = transfers.map((item) => ({
                    ...item,
                    color: minusTypes.includes(item.type)
                        ? 'slds-text-color_error'
                        : '',
                }));
            }
        );
    }
}
