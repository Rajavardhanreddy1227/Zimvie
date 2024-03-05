import { LightningElement, api, track, wire } from 'lwc';
import { ProductRecommendationsAdapter, ANCHOR_TYPES } from 'commerce/recommendationsApi';
import { navigate, NavigationContext } from 'lightning/navigation';
import { trackClickReco, trackViewReco } from 'commerce/activitiesApi';
export default class B2BEinsteinRecommendations extends LightningElement {

    @api products = [];
    @api productId;
    recommenderName = 'similar-products';
    anchorType = ANCHOR_TYPES.PRODUCT;

    get anchorValue() {
        return [this.productId];
    };

    @wire(ProductRecommendationsAdapter, {
        recommenderName: '$recommenderName',
        anchorType: '$anchorType',
        anchorValue: '$anchorValue',
    })
    async loadRecommendation(response) {
        console.log('recommendations api :: '+JSON.stringify(response));
        let { data, error } = response;

        if (data && data.recoUUID && data.products && data.products.length > 0) {
            this.products = data.products;
            this.recoUUID = data.recoUUID;
        if (this.canDisplayRecommendations) {
            this.sendViewReco();
        }
        } else if (error) {
            // unable to load recommendation, handle accordingly
            this.products = { data: [] };
            console.error('Unable to load product recommendations');
        }
    }
    get canDisplayRecommendations() {
        return this.products.length > 0;
    }
    // NavigationContext allows us to click a link to get to new Product page
    @wire(NavigationContext)
    navContext;
    handleClickProduct(event) {
        const pid = event.currentTarget.getAttribute('pid');
        const product = this.products.filter(p => p.id === pid)[0];
        trackClickReco(this.recommenderName, this.recoUUID, {
            id: product.id,
            sku: product.sku,
        });
        // go to the Product Detail Page for the product clicked
        navigate(this.navContext, {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Product2',
                recordName: product.fields.Name.replace(' ', '-'),
                name: 'recordId',
                recordId: pid,
            },
        });
    }
    sendViewReco() {
        trackViewReco(
            this.recommenderName,
            this.recoUUID,
            this.products.map((product) => {
                return {
                    id: product.id,
                    sku: product.sku,
                };
            })
        );
    }
}