import { LightningElement, track } from 'lwc';
import getAllChildren from '@salesforce/apex/sk4_Wholesale.getAllChildren';
import saveNewTransfers from '@salesforce/apex/sk4_Wholesale.saveNewTransfers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sk4_wholesale extends LightningElement {
    @track children;
    @track error;

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
                save: 0,
            }));
        } catch (error) {
            this.error = error;
        }
    }

    handleChange(event) {
        const amount = event.target.value;
        const input = event.target.dataset.input;
        const name = event.target.dataset.name;
        const children = this.children.map((child) => {
            if (child.fullName === name) {
                child[input] = +amount;
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
            child.save = 0;
            child.give = 0;
        });
        this.template.querySelectorAll('.input-save').forEach((input) => {
            input.setCustomValidity('');
            input.reportValidity();
        });
    }

    async handleSave() {
        console.log(JSON.parse(JSON.stringify(this.children)));
        if (!this.checkValidity()) {
            return;
        }

        const children = this.children.filter((child) => child.give > 0);

        if (!children.length) {
            return;
        }

        try {
            saveNewTransfers({ children });
            this.popUpEvent('success', 'Operation completed successfully.');
            this.clearInputs();
            this.getAllChildren();
        } catch (e) {
            this.popUpEvent('error', error.body.message);
            console.error(error);
        }
    }

    checkValidity() {
        let isValid = true;
        this.children.forEach((child) => {
            const input = this.template.querySelector(
                `.${child.id} .input-save`
            );
            if (child.save > child.give) {
                input.setCustomValidity(' ');
                this.popUpEvent('error', 'Cannot save more than is paid');
                isValid = false;
            } else {
                input.setCustomValidity('');
            }
            input.reportValidity();
        });
        return isValid;
    }

    defaultAmount() {
        this.children.forEach((child) => {
            if (child.defaultAmount) {
                child.give = +child.defaultAmount;
            }
        });
    }
}
