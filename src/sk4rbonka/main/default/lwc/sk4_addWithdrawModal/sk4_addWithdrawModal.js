import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import createTransfer from '@salesforce/apex/sk4_addWithdrawController.createTransfer';

const BUTTONS = [
    {
        label: 'PocketMoney',
        name: 'pocketMoney',
        variant: 'brand'
    },
    {
        label: 'Withdraw',
        name: 'withdraw',
        variant: 'neutral'
    }
];

export default class Sk4_addWithdrawModal extends LightningElement {
    buttons = BUTTONS;
    _selectedAction;
    amount;
    description;
    @api recordId;

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
            this.handleClose();
        } catch (e) {
            console.error(e);
        }
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
