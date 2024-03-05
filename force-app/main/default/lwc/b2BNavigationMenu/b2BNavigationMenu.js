import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import brandimages from '@salesforce/resourceUrl/brandimages';
//import getNavigationMenuItems from '@salesforce/apex/B2BNavigationMenuItemsController.getNavigationMenuItems';
import getNavigationMenuItemsFromConnectAPI from '@salesforce/apex/B2BNavigationMenuItemsController.getNavigationMenuItemsFromConnectAPI';
import svgLogo from '@salesforce/resourceUrl/svgLogo';
import B2B_All from '@salesforce/label/c.B2B_All';
import B2B_BIOMATERIALS from '@salesforce/label/c.B2B_BIOMATERIALS';
/**
 * This is a custom LWC navigation menu component.
 * Make sure the Guest user profile has access to the NavigationMenuItemsController apex class.
 */
export default class NavigationMenu extends LightningElement {
    labels = {
        B2B_All,
        B2B_BIOMATERIALS
    };
    currbasePath;
    dropRightIconUrl;
    hideComponent = false;
    renderedCallback() {
        this.dropRightIconUrl = svgLogo + '/svglogo/dropdown-b-right.svg';
        if(localStorage['selectedBrand'] == 'azure'){
        //if(window.location.href.includes('azure')){
            this.parentCategoryName = 'Azure';
            this.homeUrl = basePath+'/';
            this.imgurl = brandimages + '/azure.png';
            var css = this.template.host.style;
            css.setProperty('--tabColour', '#FFFFFF');
            css.setProperty('--textColour', '#0A2043');
            css.setProperty('--hoverTextColour', '#0A2043');
            css.setProperty('--hoverBGColour', '#FFFFFF');
        } else {
            this.parentCategoryName = 'Zimvie';
            this.homeUrl = basePath+'/';
            this.imgurl = brandimages + '/zimvie.png';
            var css = this.template.host.style;
            css.setProperty('--tabColour', '#0A2043');
            css.setProperty('--textColour', '#FFFFFF');
            css.setProperty('--hoverTextColour', '#0A2043');
            css.setProperty('--hoverBGColour', '#FFFFFF');
        }
        this.currbasePath = basePath;
        console.log('currbasePath=='+this.currbasePath);
    }

