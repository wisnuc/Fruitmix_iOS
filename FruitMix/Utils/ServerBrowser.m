//
//  ServerBrowser.m
//  PacketSending
//
//  Created by Jon Manning on 21/09/13.
//  Copyright (c) 2013 Secret Lab. All rights reserved.
//

#import "ServerBrowser.h"

@interface ServerBrowser () <NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
    NSNetServiceBrowser* _browser;
    NSNetService* _thisServer;
    NSMutableArray* _discoveredServers;
    NSMutableArray* _resolvedServers;
}
@end

@implementation ServerBrowser

- (id) initWithServerType:(NSString*)serverType port:(int16_t)port {
    self = [super init];
    if (self) {
        _serverType = serverType;
        _port = port;
        _discoveredServers = [NSMutableArray array];
        _resolvedServers = [NSMutableArray array];
        
        _browser = [[NSNetServiceBrowser alloc] init];
        _browser.delegate = self;
        [_browser searchForServicesOfType:_serverType inDomain:@""];
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    aNetService.delegate = self;
    [_discoveredServers addObject:aNetService];
    [aNetService resolveWithTimeout:2.0];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    [_resolvedServers addObject:sender];
    [self.delegate serverBrowserFoundService:sender];
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [_resolvedServers removeObject:sender];
    [_discoveredServers removeObject:sender];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    NSUInteger index = [_discoveredServers indexOfObject:aNetService];
    [_discoveredServers removeObject:aNetService];
    [_resolvedServers removeObject:aNetService];
    [self.delegate serverBrowserLostService:aNetService index:index];
}

- (void) createServer {
    NSAssert(self.serverType != nil, @"serverType cannot be nil");
    NSAssert([self.serverType isEqualToString:@""] == NO, @"serverType cannot be blank");
    NSAssert(self.port > 1024, @"port must be higher than 1024");
    NSAssert(_thisServer == nil, @"Cannot create a server when one is already published");
    
    _thisServer = [[NSNetService alloc] initWithDomain:@"" type:self.serverType name:@"" port:self.port];
    _thisServer.delegate = self;
    [_thisServer publish];
}

- (void) stopServer {
    [_thisServer stop];
    _thisServer = nil;
}

- (NSArray *)discoveredServers {
    // Return the list of servers that have been resolved
    return _resolvedServers;
}

- (BOOL)isRunningServer {
    return _thisServer != nil;
}

@end
