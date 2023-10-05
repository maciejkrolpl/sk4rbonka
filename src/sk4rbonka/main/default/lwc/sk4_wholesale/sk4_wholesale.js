import { LightningElement, track } from 'lwc';
import getAllChildren from '@salesforce/apex/sk4_Wholesale.getAllChildren';
import saveNewTransfers from '@salesforce/apex/sk4_Wholesale.saveNewTransfers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sk4_wholesale extends LightningElement {
    @track children;
    @track error;

    get isContinueDisabled() {
        const inputs = [...this.template.querySelectorAll('.input-give')];
        return !(
            inputs.every((input) => input.checkValidity()) &&
            this.children.some((child) => child.give > 0)
        );
    }

    connectedCallback() {
        this.getAllChildren();
    }

    async getAllChildren() {
        this.children = undefined;
        this.error = undefined;

        try {
            const children = await getAllChildren();
            this.children = children.map((child) => ({
                ...child,
                give: 0,
            }));
        } catch (error) {
            this.error = error;
        }
    }

    handleChange(event) {
        const amount = event.target.value;
        const name = event.target.dataset.name;
        const children = this.children.map((child) => {
            if (child.fullName === name) {
                child.give = +amount;
            }
            return child;
        });
        this.children = children;
    }

    popUpEvent(variant, message) {
        const toast = new ShowToastEvent({
            title: variant.toUpperCase(),
            variant,
            message,
        });
        this.dispatchEvent(toast);
    }

    clearInputs() {
        this.children.forEach((child) => {
            child.give = 0;
        });
        this.template.querySelectorAll('.input-give').forEach((input) => {
            input.setCustomValidity('');
            input.reportValidity();
        });
    }

    async handleSave() {

        try {
            await saveNewTransfers({ children });
            this.popUpEvent('success', 'Operation completed successfully.');
            this.clearInputs();
            this.getAllChildren();
        } catch (e) {
            this.popUpEvent('error', error.body.message);
            console.error(error);
        }
    }

    defaultAmount() {
        this.children.forEach((child) => {
            if (child.defaultAmount) {
                child.give = +child.defaultAmount;
            }
        });
    }
}