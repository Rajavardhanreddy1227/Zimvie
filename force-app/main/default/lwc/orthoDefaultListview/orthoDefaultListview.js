import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import Ortho_Default_Listview_Loading from '@salesforce/label/c.Ortho_Default_Listview_Loading';
const REDIRECT_DELAY = 400;
const redirectWithDelay = navFunc => {
  setTimeout(navFunc, REDIRECT_DELAY);
};
export default class OrthoDefaultListview extends NavigationMixin(
  LightningElement
) {
  @api listView;
  @track details;
  loadingText = Ortho_Default_Listview_Loading;

  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
    console.log(currentPageReference);
    if (this.rendered) {
      this.navigateToListView();
    } else {
      this.redirectOnRendered = true;
    }
  }

  navigateToListView() {
    const selection = this.listView.split(";");
    const sObject = selection[0];
    const filter = selection[1];

    redirectWithDelay(() => {
      this[NavigationMixin.Navigate](
        {
          type: "standard__objectPage",
          attributes: {
            objectApiName: sObject,
            actionName: "list"
          },
          state: {
            filterName: filter
          }
        },
        true
      );
    });
  }

  renderedCallback() {
    this.rendered = true;
    if (this.redirectOnRendered) {
      this.navigateToListView();
    }
  }
}