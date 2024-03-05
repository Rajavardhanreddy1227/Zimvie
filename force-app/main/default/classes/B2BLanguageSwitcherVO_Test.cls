/**
 * @description       : Test Class
 * @author            : Mayank Srivastava
**/

@isTest
public class B2BLanguageSwitcherVO_Test {

    @isTest
    public static void testVO()
    {
        B2BLanguageSwitcherVO obj = new B2BLanguageSwitcherVO();
        obj.language = 'english';
        obj.code = 'en-US';
        obj.selected=true;
        
        System.Assert(obj != null);
    }
}