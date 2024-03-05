global with sharing class B2BNavigationMenuItemsController {
    public static set<String> setCatId = new Set<String>();
    @AuraEnabled(cacheable=true)
    public static string getNavigationMenuItemsFromConnectAPI(){
        try {
            Map<String,String> mapExternalUrl = new Map<String,String>();
            Id commId = [SELECT id, name FROM Network where name = 'Zimvie' limit 1].id;
            String effectiveAccountId = [Select AccountId from User where Id=:Userinfo.getUserId()].AccountId;
            if(effectiveAccountId == null){
                effectiveAccountId = '0016u00000fyVSfAAM';
            }
            if(Auth.CommunitiesUtil.isGuestUser())
            {
                effectiveAccountId = null;
            }
            List<ConnectApi.NavigationMenuItemType> lstSkipTypes = new List<ConnectApi.NavigationMenuItemType>();
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.Event);
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.ExternalLink);
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.GlobalAction);
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.MenuLabel);
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.Modal);
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.NavigationalTopic);
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.SalesforceObject);
            lstSkipTypes.add(ConnectApi.NavigationMenuItemType.SystemLink);
            //system.debug('objNLS='+objNLS);
            system.debug('communityId=='+commId);
            ConnectApi.NavigationMenuItemCollection navResults = ConnectApi.NavigationMenu.getCommunityNavigationMenu(commId, null, System.label.navigationLinkSetDevName, ConnectApi.PublishStatus.Live, true, false, lstSkipTypes, effectiveAccountId);
            getCategoryIds(navResults.menuItems);
            List<ProductCategory> lstCat = new List<ProductCategory>();
            lstCat = [Select Id,ExternalURL__c from ProductCategory where Id IN: setCatId AND ExternalURL__c != null];
            if(lstCat != null && lstCat.size() > 0){
                for(ProductCategory objProdCat : lstCat){
                    mapExternalUrl.put(objProdCat.Id,objProdCat.ExternalURL__c);
                }
            }
            connectApiNavWrapper objwrap = new connectApiNavWrapper();
            objwrap.mapCat = mapExternalUrl;
            objwrap.navResults = navResults;
            return JSON.serialize(objwrap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class connectApiNavWrapper{
        Map<String,String> mapCat;
        ConnectApi.NavigationMenuItemCollection navResults;
    }
    
    public static void getCategoryIds(List<ConnectApi.NavigationMenuItem> menuItems)
    {
        for(ConnectApi.NavigationMenuItem objMenuItem : menuItems){
            setCatId.add(objMenuItem.actionValue.substring(objMenuItem.actionValue.lastIndexOf('/') + 1));
            if(objMenuItem.subMenu.size() > 0){
                getCategoryIds(objMenuItem.subMenu);
            }
        }
    }
    /*@AuraEnabled(cacheable=true)
    public static String getNavigationMenuItems(String parentCategoryName, String homeUrl, String baseUrl,String language) {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        string res;
        try {
            system.debug('baseUrl=='+baseUrl);
        Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'Zimvie' LIMIT 1];

        baseUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        String lang = userInfo.getLanguage();
        String translatedLabel;
        
        List<navigationWrapper> lstNavItems = new List<navigationWrapper>();

        Map<Id, ProductCategory> categoriesMap = new Map<Id, ProductCategory>([Select Id,Name,ExternalURL__c,(Select Id,Name,ExternalURL__c from ChildCategories order by SortOrder) from ProductCategory where ParentCategory.Name =: parentCategoryName order by SortOrder]);

        Map<Id, ProductCategory> childCategoriesMap = new Map<Id, ProductCategory>([SELECT Id,Name,ExternalURL__c, (SELECT Id,Name,ExternalURL__c from ChildCategories order by SortOrder) FROM ProductCategory WHERE ParentCategoryId IN :categoriesMap.keySet() order by SortOrder]);
		
		Map<Id, ProductCategory> grandchildCategoriesMap = new Map<Id, ProductCategory>([SELECT Id,Name,ExternalURL__c, (SELECT Id,Name,ExternalURL__c from ChildCategories order by SortOrder) FROM ProductCategory WHERE ParentCategoryId IN :childCategoriesMap.keySet() order by SortOrder]);

        List<ProductCategoryDataTranslation> prodCatDataTranslation = new List<ProductCategoryDataTranslation>([SELECT  Id,ParentId,Language,Name FROM ProductCategoryDataTranslation where Language=:language]);
        
        Map<String,String> translatedValues = new Map<String,String> ();
        for(ProductCategoryDataTranslation pcdt : prodCatDataTranslation){
            translatedValues.put(pcdt.ParentId,pcdt.Name);
        }

        for(ProductCategory objCt :categoriesMap.values()){
            navigationWrapper objwrap = new navigationWrapper();
            objwrap.label = objCt.Name;
            translatedLabel = translatedValues.get(objCt.Id);
            if(translatedLabel!= null){
                objwrap.label = translatedLabel;
            }
            List<navigationWrapper> lstChildNavItems = new List<navigationWrapper>();
            if(objCt.ChildCategories != null && objCt.ChildCategories.size() > 0){
                objwrap.isMulti = true;
                navigationWrapper objChildAllwrap = new navigationWrapper();
                objChildAllwrap.label = lang == 'fr' ? 'Tout' : lang == 'es' ? 'Todo' : lang == 'de' ? 'Alle' : 'ALL';
                
                if(String.isBlank(objCt.ExternalURL__c)){
                   objChildAllwrap.target = baseUrl+'/category/'+objCt.Id;
                }
                else{
                    objChildAllwrap.target = objCt.ExternalURL__c;
                }
                
                lstChildNavItems.add(objChildAllwrap);
                for(ProductCategory objChildCt : objCt.ChildCategories){
                    navigationWrapper objChildwrap = new navigationWrapper();
                    objChildwrap.label = objChildCt.Name;
                    translatedLabel = translatedValues.get(objChildCt.Id);
                     if(translatedLabel!= null){
                        objChildwrap.label = translatedLabel;
                    }
                    
                    List<navigationWrapper> lstgrandChildNavItems = new List<navigationWrapper>();
                    if(childCategoriesMap.get(objChildCt.Id).ChildCategories != null && childCategoriesMap.get(objChildCt.Id).ChildCategories.size() > 0){
                        objChildwrap.isMulti = true;
                        for(ProductCategory grandChildCat : childCategoriesMap.get(objChildCt.Id).ChildCategories){
                            navigationWrapper objgrandChildwrap = new navigationWrapper();
                            objgrandChildwrap.label = grandChildCat.Name;

                            translatedLabel = translatedValues.get(grandChildCat.Id);
                            if(translatedLabel!= null){
                                objgrandChildwrap.label = translatedLabel;
                            }
                            //
                            List<navigationWrapper> lstgreatgrandChildNavItems = new List<navigationWrapper>();
                            if(grandchildCategoriesMap.get(grandChildCat.Id).ChildCategories != null && grandchildCategoriesMap.get(grandChildCat.Id).ChildCategories.size() > 0){
                                objgrandChildwrap.isMulti = true;
                                for(ProductCategory greatgrandChildCat : grandchildCategoriesMap.get(grandChildCat.Id).ChildCategories){
                                    navigationWrapper objgreatgrandChildwrap = new navigationWrapper();
                                    objgreatgrandChildwrap.label = greatgrandChildCat.Name;  
                                    
                                    translatedLabel = translatedValues.get(greatgrandChildCat.Id);
                                    if(translatedLabel!= null){
                                        objgreatgrandChildwrap.label = translatedLabel;
                                    }
                                    
                                    objgreatgrandChildwrap.isMulti = false;
                                    objgreatgrandChildwrap.subMenu = null;
                                    if(String.isBlank(greatgrandChildCat.ExternalURL__c)){
                                        objgreatgrandChildwrap.target = baseUrl+'/category/'+greatgrandChildCat.Id;
                                    }
                                    else{
                                        objgreatgrandChildwrap.target = greatgrandChildCat.ExternalURL__c;
                                    }
                                    lstgreatgrandChildNavItems.add(objgreatgrandChildwrap);
                                }
                                objgrandChildwrap.subMenu = lstgreatgrandChildNavItems;
                            } else {
                                objgrandChildwrap.isMulti = false;
                                objgrandChildwrap.subMenu = null;
                                if(String.isBlank(grandChildCat.ExternalURL__c)){
                                    objgrandChildwrap.target = baseUrl+'/category/'+grandChildCat.Id;
                                }
                                else{
                                    objgrandChildwrap.target = grandChildCat.ExternalURL__c;
                                }
                            }
                            //
                            
                            //objgrandChildwrap.isMulti = false;
                            //objgrandChildwrap.subMenu = null;
                            //objgrandChildwrap.target = baseUrl+'/category/'+grandChildCat.Id;
                            lstgrandChildNavItems.add(objgrandChildwrap);
                        }
                        objChildwrap.subMenu = lstgrandChildNavItems;
                    } else {
                        objChildwrap.isMulti = false;
                        objChildwrap.subMenu = null;
                        if(String.isBlank(objChildCt.ExternalURL__c)){
                            objChildwrap.target = baseUrl+'/category/'+objChildCt.Id;
                        }
                        else{
                            objChildwrap.target = objChildCt.ExternalURL__c;
                        }
                    }
                    lstChildNavItems.add(objChildwrap);
                }
                objwrap.subMenu = lstChildNavItems;
                //
            } else {
                objwrap.isMulti = false;
                objwrap.subMenu = null;
                if(String.isBlank(objCt.ExternalURL__c)){
                    objwrap.target = baseUrl+'/category/'+objCt.Id;
                }
                else{
                    objwrap.target = objCt.ExternalURL__c;
                }
            }
            lstNavItems.add(objwrap);   
        }
        res=  JSON.serialize(lstNavItems);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return res;
    }*/
    
    

    /*public class navigationWrapper {
        public string target;
        public string label;
        public List<navigationWrapper> subMenu;
        public string windowName;
        public string id;
        public Boolean isMulti;
    }*/
}