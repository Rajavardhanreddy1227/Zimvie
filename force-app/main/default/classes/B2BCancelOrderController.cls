public class B2BCancelOrderController {
    @AuraEnabled
    public static void cancelOrder(String recId,String orderId,String accId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            List<Contract> lstContract = new List<Contract>();
            lstContract = [Select Id from Contract where AccountId=:accId];
            Id contrId;
            if(lstContract != null && lstContract.size() > 0){
                contrId = lstContract[0].Id;
            } else {
                Contract objContr = new Contract(AccountId=accId,StartDate=System.today(),ContractTerm=12);
                insert objContr;
                contrId = objContr.Id;
            }

            Order objOrder = new Order(Id=orderId,ContractId=contrId,Status='Draft');
            update objOrder;

            OrderSummary objos = new OrderSummary(Id=recId,Status='Cancelled');
            update objos;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
    }
}