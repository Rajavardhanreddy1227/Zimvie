import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";


export default class OrthoLink extends NavigationMixin(LightningElement) {
  @api show = false
  @api url;
  @api buttonText;
  openLink() {
    const link = {
      type: "standard__webPage",
      attributes: {
        url: this.url
      }
    };

    this[NavigationMixin.Navigate](link);
  }
}