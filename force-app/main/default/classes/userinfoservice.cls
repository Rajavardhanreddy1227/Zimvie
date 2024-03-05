global class userinfoservice
{
Webservice String alias;
global class userOutput
{
Webservice String flag;
Webservice String photourl;
Webservice User u;
}
Webservice static userOutput getInfo(String alias)
{
String a=String.escapeSingleQuotes(alias);
if(a=='')
{
userOutput u1=new userOutput();
u1.flag='0';
system.debug('When Alias is blank, flag='+u1.flag);
return u1;
}
list<User> lu=[select firstname,lastname,email,alias,fullphotourl,Business_Division__c from user where alias=:a limit 1];
User u2=new User();
u2=lu[0];
if(u2.Business_Division__c!='DN')
{
userOutput u1=new userOutput();
u1.flag='-1';
system.debug('When not a dental user, flag='+u1.flag);
return u1;
}
userOutput u1=new userOutput();
u1.flag='1';
u1.u=u2;
u1.photourl=u2.fullphotourl;
system.debug('User Info='+u1);
system.debug('User photourl='+u1.photourl);
system.debug('Dental user='+u1.flag);
return u1;
}
}