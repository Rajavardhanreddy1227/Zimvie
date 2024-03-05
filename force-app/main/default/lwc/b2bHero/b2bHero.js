import { LightningElement,wire,track } from 'lwc';
import retrieveMediaFromCMS from '@salesforce/apex/B2BHeroController.retrieveMediaFromCMS';
import splash1 from '@salesforce/resourceUrl/B2BSplash1';
import splash2 from '@salesforce/resourceUrl/B2BSplash2';
import splash3 from '@salesforce/resourceUrl/B2BSplash3';
import splash4 from '@salesforce/resourceUrl/B2BSplash4';
import splash5 from '@salesforce/resourceUrl/B2BSplash5';
import splash6 from '@salesforce/resourceUrl/B2BSplash6';

export default class HeroComponent extends LightningElement {
    image1;
    image2;
    image3;
    image4
    /*error;
    @track results=[];
    @wire(retrieveMediaFromCMS)
    wiredData({ error, data }) {
        if (data) {
            let objStr = JSON.parse(data);
            objStr.map(element=>{
                this.results = [...this.results,{title:element.title,
                                                url:element.url}]
            });  
            this.error = undefined;            
        } else if (error) {
            this.error = JSON.stringify(error);
            this.results = undefined;
        }
    }*/

    renderedCallback() {
        if(localStorage['selectedBrand'] == 'zimvie'){
            this.image1 = splash1;
            this.image2 = splash2;
            this.image3 = splash3;
            this.image4 = splash1;
        }
        else {
            this.image1 = splash4;
            this.image2 = splash5;
            this.image3 = splash6;
            this.image4 = splash4;
        }
    }
}