import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Account.LastName';
import EMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';

export default class AccountCreator extends LightningElement {
    objectApiName = ACCOUNT_OBJECT;
    fields = [NAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD, PHONE_FIELD];

    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Account was created successfully!',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }
}
