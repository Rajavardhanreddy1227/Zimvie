/**
* @author Appirio Inc.
* @date Feb, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_ListviewSelector Controller
*/
@isTest
public class Ortho_ChartControllerTest {
    
    @isTest
    static void getDataTest(){
        Ortho_ChartData ocd = Ortho_ChartController.getData('Ortho_ChartDataYOYTable');
        list<Ortho_ChartFilter> ocf = new list<Ortho_ChartFilter>();
        Ortho_ChartData ocd1 = Ortho_ChartController.getData('Ortho_ChartDataYOYTable', ocf);
    }
}