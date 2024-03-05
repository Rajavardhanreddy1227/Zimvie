public class JSONToApexOraclePayment {

	public class TrxNums {
		public String TransactionNumber;
		public String SfInvoiceId;
	}

	public String SfPaymentId;
	public String ReceiptNumber;
	public Decimal ReceiptAmount;
	public String ReceiptCurrency;
	public Date ReceiptDate;
	public String CustomerNumber;
	//public String ReceiptMethodID;
	public String CreditCardToken;
	//public String GLDate;
	public String CardHolderName;
	public String CardNumber;
	public String CardCurrency;
	public String Org_id;
	public Date CardExpirationDate;
	public List<TrxNums> TrxNums;

	
	public static List<JSONToApexOraclePayment> parse(String json) {
		return (List<JSONToApexOraclePayment>) System.JSON.deserialize(json, List<JSONToApexOraclePayment>.class);
	}
}