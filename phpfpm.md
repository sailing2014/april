# Document About Php-fpm        
   FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features (mostly) useful for heavy-loaded sites.   
   Some Useful Information,You Can Visit http://php.net/manual/en/intro.fpm.php

## How Php-fpm Running    
   We Used Ningx That Handle For Httpd Request,Then Nginx Passing Requests to an Php-fpm Server.  

## About Nginx Configuration    
   Now, Nginx Passing Requests To 127.0.0.1:9000,Port 9000 Is An Php-fpm Server Port     
   If Your Nginx Configuration Was't Passing Request To 127.0.0.1:9000,You Would Get 502 Httpd Status Code       
   So,You Should Changed ``` fastcgi_pass   127.0.0.1:Port; ``` To ```fastcgi_pass   127.0.0.1:9000;``` In Your Nginx Configuration 

## About Php-fpm Configuration   
   Your Should Delete All Your php-fpm.conf In Your Source Code;
         
## Notice   
  **You Need An Tag For Running Ci,So That Would't Be Sytnax Problem**

# upload max file size
```   
location ~ \.php$ {
      fastcgi_param PHP_VALUE "upload_max_filesize = 50M";
      fastcgi_param PHP_VALUE "post_max_size=51M";
}  

``` 
