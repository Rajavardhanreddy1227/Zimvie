/**
* @author Appirio Inc.
* @date March, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_ChartDataYOYTable Controller
*/
@isTest
public class Ortho_FieldSetsTest {
    
    @testSetup
    public static void createTestData(){
        //Create User
        User usr = TestUtilsLocal.createTestUser('Test@@2', true);
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
    }
    
    @istest
    static void testFieldSet(){
        User appUser = [Select Id,Name from User LIMIT 1]; 
        List<Ortho_FieldSets.Ortho_FieldSetMember> fsMList;
        Test.startTest();
        System.runAs(appUser) {
            fsMList = Ortho_FieldSets.getFieldsetByObjectAndName('Opportunity', 'Ortho_Mobile_Fields');
        
        }
        Test.stopTest();
        system.assert(fsMList.size() > 0);
        Ortho_FieldSets.Ortho_FieldSetMember member = fsMList.get(0);
        system.debug('member-->'+member);
        System.assert(member.required == false);
        System.assert(member.dbRequired == true);
        System.assert(member.fieldPath == 'Name');
        System.assert(member.label == 'Name');
        System.assert(member.fieldType == 'String');
        System.assert(member.fullName == 'Opportunity.Name');
        System.assert(member.relationshipPath == null );
    }
    
   /*@istest
    public static void forCoverage(){
        Ortho_FieldSets ofs = new Ortho_FieldSets();
        Ortho_FieldSets.Ortho_FieldSetMember ofsm = new Ortho_FieldSets().Ortho_FieldSetMember(ofs);
        //ofs.Ortho_FieldSetMember ofsm = new ofs.Ortho_FieldSetMember();
        ofs.Ortho_FieldSetMember.relationshipPath();
    }*/
}