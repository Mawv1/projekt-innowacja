import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAnimals from '@salesforce/apex/AnimalSearchController.getAnimals';
import getShelterOptions from '@salesforce/apex/AnimalSearchController.getShelterOptions';
import getBreedOptions from '@salesforce/apex/AnimalSearchController.getBreedOptions';
import getAgeOptions from '@salesforce/apex/AnimalSearchController.getAgeOptions';
import getGenderOptions from '@salesforce/apex/AnimalSearchController.getGenderOptions';

export default class AnimalSearch extends NavigationMixin(LightningElement) {
    @track shelterOptions = [{ label: 'Any', value: '' }];
    @track breedOptions = [{ label: 'Any', value: '' }];
    @track ageOptions = [{ label: 'Any', value: '' }];
    @track genderOptions = [{ label: 'Any', value: '' }];
    @track selectedShelter = '';
    @track selectedBreed = '';
    @track selectedAge = '';
    @track selectedGender = '';
    @track animals = [];

    connectedCallback() {
        this.fetchAnimals();
    }

    fetchAnimals() {
        getAnimals({
            shelter: this.selectedShelter,
            breed: this.selectedBreed,
            age: this.selectedAge,
            gender: this.selectedGender
        })
        .then(result => {
            this.animals = result.map(animal => ({
                id: animal.Id,
                name: animal.Name,
                breed: animal.Breed__c,
                age: animal.Age__c,
                shelterName: animal.Shelter__r ? animal.Shelter__r.Name : 'Unknown',
                gender: animal.Sex__c,
                image: animal.Photo_URL__c ? animal.Photo_URL__c : 'https://cdn-icons-png.flaticon.com/512/4823/4823463.png',
            }));
        })
        .catch(error => {
            console.error('Error loading animals:', error);
        });
    }

    get filteredAnimals() {
        return this.animals;
    }

    handleShelterChange(event) {
        this.selectedShelter = event.detail.value;
        this.fetchAnimals();
    }

    handleBreedChange(event) {
        this.selectedBreed = event.detail.value;
        this.fetchAnimals();
    }

    handleAgeChange(event) {
        this.selectedAge = parseInt(event.detail.value, 10);
        if (isNaN(this.selectedAge)) {
            this.selectedAge = '';
        }
        this.fetchAnimals();
    }

    handleGenderChange(event) {
        this.selectedGender = event.detail.value;
        this.fetchAnimals();
    }

    @wire(getShelterOptions)
    wiredShelters({ error, data }) {
        if (data) {
            this.shelterOptions = [{ label: 'Any', value: '' }, ...data.map(shelter => ({ label: shelter, value: shelter }))];
        }
    }

    @wire(getBreedOptions)
    wiredBreeds({ error, data }) {
        if (data) {
            this.breedOptions = [{ label: 'Any', value: '' }, ...data.map(breed => ({ label: breed, value: breed }))];
        }
    }

    @wire(getAgeOptions)
    wiredAges({ error, data }) {
        if (data) {
            this.ageOptions = [{ label: 'Any', value: '' }, ...data.map(age => ({ label: age, value: age }))];
        }
    }

    @wire(getGenderOptions)
    wiredGenders({ error, data }) {
        if (data) {
            this.genderOptions = [{ label: 'Any', value: '' }, ...data.map(gender => ({ label: gender, value: gender }))];
            console.log(this.genderOptions);
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
}