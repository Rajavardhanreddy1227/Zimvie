public with sharing class B2BWebStorePicklist extends VisualEditor.DynamicPickList{

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        for(WebStore store : Database.query('SELECT Id,Name FROM WebStore LIMIT 100')){
            myValues.addRow(new VisualEditor.DataRow(String.valueOf(store.Name) , String.valueOf(store.Id)));
        }
        return myValues;
    }

    public override VisualEditor.DataRow getDefaultValue() {
        //TODO USE CONSTANTS
        String storeName = 'ZimVie' ;
        List<WebStore> webStores = Database.query('SELECT Id,Name FROM WebStore WHERE NAME=: storeName  LIMIT 1');
        if(!webStores.isEmpty()){
            return new VisualEditor.DataRow(String.valueOf(webStores.get(0).Name), String.valueOf(webStores.get(0).Id));
        }else{
            return null;
        }
    }
}