/**
 * @description       : 
 * @author            : hugodhm@icloud.com
 * @group             : 
 * @last modified on  : 12-06-2021
 * @last modified by  : hugodhm@icloud.com
**/
trigger contentVersionExternalLink on ContentVersion (after insert) {
    system.debug('Content version after inserttt');
	ContentTriggerHandler.createPublicLinkForFile(trigger.new);
}