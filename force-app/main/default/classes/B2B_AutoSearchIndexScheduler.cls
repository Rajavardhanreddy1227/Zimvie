global class B2B_AutoSearchIndexScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        String webstoreId = [Select id from WebStore Where Name = 'Zimvie' order by createddate desc limit 1].id; 
        ConnectApi.CommerceSearchIndexCollection objIndexCollection = ConnectApi.CommerceSearchSettings.getCommerceSearchIndexes(webstoreId);
        Boolean doSearchIndex = true;
        
        if (objIndexCollection.indexes != null && objIndexCollection.indexes.size() > 0) {
            for (ConnectApi.CommerceSearchIndex objIndex : objIndexCollection.indexes) {
                if (objIndex.indexBuildType == ConnectApi.CommerceSearchIndexBuildType.Full && objIndex.indexStatus == ConnectApi.CommerceSearchIndexStatus.InProgress) {
                    doSearchIndex = false;
                    break;
                }
            }
        }
        
        if (doSearchIndex == true) {
            ConnectApi.CommerceSearchSettings.createCommerceSearchIndex(webstoreId, ConnectApi.CommerceSearchIndexBuildType.Full);
        }
    }
}