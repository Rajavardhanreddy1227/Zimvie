@isTest

private class CodeCoverageTest {

    public static ApexPages.StandardController con;
    public static CodeCoverageClass entre_ext;

    public static testMethod void initialize()
     {
        entre_ext = new CodeCoverageClass();
        entre_ext.initialize ();                     
    }
}