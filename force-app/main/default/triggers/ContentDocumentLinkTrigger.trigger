/**
 * @description       : 
 * @author            : hugodhm@icloud.com
 * @group             : 
 * @last modified on  : 12-06-2021
 * @last modified by  : hugodhm@icloud.com
**/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    for(ContentDocumentLink l:Trigger.new) {
        l.Visibility='AllUsers';
    }
}