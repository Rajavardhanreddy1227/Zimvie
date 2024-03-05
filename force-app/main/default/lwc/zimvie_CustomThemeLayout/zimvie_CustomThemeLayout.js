import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import zimviestyle from '@salesforce/resourceUrl/zimviestyle';
/**
 * @slot brandbar
 * @slot searchbar
 * @slot countrybar
 * @slot logout
 * @slot sitelogo
 * @slot navBar
 * @slot icon1
 * @slot icon2
 * @slot icon3
 * @slot navlinks
 * @slot footer
 */
export default class CustomLayout extends LightningElement {
    renderedCallback() {
        Promise.all([
            loadStyle( this, zimviestyle + '/zimviecustomfont.css' )
            ]).then(() => {
                console.log( 'Files loaded' );
            })
            .catch(error => {
                console.log( error.body.message );
        });
        window.addEventListener("scroll", (evt) => {
                //if (message !== undefined && message.data === 'successGCP' && message.origin === window.location.origin) {
                    //this.captchaDone = true; // not able to access this.captchaDone getting undefined while this is declared.
                    var header = this.template.querySelector('.header');

                    var sticky = header.offsetTop;

                    if (window.pageYOffset > sticky) {
                        header.classList.add("sticky");
                    } else {
                        header.classList.remove("sticky");
                    }
               // }
            }
        );
    }

    /*handlescroll(){
        console.log('on scroll called');
        var header = this.template.querySelector('.header');

        var sticky = header.offsetTop;

        if (window.pageYOffset > sticky) {
            header.classList.add("sticky");
        } else {
            header.classList.remove("sticky");
        }
    }*/
    //scrollPosition;
    //handleScroll(event) {
    //    this.scrollPosition = event.target.scrollTop;
    //    console.log('this.scrollPosition='+this.scrollPosition);
    //}

    //connectedCallback() {
    //    window.addEventListener('scroll', this.handleScroll);
    //}

    //disconnectedCallback() {
   //     window.removeEventListener('scroll', this.handleScroll);
    //}

    handleScroll(event) {
        console.log('on scroll called');
        console.log(this.template);
        var header = this.template.querySelector('.header');

        var sticky = header.offsetTop;

        if (window.pageYOffset > sticky) {
            header.classList.add("sticky");
        } else {
            header.classList.remove("sticky");
        }
    }

    makeContentFaded(event){
        //console.log('mouse hovered on navigation');
        let ele = this.template.querySelector('.content');
        ele.classList.add('opacityclass');// = "0.2";
    }
    makecontentvisible(event){
        let ele = this.template.querySelector('.content');
        ele.classList.remove('opacityclass');
    }
}