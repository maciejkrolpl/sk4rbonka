import { LightningElement, wire, api } from 'lwc';
import getTransfersByChildren from '@salesforce/apex/sk4_TransferController.getTransfersByChildren';
import getMinusTypes from '@salesforce/apex/sk4_TransferController.getMinusTypes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sk4_history extends LightningElement {
  columns = [
    { label: 'Date', fieldName: 'dt', type: 'date-local' },
    { label: 'Type', fieldName: 'type' },
    { label: 'Description', fieldName: 'description' },
    { label: 'Amount', fieldName: 'amount', type: 'currency', cellAttributes: { class: { fieldName: 'color' } } },
    { label: 'Balance', fieldName: 'total', type: 'currency' },
  ];

  @api recordId;
  @wire(getMinusTypes) minusTypes;
  @wire(getTransfersByChildren, { childId: '$recordId' }) wireResult;
  get transfers() {
      if (!this.minusTypes) {
      return null;
    }
    if (this.wireResult.error) {
      const toast = new ShowToastEvent({
        title: 'Error',
        variant: 'error',
        message: this.wireResult.error.body.message
      });
      this.dispatchEvent(toast);
      return null;
    }
    
    return this.wireResult.data?.map(item => ({
      ...item,
      color: (this.minusTypes.data.includes(item.type)) ? 'slds-text-color_error' : ''
    }));
  }
}