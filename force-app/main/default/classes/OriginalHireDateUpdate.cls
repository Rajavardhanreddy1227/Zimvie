public with sharing class OriginalHireDateUpdate { 
// Static variables are local to the context 
private static boolean alreadyLaunchedUpdateTrigger = false; 
public static boolean hasAlreadyLaunchedUpdateTrigger()
{ 
return alreadyLaunchedUpdateTrigger; 
} 
// By setting the variable to true, it maintains this 
// new value throughout the duration of the request 

public static void setAlreadyLaunchedUpdateTrigger()
{ 
alreadyLaunchedUpdateTrigger = true; 
}
}