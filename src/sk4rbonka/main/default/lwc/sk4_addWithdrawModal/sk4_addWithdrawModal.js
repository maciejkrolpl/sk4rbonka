import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import createTransfer from '@salesforce/apex/sk4_addWithdrawController.createTransfer';
import { publish, MessageContext } from 'lightning/messageService';
import HISTORY_REFRESH_CHANNEL from '@salesforce/messageChannel/HistoryRefresh__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import TRANSFER_OBJECT from '@salesforce/schema/sk4_Transfer__c';
import TYPE_FIELD from '@salesforce/schema/sk4_Transfer__c.sk4_Type__c';

const TRANSFER_RT_STANDARD = 'Standard';
const DEFAULT_BUTTON = 'PocketMoney';

export default class Sk4_addWithdrawModal extends LightningElement {
    buttons;
    _selectedAction;
    amount;
    description;
    @api recordId;
    standardTransferRecordTypeId;
    transferTypes;

    @wire(MessageContext)
    messageContext;

    @wire(getObjectInfo, { objectApiName: TRANSFER_OBJECT })
    transferInfo({ data, error }) {
        if (data && data.recordTypeInfos) {
            const recordTypeInfo = Object.values(data.recordTypeInfos).find(info => info.name === TRANSFER_RT_STANDARD);
            this.standardTransferRecordTypeId = recordTypeInfo?.recordTypeId;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$standardTransferRecordTypeId', fieldApiName: TYPE_FIELD })
    picklistValues({ data, error }) {
        if (data) {
            this.buttons = data.values.map(picklistValue => ({
                name: picklistValue.value,
                variant: picklistValue.value === DEFAULT_BUTTON ? 'brand' : 'neutral',
                ...picklistValue
            }));
        }
    }

    set selectedAction(value) {
        this._selectedAction = value;
    }

    get selectedAction() {
        return this._selectedAction || this.buttons[0].name;
    }

    handleClick(event) {
        this.buttons = this.buttons.map(button => ({
            ...button,
            variant: button.name === event.target.dataset.action ? 'brand' : 'neutral'
        }));
        this.selectedAction = event.target.dataset.action;
    }

    handleChange(event) {
        this[event.target.dataset.field] = event.target.value;
    }

    async handleSave() {
        try {
            await createTransfer({
                type: this.selectedAction,
                amount: this.amount,
                description: this.description,
                childId: this.recordId
            });
            publish(this.messageContext, HISTORY_REFRESH_CHANNEL, {});
            this.handleClose();
        } catch (e) {
            console.error(e);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error adding transfer',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
