@isTest

private class CodeCoverageTest2 {

    public static ApexPages.StandardController con;
    public static CodeCoverageClass2 entre_ext;

    public static testMethod void initialize()
     {
        entre_ext = new CodeCoverageClass2();
        entre_ext.initialize ();                     
    }
}