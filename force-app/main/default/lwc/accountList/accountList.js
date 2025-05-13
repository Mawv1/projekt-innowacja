import { LightningElement, wire } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Account.LastName';
import EMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

const COLUMNS = [
    { label: 'First Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' },
    { label: 'Last Name', fieldName: LASTNAME_FIELD.fieldApiName, type: 'text' },
    { label: 'Email', fieldName: EMAIL_FIELD.fieldApiName, type: 'email' },
    { label: 'Phone', fieldName: PHONE_FIELD.fieldApiName, type: 'phone' }
];

export default class AccountList extends LightningElement {
    columns = COLUMNS;
    @wire(getAccounts)
    accounts;
}
