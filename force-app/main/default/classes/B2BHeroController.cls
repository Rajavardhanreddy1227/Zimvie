public class B2BHeroController {
    @AuraEnabled (cacheable=true)
    public static String retrieveMediaFromCMS(){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        String res;
        try {
            String channelName = 'zimvie';
        String channelId = getChannelId(channelName);
  
        //get the image content
        ConnectApi.ManagedContentVersionCollection obj = 
            ConnectApi.ManagedContent.getAllContent(channelId, 0, 5, 'en_US', 
                                                    'cms_image',false,
                                                    '2011-02-25T18:24:31.000Z','2021-09-25T18:24:31.000Z',true);
        
        List<ReturnWrapper> wrapperList = new List<ReturnWrapper>();
        System.debug('json value=' + JSON.serialize(obj));

        //loop through each item and prepare a wrapper list
        for(ConnectApi.ManagedContentVersion versionObj: obj.items){
            ReturnWrapper wrapper = new ReturnWrapper();
            wrapper.title = versionObj.title;
            
            //get the url
            Map<String,ConnectApi.ManagedContentNodeValue> contentNodesMap = versionObj.contentNodes;
            for(String str:contentNodesMap.keySet()){                
                if(str=='source'){
                    wrapper.url= ((ConnectApi.ManagedContentMediaSourceNodeValue)contentNodesMap.get(str)).url;
                }		
            }
            wrapperList.add(wrapper);	
        }
            res = JSON.serialize(wrapperList);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return res;
    }

    @AuraEnabled (cacheable=true)
    public static String getChannelId(String channelName){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            ConnectApi.ManagedContentChannelCollection channelRepObj = 
                ConnectApi.ManagedContent.getAllDeliveryChannels(0,2);        

            //loop through the channels and return the channel Id
            for(ConnectApi.ManagedContentChannel channelObj: channelRepObj.channels){
                if(channelObj.channelName == channelName){
                    return channelObj.channelId;
                }
            }
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        return null;
    }

    public class ReturnWrapper{
        String title {get;set;}
        String url {get;set;}
    }
}