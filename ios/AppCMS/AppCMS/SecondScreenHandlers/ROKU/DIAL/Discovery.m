//
//  Discovery.m
//  Copyright (c) 2013 Roku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <fcntl.h>
#import <unistd.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#import "Discovery.h"

@interface SSDP : NSObject {
    
    CFSocketRef socketRef;
}

-(BOOL)isSocketOpen;

//@property (nonatomic, assign) CFSocketRef socket;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) int count;

@property (nonatomic, retain) NSObject<DiscoveryEventsDelegate> *listener;

- (id)initWithDelegate:(NSObject<DiscoveryEventsDelegate> *)listener;

- (BOOL)open;
- (void)sendBroadcast;

@end

//@interface Scan : NSObject
//@property (nonatomic, retain) NSString *root;
//@property (nonatomic) int count;
//
//@property NSObject<DiscoveryEventsDelegate> * listener;
//- (id)initWithDelegate:(NSObject<DiscoveryEventsDelegate> *)listener;
//@end


static const SSDP* s;

/*
 * Discovery
 */
@implementation Discovery

+(Discovery *)sharedDiscovery
{
    static Discovery* sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[Discovery alloc]init];
    });
    return sharedObj;
}

-(void)startSSDPBroadcast:(NSObject<DiscoveryEventsDelegate> *)listener {
    if ([s isSocketOpen] == NO) {
        s = [[SSDP alloc] initWithDelegate:listener];
        [s open];
        [s sendBroadcast];
    }
}
@end


/*
 * RokuBox
 */
@implementation DiscoveredRokuBox
@end



/*
 * SSDP
 */

@implementation SSDP
{
    BOOL isSocketOpen;
}
- (id)initWithDelegate:(NSObject<DiscoveryEventsDelegate> *)l
{
    NSLog(@"SSDP init");
    self = [super init];
    if (self != nil) {
        self.listener = l;
    }
    return self;
}

/*
 * Internal
 */

