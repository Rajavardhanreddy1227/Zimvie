trigger OnCartUpdate on WebCart (after update) {
    Map < Id, WebCart > nMap = new Map < Id, WebCart > ();
    Map < Id, WebCart > oMap = new Map < Id, WebCart > ();
     nMap = Trigger.newMap;
   	 oMap = Trigger.oldMap;
      Set<Id> cartIds = new Set<Id>();
      for (WebCart newCart: trigger.new) {
           WebCart oldCart = new WebCart();
            oldCart = oMap.get(newCart.Id);
          	 system.debug('New Cart Status '+newCart.Status);
          	system.debug('Old Cart Status '+newCart.Status);
  		if (newCart.Status =='Active' && oldCart.status=='Checkout') {
       		  string cartId = trigger.new[0].Id;
 			  cartIds.add(newCart.Id);
             
          }
       	}
      system.debug('cartId---'+cartIds);
      List<CartItem> lstCI = new List<CartItem>();
   	  lstCI = [Select Id,Product2Id from CartItem where CartId IN : cartIds];
   	  Set<Id> productIds = new Set<Id>();
   		for(CartItem a:lstCI){
                productIds.add(a.Product2Id);
            }
    	 system.debug('productIds----'+productIds);
  		  List<RMA_Item__c> lstRLI = new List<RMA_Item__c>();
   		 lstRLI = [Select Id,RMAId__c from RMA_Item__c where Exchange_Product__c IN:productIds AND Cart__c IN:cartIds];
    	 system.debug('RMA Line Item List Size----'+lstRLI.size());
         List<RMA__c> lstRMA = new List<RMA__c>();
  	     if(lstRLI != null && lstRLI.size() > 0)
        {   
            for(RMA_Item__c objRLI : lstRLI){
                lstRMA.add(new RMA__c(Id=objRLI.RMAId__c));
             }
        }
        if(!lstRMA.isEmpty()){
            delete lstRMA;
        }
      }