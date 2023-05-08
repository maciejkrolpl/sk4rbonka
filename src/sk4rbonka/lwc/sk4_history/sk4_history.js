import { LightningElement, track, api } from 'lwc';
import getTransfersByChildren from '@salesforce/apex/sk4_TransferController.getTransfersByChildren';

export default class Sk4_history extends LightningElement {

  @api recordId;
  @track transfers;

  async connectedCallback() {
    const transfers = await getTransfersByChildren({childrenId: this.recordId});
    console.log("🚀 ~ connectedCallback ~ transfers:", JSON.parse(JSON.stringify(transfers)))
    this.transfers = transfers;
    this.countBalances();
  }

  countBalances() {

    // const transfers = this.transfers.map(transfer => {
    //   const balanceAf
    // })
  }
}