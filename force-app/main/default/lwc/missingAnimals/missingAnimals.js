import { LightningElement, track } from 'lwc';
import getMissingAnimals from '@salesforce/apex/MissingAnimalService.getMissingAnimals';
import getMissingAnimalDetails from '@salesforce/apex/MissingAnimalService.getMissingAnimalDetails';
import createMissingAnimal from '@salesforce/apex/MissingAnimalService.createMissingAnimal';
import updateAnimalFoundStatus from '@salesforce/apex/MissingAnimalService.updateAnimalFoundStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MissingAnimals extends LightningElement {
    @track dayDelta = 100;
    @track animals = [];
    @track isLoading = false;

    get sizeOptions() {
    return [
        { label: 'Small',  value: 'Small' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Big',    value: 'Big' }
    ];
}

    // Formularz - zmienne do trzymania wartości
    newAnimalName = '';
    newReportAddress = '';
    newDisappearanceDate = '';
    newReportDescription = '';
    newAnimalBreed = '';
    newAnimalAge;
    newAnimalUniqueFeatures = '';
    newAnimalSize = '';
    newAnimalImageUrl = '';

    handleDeltaChange(event) {
        this.dayDelta = parseInt(event.target.value, 10) || 0;
    }

    async fetchAnimals() {
        try {
            this.isLoading = true;
            const list = await getMissingAnimals({ dayDelta: this.dayDelta });
            const detailedPromises = list.map(item => {
                // console.log('Processing item ID:', item);
                if (!item.id) {
                    console.warn('Skipping detail fetch: missing id for item', item);
                    return Promise.resolve({
                        id: null,
                        name: item.name || 'Unnamed',
                        missingDate: item.missingDate,
                        imageUrl: null,
                        found: false
                    });
                }
                
                return getMissingAnimalDetails({ id: item.id })
                    .then(detail => ({
                        id: detail.id,
                        name: detail.name,
                        missingDate: detail.missingDate,
                        imageUrl: detail.imageUrl,
                        found: detail.found || false
                    }))
                    .catch(err => {
                        console.error(`Error fetching details for ID ${item.id}:`, err);
                        return {
                            id: item.id,
                            name: item.name,
                            missingDate: item.missingDate,
                            imageUrl: null,
                            found: false
                        };
                    });
            });
            this.animals = await Promise.all(detailedPromises);
            this.animals.sort((a, b) => {
                return new Date(b.missingDate) - new Date(a.missingDate);
            });
        } catch (error) {
            console.error('Error fetching animals list:', error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleAddAnimal() {
        this.isLoading = true;
        if (!this.newAnimalName || !this.newReportAddress || 
            !this.newDisappearanceDate || !this.newReportDescription) {
            console.error('Missing required fields');
            return;
        }
        
        const formattedDate = new Date(this.newDisappearanceDate).toISOString().split('T')[0];
        
        const today = new Date();
        const disappearanceDate = new Date(formattedDate);
        if (disappearanceDate > today) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Disappearance date cannot be in the future.',
                    variant: 'error'
                })
            );
            this.isLoading = false;
            return;
        }
        
        const wrapper ={
                report:{
                    "disappearancePlaceLongitude": null,
                    "disappearancePlaceLatitude": null,
                    "disappearanceDate": formattedDate,
                    "description": this.newReportDescription,
                    "address": this.newReportAddress
                },
                animal:{
                    "uniqueFeatures": this.newAnimalUniqueFeatures,
                    "size": this.newAnimalSize,
                    "name": this.newAnimalName,
                    "imageUrl": this.newAnimalImageUrl,
                    "breed": this.newAnimalBreed,
                    "age": this.newAnimalAge ? parseInt(this.newAnimalAge, 10) : null
                }
            };
        
        console.warn('Adding new animal with data:', wrapper);
        
        try {
            await createMissingAnimal({ wrapper });
            this.newAnimalName = '';
            this.newReportAddress = '';
            this.newDisappearanceDate = '';
            this.newReportDescription = '';
            this.newAnimalBreed = '';
            this.newAnimalAge = null;
            this.newAnimalUniqueFeatures = '';
            this.newAnimalSize = '';
            this.newAnimalImageUrl = '';

            this.fetchAnimals();
        } catch (error) {
            console.error('Error adding missing animal:', error);
        } finally {
        this.isLoading = false;
    }
    }

    async handleFoundChange(event) {
        const animalId = event.target.dataset.id;
        const found = event.target.checked;
        console.log(`Updating found status for animal ID ${animalId} to ${found}`);
        try {
            await updateAnimalFoundStatus({ animalId, found });

            const animal = this.animals.find(a => a.id === animalId);
            if (animal) animal.found = found;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Animal status updated',
                    message: 'Animal found status has been updated successfully.',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to update animal status.',
                    variant: 'error'
                })
            );
            console.error('Error updating found status:', error);
        }
        
    }

    handleNewAnimalNameChange(event) {
        this.newAnimalName = event.target.value;
    }

    handleNewReportAddressChange(event) {
        this.newReportAddress = event.target.value;
    }

    handleNewDisappearanceDateChange(event) {
        this.newDisappearanceDate = event.target.value;
    }

    handleNewReportDescriptionChange(event) {
        this.newReportDescription = event.target.value;
    }

    handleNewAnimalBreedChange(event) {
        this.newAnimalBreed = event.target.value;
    }

    handleNewAnimalAgeChange(event) {
        this.newAnimalAge = event.target.value;
    }

    handleNewAnimalUniqueFeaturesChange(event) {
        this.newAnimalUniqueFeatures = event.target.value;
    }

    handleNewAnimalSizeChange(event) {
        this.newAnimalSize = event.target.value;
    }

    handleNewAnimalImageUrlChange(event) {
        this.newAnimalImageUrl = event.target.value;
    }

    handleImageError(event) {
        event.target.onerror = null;
        event.target.src = 'https://cdn-icons-png.flaticon.com/512/4823/4823463.png';
    }
}