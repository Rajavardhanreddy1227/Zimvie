import { LightningElement,api } from 'lwc';
import getInvoiceDetailRecord from '@salesforce/apex/listOfRecordsToUpdateController.getInvoiceDetailRecord';
import B2B_Zimvie_Address from '@salesforce/label/c.B2B_Zimvie_Address';
import B2B_Zimvie_Phone from '@salesforce/label/c.B2B_Zimvie_Phone';
import B2B_Zimvie_Website from '@salesforce/label/c.B2B_Zimvie_Website';
import B2B_Zimvie_EIN from '@salesforce/label/c.B2B_Zimvie_EIN';
import B2B_Zimvie_Orders_Number from '@salesforce/label/c.B2B_Zimvie_Orders_Number';
import B2B_Zimvie_Orders_Fax from '@salesforce/label/c.B2B_Zimvie_Orders_Fax';
import B2B_Zimvie_Accounting_No from '@salesforce/label/c.B2B_Zimvie_Accounting_No';
import B2B_Zimvie_Accounting_Fax from '@salesforce/label/c.B2B_Zimvie_Accounting_Fax';
import B2B_Back_to_All_Invoices from '@salesforce/label/c.B2B_Back_to_All_Invoices';
import B2B_Invoice_Number from '@salesforce/label/c.B2B_Invoice_Number';
import B2B_Invoice_Details from '@salesforce/label/c.B2B_Invoice_Details';
import date from '@salesforce/label/c.date';
import Order_Number from '@salesforce/label/c.Order_Number';
import Order_Date from '@salesforce/label/c.Order_Date';
import B2B_Delivery_Number from '@salesforce/label/c.B2B_Delivery_Number';
import Customer_Number from '@salesforce/label/c.Customer_Number';
import B2B_Customer_PO_Number from '@salesforce/label/c.B2B_Customer_PO_Number';
import B2B_Patient_Ref from '@salesforce/label/c.B2B_Patient_Ref';
import B2B_Total_Amount from '@salesforce/label/c.B2B_Total_Amount';
import DueDate from '@salesforce/label/c.DueDate';
import B2B_Payment_Terms from '@salesforce/label/c.B2B_Payment_Terms';
import B2B_Remit_to from '@salesforce/label/c.B2B_Remit_to';
import Address from '@salesforce/label/c.Address';
import Phone from '@salesforce/label/c.Phone';
import Website from '@salesforce/label/c.Website';
import B2B_EIN from '@salesforce/label/c.B2B_EIN';
import Orders from '@salesforce/label/c.Orders';
import B2B_Orders_Fax from '@salesforce/label/c.B2B_Orders_Fax';
import B2B_Accounting from '@salesforce/label/c.B2B_Accounting';
import B2B_Accounting_Fax from '@salesforce/label/c.B2B_Accounting_Fax';
import B2B_Ship_To from '@salesforce/label/c.B2B_Ship_To';
import B2B_Bill_To from '@salesforce/label/c.B2B_Bill_To';
import B2B_Item_Summary from '@salesforce/label/c.B2B_Item_Summary';
import Items from '@salesforce/label/c.Items';
import B2B_Qty_Ordered from '@salesforce/label/c.B2B_Qty_Ordered';
import B2B_Qty_Backordered from '@salesforce/label/c.B2B_Qty_Backordered';
import B2B_Qty_Shipped from '@salesforce/label/c.B2B_Qty_Shipped';
import B2B_Print from '@salesforce/label/c.B2B_Print';
import B2B_Invoice_Detail_Data from '@salesforce/label/c.B2B_Invoice_Detail_Data';
import img from '@salesforce/resourceUrl/default';
import brandimage from '@salesforce/resourceUrl/brandimages';


export default class B2bInvoiceDetailView extends LightningElement {
    @api invoiceName;
    invoiceData;
    isLoading=false;
    defaultimg = img;
    brandimg = brandimage+'/zimvie.png';

    labels={
        B2B_Zimvie_Address,B2B_Zimvie_Phone,B2B_Zimvie_Website,B2B_Zimvie_EIN,B2B_Zimvie_Orders_Number,B2B_Zimvie_Orders_Fax,
        B2B_Zimvie_Accounting_No,B2B_Zimvie_Accounting_Fax,B2B_Back_to_All_Invoices,B2B_Invoice_Number,B2B_Invoice_Details,
        date,Order_Number,Order_Date,B2B_Delivery_Number,Customer_Number,B2B_Customer_PO_Number,B2B_Patient_Ref,B2B_Total_Amount,
        DueDate,B2B_Payment_Terms,B2B_Remit_to,Address,Phone,Website,B2B_EIN,Orders,B2B_Orders_Fax,B2B_Accounting,B2B_Accounting_Fax,
        B2B_Ship_To,B2B_Bill_To,B2B_Item_Summary,Items,B2B_Qty_Ordered,B2B_Qty_Backordered,B2B_Qty_Shipped,B2B_Print,B2B_Invoice_Detail_Data

    }

    connectedCallback(){
        console.log('here inside connnected call back of invoice details');
        console.log('invoice value>>'+this.invoiceName);
        this.isLoading = true;
        getInvoiceDetailRecord({invoiceName:this.invoiceName})
        .then(response =>{
            this.isLoading = false;
            console.log('here invoice detail response>>>'+JSON.stringify(response));
            this.invoiceData = response;
        })
        .catch(error=>{
            this.isLoading = false;
            console.log('here invoice detail error>>>'+JSON.stringify(error));
            console.log(error);
        })
    }

    handleBacktoallinvoice(){
        this.dispatchEvent(new CustomEvent('backtoallinvoice', {
            detail: {}
        }));
    }

    handlePrint(){
        window.print();
    }
}