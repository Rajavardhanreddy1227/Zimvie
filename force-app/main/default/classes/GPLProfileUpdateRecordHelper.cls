public class GPLProfileUpdateRecordHelper {

    // Static variables are local to the context of a Web request  
    // (or testMethod during a runTests call)  
    // Therefore, this variable will be initialized as false  
    // at the beginning of each Web request which accesses it.  
    

    private static boolean GPLProfileUpdate = false;


    public static boolean hasAlreadyUpdatedGPLProfileRecord () {
        return GPLProfileUpdate;
    }

    // By setting the variable to true, it maintains this  
    
    // new value throughout the duration of the request  
    
    // (or testMethod)  
    
    public static void setAlreadyUpdatedGPLProfileRecord() {
        GPLProfileUpdate = true;
    }
    
}