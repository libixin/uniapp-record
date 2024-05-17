#import "WiFiModule.h"
#import "DCUniDefine.h"
#import "getgateway.h"

#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/sysctl.h>







@implementation WiFiModule
UNI_EXPORT_METHOD_SYNC(@selector(getWifiRouteIP:))

-(NSString *)getWifiRouteIP:(NSDictionary *)options{
        // options 为 js 端调用此方法时传递的参数
        //NSLog(@"%@",options);
        // 同步返回参数给 js 端 注:只支持返回 String 或 NSDictionary(map)类型
        //return @"success is me";
        NSString *address = @"error";
        NSString *localIp = @"error";
        NSString *netmask = @"error";
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        
        success = getifaddrs(&interfaces);
        if (success == 0) {
            temp_addr = interfaces;
            while (temp_addr != NULL) {
                if (temp_addr->ifa_addr->sa_family == AF_INET) {
                    if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr)->sin_addr)];
                        // 广播地址
                        //NSLog(@"broadcast address : %@", [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                        // 本机地址
                        //NSLog(@"local device ip : %@", [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                        localIp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                        // 子网掩码
                        //NSLog(@"netmask : %@", [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                        netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                        // 端口地址
                        //NSLog(@"interface : %@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
                    }
                }
                
                temp_addr = temp_addr->ifa_next;
            }
        }
        
        
        // Free memory
        freeifaddrs(interfaces);

        in_addr_t i =inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
        in_addr_t* x =&i;


        unsigned char *s=  getdefaultgateway(x);
        NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];

        //NSLog(@"路由器地址-----%@",ip);
        
        return ip;
        



    }


@end


