trigger CreateUserAccountfromContact on Contact (after insert, after update) { 
     if(checkRecursive.runOnce())
    {
    ContactTiggerHandler handlerObj = new ContactTiggerHandler();
    handlerObj.onTrigger();  
    }
}