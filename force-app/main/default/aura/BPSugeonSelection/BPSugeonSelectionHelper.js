({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event, sortField, filter, segment){ 
        var action = component.get("c.fetchAccountWrapper");
        var productgroupname= component.get("v.Productgroup");
        console.log('product group ---> '+productgroupname);
        console.log('sortField ---> '+sortField);
        console.log('segment ---> '+segment);
        action.setParams({    
            'businessplanID': component.get("v.recordId"),
            'productgroupName': productgroupname,
            'sortField': sortField,
            'isAsc': component.get("v.isAsc"),
            'filter': filter,
            'segment': segment
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set('v.listOfAllAccounts', oRes);
                    
                    //get avp name 
                    var allData = [];
                    allData = component.get("v.listOfAllAccounts");
                    var avpName = allData[0].avpName;
                    console.log('---AVP Name--'+allData[0].avpName);
                    
                    // create dashboard url based on the AVP name
                    
                    var dashboard = '';

                    if(avpName.includes('Clint Hampton')){
                        dashboard = 'AVPCLINTHAMPTON';}
                    
                    if(avpName.includes('Gary')){
                        dashboard = 'AVPOPEN';}
                    
                    if(avpName.includes('Gregg')){
                        dashboard = 'AVPGreggKunkelmann';}
                    
                    if(avpName.includes('Dean Trippiedi')){
                        dashboard = 'AVPERICMARTIN';}
                    
                    if(avpName.includes('Dean Johnson')){
                        dashboard = 'AVPMARCMURRELL';}
                    
                    if(avpName.includes('Tyler Blevins')){
                        dashboard = 'AVPTYLERBLEVINS';}
                    
                    component.set("v.dashboardName",dashboard);
                    console.log('----dashboard Name---'+component.get('v.dashboardName'));
                    
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllAccounts").length > i){
                            PaginationLst.push(oRes[i]);
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                    component.set("v.bNoRecordsFound" , false);
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);  
    },
    sortHelper: function(component, event, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
   
        if (currentDir == 'arrowdown') {
           // set the arrowDirection attribute for conditionally rendred arrow sign  
           component.set("v.arrowDirection", 'arrowup');
           // set the isAsc flag to true for sort in Assending order.  
           component.set("v.isAsc", true);
        } else {
           component.set("v.arrowDirection", 'arrowdown');
           component.set("v.isAsc", false);
        }
        if(sortFieldName == ''){
            sortFieldName = Segementation__c ; 
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        var term = component.get("v.filter"); 
        var seg = component.get("v.segment");  
        console.log('Term--**>'+term);
        console.log('Segment--**>'+seg);
        if(term == ''){
            this.doInitHelper(component, event, sortFieldName, '',seg == '' ? '' : seg);
        }else{
            this.doInitHelper(component, event, sortFieldName, term,seg == '' ? '' : seg);
        }
    },
     
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
   // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    OpportunitySelectedHelper: function(component, event, selectedRecords) {
        //call apex class method
        var action = component.get('c.createOpportunities');
        // pass the all selected record's Id's to apex method 
        action.setParams({
         'lstRecord': selectedRecords,
         'businessplanID': component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
         //store state of response
         var state = response.getState();
         if (state === "SUCCESS") {
          console.log(state);
          if (response.getReturnValue() != '') {
           // if getting any error while delete the records , then display a alert msg/
           alert('The following error has occurred' + response.getReturnValue());
          } else {
           console.log('check it--> insert successful');
          }
          // call the onLoad function for refresh the List view  
          var term = component.get("v.filter"); 
          var seg = component.get("v.segment");  
          console.log('Term--**>'+term);
          console.log('Segment--**>'+seg); 
          if(term == ''){
            this.doInitHelper(component, event, 'Market_Procedures__c', '',seg == '' ? '' : seg);
          }else{
            this.doInitHelper(component, event, 'Market_Procedures__c', term,seg == '' ? '' : seg);
          }
         }
        });
        $A.enqueueAction(action);
       },
})