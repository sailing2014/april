# Proxy System

## Installation

### `scripts/install.sh`
* Usage
```
install.sh <action> <env>
```
  * Parameters

| Parameters | Description |
|------------|-------------|
| action | install update uninstall   (install：全新安装 update：更新配置文件 uninstall： 卸载)   |
| env    | developing  master  staging  (developing:开发环境 master：生产环境  staging：测试环境) |


* Pay Attention About Php-fpm 
  
    *  Nginx Act AS Reverse Proxy,That Backend Server Was Running With Nginx And Php-fpm   
       ```If Php-fpm Has Been Down,That Httpd Status Code 502 Would Be Appear```    
       * By Default, Reverse Proxy Don't Know That Php-fpm Has Been Down   
         So We Need Add  ```Need proxy_next_upstream  http_502; ```To Reverse Proxy.   
         More Information Can See http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_next_upstream
       
      
       
      