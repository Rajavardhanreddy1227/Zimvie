<aura:application extends="force:slds">
    <c:zimvie_recordlist objectApiName="Order" filterfield1="EffectiveDate" filterfield2="Status" fieldsName="Id,Name,AccountId" actionName="Pay Now" onactionclicked="{!c.myAction}"></c:zimvie_recordlist>
</aura:application>