- (BOOL)open
{
    NSLog(@"SSDP open port:%i",1900);
    isSocketOpen = YES;
    // Create socketRef
    const int sock = socket(AF_INET,SOCK_DGRAM,0);
    if (0 > sock) {
        NSLog(@"socket failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
        return false;
    }
    
    // Non-blocking
    {
        const int flags = fcntl(sock, F_GETFL);
        if (0 > fcntl(sock,F_SETFL,flags | O_NONBLOCK)) {
            NSLog(@"fcntl failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
            close(sock);
            return false;
        }
    }
    // Reuse address
    {
        u_int yes = 1;
        if (0 > setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(yes))) {
            NSLog(@"setsockopt SO_REUSEADDR failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
            close(sock);
            return false;
        }
    }
    // Ignore SIGPIPE 13 error when writing to disconnected pipe
    {
        u_int no = 1;
        if (0 > setsockopt(sock,SOL_SOCKET,SO_NOSIGPIPE,&no,sizeof(no))) {
            NSLog(@"setsockopt SO_NOSIGPIPE failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
            close(sock);
            return false;
        }
    }
    // Set SO_RCVTIMEO
    {
        struct timeval timeout = {5,0};
        if (0 > setsockopt(sock,SOL_SOCKET,SO_RCVTIMEO,(char *)&timeout,sizeof(timeout))) {
            NSLog(@"setsockopt SO_RCVTIMEO failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
            close(sock);
            return false;
        }
    }
    // Set SO_BROADCAST
    {
        u_int yes = 1;
        if (0 > setsockopt(sock,SOL_SOCKET,SO_BROADCAST,&yes,sizeof(yes))) {
            NSLog(@"setsockopt SO_NOSIGPIPE failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
            close(sock);
            return false;
        }
    }
    
    // Big receive buffer
    {
        u_int size = 64*1024;
        if (0 > setsockopt(sock,SOL_SOCKET,SO_RCVBUF,&size,sizeof(size))) {
            NSLog(@"setsockopt failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
            close(sock);
            return false;
        }
    }
    
    // Wrap in a CFSocket and schedule on async runloop
    {
        const CFSocketContext context = {0,(__bridge void *)(self),NULL,NULL,NULL};
        
        socketRef = CFSocketCreateWithNative(NULL,sock,kCFSocketReadCallBack, readCallback,&context);
        
        // The socket will now take care of cleaning up our file descriptor
        assert( CFSocketGetSocketFlags(socketRef) & kCFSocketCloseOnInvalidate );
        
        CFRunLoopSourceRef rls = CFSocketCreateRunLoopSource(NULL, socketRef, 0);
        if (NULL == rls) {
            NSLog(@"CFSocketCreateRunLoopSource failed, should never happen");
            return false;
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
        CFRelease(rls);
    }
    
    return true;
}

- (void)close
{
    NSLog(@"SSDP close");
    close(CFSocketGetNative(socketRef));
    CFRelease(socketRef);
    isSocketOpen = NO;
//    socketRef = nil;
}

- (void)sendBroadcast
{
    NSLog(@"SSDP sendBroadcast");
    struct sockaddr_in addr = {0};
    addr.sin_len         = sizeof(addr);
    addr.sin_family      = AF_INET;
    addr.sin_port        = htons(1900);
    addr.sin_addr.s_addr = inet_addr("255.255.255.255");
    const static char rqst[] = {
        "M-SEARCH * HTTP/1.1\n" \
        "Host: 239.255.255.250:1900\n" \
        "Man: \"ssdp:discover\"\n" \
        "MX: 3\n" \
        "ST: urn:dial-multiscreen-org:service:dial:1\n" \
        "\n"
    };
    
    if (0 > sendto(CFSocketGetNative(socketRef),rqst,strlen(rqst),0,(struct sockaddr*)&addr,sizeof(addr))) {
        NSLog(@"sendto failed errno:%i (%@)",errno,[NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil]);
    }
    
    self.count = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerEvent) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer
                                 forMode:NSRunLoopCommonModes];
}



- (void)readData
{
    //  NSLog(@"SSDP readData");
    
    if (![NSThread isMainThread]) NSLog(@"not on main thread");
    
    struct sockaddr_in addr;
    socklen_t addrLen = sizeof(addr);
    
    uint8_t buffer[65536];
    const ssize_t bytesRead = recvfrom(CFSocketGetNative(socketRef), buffer, sizeof(buffer), 0, (struct sockaddr *) &addr, &addrLen);
    
    if (0 > bytesRead) {
        NSLog(@"recvfrom < -1, socket is closed");
        isSocketOpen = NO;
        return;
    }
    if (0 == bytesRead) {
        NSLog(@"recvfrom == 0, should never happen");
        return;
    }
    
    NSData *dataObj = [NSData dataWithBytes:buffer length:(NSUInteger)bytesRead];
    if (nil == dataObj) {
        NSLog(@"dataWithBytes return nil, should never happen");
        return;
    }
    
    const unsigned char node = ( addr.sin_addr.s_addr >>24 ) &0xFF;
    
    char addrr[1+INET_ADDRSTRLEN] = {0};
    inet_ntop(AF_INET, &addr.sin_addr.s_addr, addrr, sizeof(addrr));
    const NSString *d = [[NSString stringWithCString:[dataObj bytes] encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
#pragma unused(d)
    
    self.count++;
    
    // NSLog(@"DISCOVERED: %@", d);
    const DiscoveredRokuBox *b = [[DiscoveredRokuBox alloc] init];
    b.node = (int)node;
    b.ip = [NSString stringWithCString:addrr encoding:NSUTF8StringEncoding];
    
    NSArray *keyValues = [d componentsSeparatedByString:@"\n"];
    BOOL extFound = false;
    for (NSString *s in keyValues)
    {
        if ([s hasPrefix: @"EXT:"] || [s hasPrefix: @"Ext:"])
        {
            extFound = true;
            continue;
        }
        
        if ([s hasPrefix: @"LOCATION:"] == true && extFound == true)
        {
            b.dialURL = [s substringFromIndex: 10];
            //NSLog(@"Found DIAL URL: %@", b.dialURL);
        }
    }
    
    if (nil != self.listener && extFound)
        [self.listener onFound:b];
}

// Thunk from C to Objective-C
static void readCallback(CFSocketRef s,CFSocketCallBackType type,CFDataRef address,const void *data,void *info)
{
//    return;
    SSDP * obj = (__bridge SSDP *) info;
//    assert([obj isKindOfClass:[SSDP class]]);
    
    if (0 == obj->socketRef) {
        NSLog(@"SSDP socket is zero, bailiing out");
        return;
    }
    
//#pragma unused(s)
//    assert(s == obj->socketRef);
#pragma unused(type)
    assert(type == kCFSocketReadCallBack);
#pragma unused(address)
    assert(address == nil);
#pragma unused(data)
    assert(data == nil);
    if ([obj isKindOfClass:[SSDP class]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [obj readData];
        });
    }
}

-(BOOL)isSocketOpen
{
    return isSocketOpen;
}

-(void)dealloc
{
    NSLog(@"Socket Dealloced");
}

- (void) timerEvent
{
    NSLog(@"SSDP timerEvent");
    
    if (nil != self.listener) [self.listener onFinished:self.count];
    [self close];
}

@end








