import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getChildren from '@salesforce/apex/sk4_TransferController.getChildren';

export default class Sk4_wholesale extends NavigationMixin(LightningElement) {
    @track children;
    @track error;

    connectedCallback() {
        this.getAllChildren();
    }

    async getAllChildren() {
        this.children = await getChildren();
    }

    handleChildNavigate(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.childId,
                objectApiName: 'sk4_child__c',
                actionName: 'view'
            }
        });
    }
}
