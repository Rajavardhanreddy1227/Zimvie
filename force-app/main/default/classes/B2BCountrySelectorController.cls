public class B2BCountrySelectorController {
    
    @AuraEnabled(cacheable=true)
    public static String fetchLocales(){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        string result;
        try {
            List<countryWrap> lstLocale = new List<countryWrap>();
       String userType=UserInfo.getuserType();
       if(userType !='Guest'){
        for (PicklistEntry pe : User.LocaleSidKey.getDescribe().getPicklistValues()) {
            countryWrap obj = new countryWrap();
            String val = '';
            if(pe.getLabel().indexOf('(')>-1) {
                val = pe.getLabel().substring(pe.getLabel().indexOf('(')+1, pe.getLabel().indexOf(')'));
            } else{
                val = pe.getLabel();
            }
            obj.label = val;
            obj.value = pe.getValue();
            lstLocale.add(obj);
            
            system.debug('Code: '+pe.getValue() + ' Val: '+pe.getLabel()+'\n' + 'Label: '+val);
        }
    }
        else{
            
            countryWrap obj5 = new countryWrap();            
            obj5.label='United States';
            obj5.value='United States';
            lstLocale.add(obj5);

            countryWrap obj1 = new countryWrap();            
            obj1.label='Canada';
            obj1.value='Canada';
            lstLocale.add(obj1);

            countryWrap obj2 = new countryWrap();

            obj2.label='France';
            obj2.value='France';
            lstLocale.add(obj2);

            countryWrap obj3 = new countryWrap();
            obj3.label='Germany';
            obj3.value='Germany';
            lstLocale.add(obj3);

            countryWrap obj4 = new countryWrap();
            obj4.label='Spain';
            obj4.value='Spain';
            lstLocale.add(obj4);
        
        }

        // for (PicklistEntry pe : User.LocaleSidKey.getDescribe().getPicklistValues()) {
        //     system.debug(pe.getValue() + ' ' + pe.getLabel());
        //     countryWrap obj = new countryWrap();
        //     obj.label = pe.getLabel();
        //     obj.value = pe.getValue();
        //     lstLocale.add(obj);
        // }
            result = JSON.serialize(lstLocale);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
        return result;
    }

    private class countryWrap {
        private string label;
        private string value;
    }
}