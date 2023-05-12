import { LightningElement, wire, api, track } from "lwc"
import getTransfersByChildren from "@salesforce/apex/sk4_TransferController.getTransfersByChildren"
import getMinusTypes from "@salesforce/apex/sk4_TransferController.getMinusTypes"
import { ShowToastEvent } from "lightning/platformShowToastEvent"

export default class Sk4_history extends LightningElement {
    columns = [
        { label: "Date", fieldName: "dt", type: "date-local" },
        { label: "Type", fieldName: "type" },
        { label: "Description", fieldName: "description" },
        {
            label: "Amount",
            fieldName: "amount",
            type: "currency",
            cellAttributes: { class: { fieldName: "color" } },
        },
        { label: "Balance", fieldName: "total", type: "currency" },
    ]

    @api recordId
    @track transfers
    @track minusTypes

    displayErrorToast(message) {
        const toast = new ShowToastEvent({
            title: "Error",
            variant: "error",
            message,
        })
        this.dispatchEvent(toast)
    }

    @wire(getMinusTypes) wireMinusTypes({ error, data }) {
        if (data) {
            this.minusTypes = data
        } else if (error) {
            this.minusTypes = undefined
            this.displayErrorToast(error.body.message)
        }
    }

    @wire(getTransfersByChildren, { childId: "$recordId" }) wireTransfers({
        error,
        data,
    }) {
        if (data) {
            this.transfers = data?.map((item) => ({
                ...item,
                color: this.minusTypes.includes(item.type)
                    ? "slds-text-color_error"
                    : "",
            }))
        } else if (error) {
            this.transfers = undefined
            this.displayErrorToast(error.body.message)
        }
    }
}
