// Copyright (c) 2012 quicktigame2d project
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of the project nor the names of its contributors may be
//   used to endorse or promote products derived from this software without
//   specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
#import "ParticleDataReader.h"
#import <zlib.h>

@implementation ParticleDataReader

+ (NSData*)parseDataWithBase64EncodedString:(NSString *) string {
    return [self gzipInflate:[self dataWithBase64EncodedString:string]];
}

+ (NSData*)dataWithBase64EncodedString:(NSString *) string {
    NSMutableData *mutableData = nil;
    
    if( string ) {
        unsigned long ixtext = 0;
        unsigned long lentext = 0;
        unsigned char ch = 0;
        unsigned char inbuf[4], outbuf[3];
        short i = 0, ixinbuf = 0;
        BOOL flignore = NO;
        BOOL flendtext = NO;
        NSData *base64Data = nil;
        const unsigned char *base64Bytes = nil;
        
        // Convert the string to ASCII data.
        base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
        base64Bytes = [base64Data bytes];
        mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
        lentext = [base64Data length];
        
        while( YES ) {
            if( ixtext >= lentext ) break;
            ch = base64Bytes[ixtext++];
            flignore = NO;
            
            if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
            else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
            else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
            else if( ch == '+' ) ch = 62;
            else if( ch == '=' ) flendtext = YES;
            else if( ch == '/' ) ch = 63;
            else flignore = YES; 
            
            if( ! flignore ) {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if( flendtext ) {
                    if( ! ixinbuf ) break;
                    if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    ixinbuf = 3;
                    flbreak = YES;
                }
                
                inbuf [ixinbuf++] = ch;
                
                if( ixinbuf == 4 ) {
                    ixinbuf = 0;
                    outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                    outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                    outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                    
                    for( i = 0; i < ctcharsinbuf; i++ ) 
                        [mutableData appendBytes:&outbuf[i] length:1];
                }
                
                if( flbreak )  break;
            }
        }
    }
    
    return [[[NSData alloc] initWithData:mutableData] autorelease];
}

+ (NSData *)gzipInflate:(NSData*) data {
	if ([data length] == 0) return data;
	
	unsigned full_length = [data length];
	unsigned half_length = [data length] / 2;
	
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	strm.next_in = (Bytef *)[data bytes];
	strm.avail_in = [data length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
	while (!done) {
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd (&strm) != Z_OK) return nil;
	
	// Set real length.
	if (done) {
		[decompressed setLength: strm.total_out];
		return [NSData dataWithData: decompressed];
	}
	else return nil;
}


@end