    newNavigationMenu;
    navLoaded = false;
    externalCatMap;
    @wire(getNavigationMenuItemsFromConnectAPI)
    wiredMenuItems({error, data}) {
        if (data && !this.navLoaded) {
            console.log('nav menus are :::: '+data);
            let parsedData = JSON.parse(data);
            this.externalCatMap = parsedData.mapCat;
            console.log('this.externalCatMap=='+this.externalCatMap);
            let tempMenus = parsedData.navResults.menuItems;
            tempMenus.forEach(element => {
                if(element.label.toUpperCase() == this.parentCategoryName.toUpperCase()){
                    let tempValStr = JSON.stringify(element.subMenu).replaceAll("\"subMenu\":[],", "");
                    //console.log('after removing null menus : '+tempValStr);
                    let tempVal = JSON.parse(tempValStr);
                    for(var indx=0; indx < tempVal.length; indx++){
                        if(localStorage['selectedBrand'] == 'azure'){
                            tempVal[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-b.svg';   
                        }
                        else{
                            tempVal[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-w.svg';
                        }
                        if(tempVal[indx].label.toUpperCase() == this.labels.B2B_BIOMATERIALS){
                            if(localStorage['selectedBrand'] == 'azure'){
                                tempVal[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-blue.svg';
                                tempVal[indx].style = 'color: #0044FC;';
                            }
                            else{
                                tempVal[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-lemon.svg';
                                tempVal[indx].style = 'color: #E6DC19;';
                            }
                        }
                        //if(tempVal[indx].subMenu.length < 1){
                        //    tempVal[indx].subMenu = null;
                        //}
                    }
                    //console.log('tempVal str : '+JSON.stringify(tempVal));
                    console.log(tempVal);
                    tempVal.forEach(item => {
                        // Check if the item has a subMenu array
                        if (item.subMenu) {
                          // Create a new submenu item for "All"
                          const allSubMenu = {
                            actionType: "InternalLink",
                            actionValue: item.actionValue,
                            imageUrl: null,
                            label: this.labels.B2B_All,
                            target: "CurrentWindow"
                          };
                      
                          // Insert the "All" submenu item as the first item in the subMenu array
                          item.subMenu.unshift(allSubMenu);
                        }
                    });
                    this.newNavigationMenu = this.updateActionValue(tempVal);
                    console.log(this.newNavigationMenu);
                }
            });
            this.navLoaded = true;
            console.log('menuitems>>>'+JSON.stringify(this.menuItems));
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.navLoaded = true;
            console.error(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    updateActionValue(data) {
        data.forEach(item => {
          if (item.actionValue) {
            let catId = item.actionValue.substr(item.actionValue.lastIndexOf("/")+1);
            
            item.actionValue = '/Zimvie/category/'+catId;
            
            console.log('catId=='+catId);
            if(this.externalCatMap[catId]){
                item.actionValue = this.externalCatMap[catId];
            }
          }
          if (item.subMenu) {
            this.updateActionValue(item.subMenu);
          }
        });
        return data;
    }

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          var pageName = currentPageReference.attributes.name;
          if(pageName == 'Current_Checkout'){
              this.hideComponent = true;
          }
          else{
              this.hideComponent = false;
          }
       }
    }

    handleBrandClick(){
        window.location.href=this.homeUrl;
    }

    imgurl;
    /**
     * the label or name of the nav menu linkset (NavigationMenuLinkSet.MasterLabel) exposed by the .js-meta.xml,
     * used to look up the NavigationMenuLinkSet.DeveloperName
     */
     @api parentCategoryName;

     /**
      * include the Home menu URL
      */
     @api homeUrl;

    /**
     * the menu items when fetched by the NavigationItemsController
     */
    @track menuItems = [];

    /**
     * if the items have been loaded
     */
    @track isLoaded = false;

    /**
     * the error if it occurs
     */
    @track error;

    /**
     * Using a custom Apex controller, query for the NavigationMenuItems using the
     * menu name and published state.
     * 
     * The custom Apex controller is wired to provide reactive results. 
     */
    /*@wire(getNavigationMenuItems, {
        parentCategoryName: '$parentCategoryName',
        homeUrl: '$homeUrl',
        basePath : '$currbasePath',
        language : localStorage['selectedlanguage']
    })
    wiredMenuItems({error, data}) {
        if (data && !this.isLoaded) {
            //console.log('basePath='+basePath);
            //console.log('this.homeUrl='+this.homeUrl);
            //console.log('navigation === '+data);
            let menuItemsResult = JSON.parse(data);
            for(var indx=0; indx < menuItemsResult.length; indx++){
                if(localStorage['selectedBrand'] == 'azure'){
                    menuItemsResult[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-b.svg';   
                }
                else{
                    menuItemsResult[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-w.svg';
                }
                if(menuItemsResult[indx].label.toUpperCase() == 'BIOMATERIALS'){
                    if(localStorage['selectedBrand'] == 'azure'){
                        menuItemsResult[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-blue.svg';
                        menuItemsResult[indx].style = 'color: #0044FC;';
                    }
                    else{
                        menuItemsResult[indx].dropDownIconUrl = svgLogo + '/svglogo/drop-down-arrow-lemon.svg';
                        menuItemsResult[indx].style = 'color: #E6DC19;';
                    }
                }
            }
            this.menuItems = menuItemsResult;
            this.error = undefined;
            this.isLoaded = true;
            console.log('menuitems>>>'+JSON.stringify(this.menuItems));
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.isLoaded = true;
            console.error(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }*/
}