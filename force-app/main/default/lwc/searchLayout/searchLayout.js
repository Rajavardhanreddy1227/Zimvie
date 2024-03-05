import { LightningElement, api } from 'lwc';
export default class SearchLayout extends LightningElement {

    @api
    displayData;

    @api
    isFeatured;

    @api
    config;


    get layoutContainerClass() {
        return this.config.resultsLayout === 'grid'
            ? 'layout-grid'
            : 'layout-list';
    }

    slideIndex = 0;
    isMobile = false;

    renderedCallback() {
        if(!this.isFeatured)
        return;
        this.isMobile = this.isMobileDevice();
        this.showSlides();
    }

    isMobileDevice() {
        const userAgent = navigator.userAgent;
        return /Mobi|Android/i.test(userAgent);
    }

    previousSlides() {
        this.slideIndex -= this.isMobile ? 1 : 3;
        this.showSlides();
    }

    nextSlides() {
        this.slideIndex += this.isMobile ? 1 : 3;
        this.showSlides();
    }

    getDisplaySlideClass(event) {
        const index = parseInt(event.target.dataset.index);
        const slideIndex = this.slideIndex;
        const displayIndex = index + 1;

        const classList = ['mySlides', 'fade'];

        if (!(displayIndex >= slideIndex && displayIndex <= slideIndex + (this.isMobile ? 0 : 3))) {
            classList.push('hidden');
        }

        return classList.join(' ');
    }

    showSlides() {
        const slides = this.template.querySelectorAll('.mySlides');
        slides.forEach(slide => slide.style.display = "none");
        console.log('slides.length=='+slides.length);
        console.log('this.slideIndex='+this.slideIndex);
        console.log('this.displayData.length='+this.displayData.length);
        console.log('Math.max(0, this.displayData.length - (this.isMobile ? 1 : 3))='+Math.max(0, this.displayData.length - (this.isMobile ? 1 : 3)));
        if (this.slideIndex < 0) {
            this.slideIndex = 0;
        } else if (this.slideIndex >= this.displayData.length) {
            this.slideIndex = Math.max(0, this.displayData.length - (this.isMobile ? 1 : 3));
        }
        console.log('this.slideIndex + (this.isMobile ? 1 : 3)='+parseInt(this.slideIndex + (this.isMobile ? 1 : 3)));
        for (let i = this.slideIndex; i < parseInt(this.slideIndex + (this.isMobile ? 1 : 3)) && i < slides.length; i++) {
            console.log('i='+i);
            slides[i].style.display = "block";
        }
    }

}