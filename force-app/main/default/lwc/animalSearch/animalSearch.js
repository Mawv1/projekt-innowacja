import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAnimals from '@salesforce/apex/AnimalSearchController.getAnimals';
import getShelterOptions from '@salesforce/apex/AnimalSearchController.getShelterOptions';
import getGenderOptions from '@salesforce/apex/AnimalSearchController.getGenderOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BREED_FIELD from '@salesforce/schema/Animal__c.Breed__c';

export default class AnimalSearch extends NavigationMixin(LightningElement) {
    @track shelterOptions = [{ label: 'Any', value: '' }];
    @track genderOptions = [{ label: 'Any', value: '' }];
    @track selectedShelter = '';
    @track selectedBreedId = '';
    @track selectedBreedName = '';
    @track selectedAge = '';
    @track selectedGender = '';

    @track animals = [];
    @track isLoading = false;
    @track offset = 0;
    @track hasMore = true;

    matchingInfo = {
        primaryField: { fieldPath: 'Breed__c' }
    };

    displayInfo = {
        primaryField: 'Breed__c',
    };

    connectedCallback() {
        this.resetAndFetch(); 
        window.addEventListener('scroll', this.handleScroll);
    }

    disconnectedCallback() {
        window.removeEventListener('scroll', this.handleScroll);
    }

    fetchAnimals(isLoadMore = false) {
        this.isLoading = true;

        getAnimals({
            shelter: this.selectedShelter,
            breed: this.selectedBreedName,
            age: (this.selectedAge !== '' ? parseInt(this.selectedAge, 10) : null),
            gender: this.selectedGender,
            offset: this.offset
        })
        .then(result => {
            const mapped = result.map(animal => ({
                id: animal.Id,
                name: animal.Name,
                breed: animal.Breed__c,
                age: animal.Age__c != null ? `${animal.Age__c} years old` : 'Unknown age',
                shelterName: animal.Shelter__r?.Name || 'Unknown',
                gender: animal.Sex__c,
                image: animal.Photo_URL__c || 'https://cdn-icons-png.flaticon.com/512/4823/4823463.png',
            }));

            if (isLoadMore) {
                this.animals = [...this.animals, ...mapped];
            } else {
                this.animals = mapped;
            }

            const PAGE_SIZE = 10;
            this.hasMore = (mapped.length === PAGE_SIZE);
            this.offset += PAGE_SIZE; 
            this.isLoading = false;
        })
        .catch(error => {
            console.error('Error loading animals:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading animals',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        });
    }

    resetAndFetch() {
        this.offset = 0;
        this.hasMore = true;
        this.animals = [];
        this.fetchAnimals(false);
    }

    get noResults() {
        return !this.animals.length && !this.isLoading;
    }

    handleShelterChange(event) {
        this.selectedShelter = event.detail.value;
        this.resetAndFetch();
    }

    handleBreedChange(event) {
        const selectedId = event.detail.recordId;

        if (selectedId) {
            this.selectedBreedId = selectedId;
        } else {
            this.selectedBreedName = '';
        }
        this.resetAndFetch();
    }

    @wire(getRecord, { recordId: '$selectedBreedId', fields: [BREED_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.selectedBreedName = getFieldValue(data, BREED_FIELD);
            this.resetAndFetch();
        } else if (error) {
            console.error('Błąd podczas pobierania rekordu:', error);
        }
    }

    handleAgeChange(event) {
        const value = event.detail.value;
        if (value === '') {
            this.selectedAge = '';
            this.resetAndFetch();
            return;
        }
        const numeric = parseInt(value, 10);
        if (isNaN(numeric) || numeric <= 0 || numeric > 20) {
            this.selectedAge = '';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Invalid age',
                    message: 'Age must be a number between 1 and 20.',
                    variant: 'error'
                })
            );
            this.resetAndFetch();
            return;
        }
        this.selectedAge = numeric.toString();
        this.resetAndFetch();
    }

    handleGenderChange(event) {
        this.selectedGender = event.detail.value;
        this.resetAndFetch();
    }


    handleScroll = () => {
        if (this.isLoading || !this.hasMore) {
            return;
        }
        const scrollHeight = document.documentElement.scrollHeight;
        const scrollTop = document.documentElement.scrollTop;
        const clientHeight = document.documentElement.clientHeight;

        if (scrollTop + clientHeight >= scrollHeight - 50) {
            this.fetchAnimals(true);
        }
    }


    @wire(getShelterOptions)
    wiredShelters({ error, data }) {
        if (data) {
            this.shelterOptions = [
                { label: 'Any', value: '' },
                ...data.map(shelterName => ({ label: shelterName, value: shelterName }))
            ];
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getGenderOptions)
    wiredGenders({ error, data }) {
        if (data) {
            this.genderOptions = [
                { label: 'Any', value: '' },
                ...data.map(genderValue => ({ label: genderValue, value: genderValue }))
            ];
        } else if (error) {
            console.error(error);
        }
    }

    navigateToAnimalDetail(event) {
        const animalId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: animalId,
                objectApiName: 'Animal__c',
                actionName: 'view'
            }
        });
    }

    handleImageError(event) {
        event.target.onerror = null;
        event.target.src = 'https://cdn-icons-png.flaticon.com/512/4823/4823463.png';
    }
}
