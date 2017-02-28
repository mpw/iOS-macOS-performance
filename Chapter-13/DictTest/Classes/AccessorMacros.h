/*
	Copyright (c) 2001-2012 by Marcel Weiher. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

	Redistributions of source code must retain the above copyright
	notice, this list of conditions and the following disclaimer.

	Redistributions in binary form must reproduce the above copyright
	notice, this list of conditions and the following disclaimer in
	the documentation and/or other materials provided with the distribution.

	Neither the name Marcel Weiher nor the names of contributors may
	be used to endorse or promote products derived from this software
	without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

*/

#ifndef ACCESSOR_MACROS
#define ACCESSOR_MACROS



//---	This file expands the accessor macros

#define newBool(x)	(x ? [[NSNumber numberWithBool:x] retain] : nil)
#define newInt(x)	[[NSNumber numberWithInt:x]  retain]
#define newChar(x)	[[NSNumber numberWithChar:x] retain]
#define makeBool(x)	(x ? [NSNumber numberWithBool:x] : nil)
#define makeInt(x)	[NSNumber numberWithInt:x]
#define makeChar(x)	[NSNumber numberWithChar:x]
#define toInt(x)	[x intValue]
#define toBool(x)	[x boolValue]
//#define toString(x)	[x stringValue]

#if !__has_feature(objc_arc)
#define ASSIGN_ID(var,value)\
    {\
        id tempValue=(value);\
	if ( tempValue!=var) {  \
        if ( tempValue!=(id)self ) \
            [tempValue retain]; \
		if ( var && var!=(id)self) \
			[var release]; \
		var = tempValue; \
	} \
    }
#else
#define ASSIGN_ID(var,value)    var=value
#endif

#ifndef AUTORELEASE
#if !__has_feature(objc_arc)
#define AUTORELEASE(x)  ([(x) autorelease])
#else
#define AUTORELEASE(x)  (x)
#endif
#endif


#define	setAccessor( type, var,setVar ) \
-(void)setVar:(type)newVar { \
    ASSIGN_ID(var,newVar)\
} \

#define readAccessorName( type, var , name )\
-(type)name						{	return var;			}

#define readAccessor( type, var )   readAccessorName( type, var, var )

#define relayReadAccessor( var, delegate ) \
-var\
{\
    if ( var ) {\
        return var;\
    } else {\
        return [delegate var];\
    }\
}\

#define objectAccessor( objectType, var, setVar ) \
    readAccessor( objectType*, var )\
    setAccessor( objectType*, var,setVar )

#define idAccessor( var, setVar )\
    readAccessor( id, var )\
    setAccessor( id, var,setVar )


#define relayAccessor( var, setVar, delegate )\
    relayReadAccessor( var , delegate )\
    setAccessor( id, var, setVar )

#define	idAccessor_h( var,setVar ) -(void)setVar:newVar; \
-var;

#define scalarAccessor( scalarType, var, setVar ) \
-(void)setVar:(scalarType)newVar	{	var=newVar;	} \
-(scalarType)var					{	return var;	} 
#define scalarAccessor_h( scalarType, var, setVar ) \
-(void)setVar:(scalarType)newVar; \
-(scalarType)var;

#define objectAccessor_h( objectType, var, setVar )   scalarAccessor_h( objectType*, var, setVar )

#define intAccessor( var, setVar )	scalarAccessor( int, var, setVar )
#define intAccessor_h( var, setVar )	scalarAccessor_h( int, var, setVar )
#define floatAccessor(var,setVar )  scalarAccessor( float, var, setVar )
#define floatAccessor_h(var,setVar )  scalarAccessor_h( float, var, setVar )
#define boolAccessor(var,setVar )  scalarAccessor( BOOL, var, setVar )
#define boolAccessor_h(var,setVar )  scalarAccessor_h( BOOL, var, setVar )

#define lazyAccessor( ltype, lvar ,setLVar, computeVar )   \
	readAccessorName( ltype*, lvar, _##lvar ) \
	setAccessor( ltype*, lvar, setLVar ) \
\
-(ltype*)lvar { \
    if ( ![self _##lvar] )  { \
      [self setLVar:[self computeVar]]; \
    }  \
	return [self _##lvar]; \
} \

#define slazyAccessor( ltype, lvar ,setLVar, computeVar )   \
readAccessorName( ltype*, lvar, _##lvar ) \
setAccessor( ltype*, lvar, setLVar ) \
\
-(ltype*)lvar { \
@synchronized( self ) { \
if ( ![self _##lvar] )  { \
[self setLVar:[self computeVar]]; \
}  \
} \
return [self _##lvar]; \
} \



#define dictAccessor( objectType, var, setVar, someDict ) \
    -(objectType*)var { return [someDict objectForKey:@""#var]; } \
    -(void)setVar:(objectType*)newValue { [someDict setObject:newValue forKey:@""#var]; } \

#define scalarDictAccessor( scalarType, var, setVar, someDict ) \
     -(scalarType)var { scalarType temp=0;  [[someDict objectForKey:@""#var] getValue:&temp]; return temp; }\
     -(void)setVar:(scalarType)newValue {  NSValue *temp=[NSValue valueWithBytes:&newValue objCType:@encode(scalarType)]; [someDict setObject:temp forKey:@""#var]; } \

#ifndef CONVENIENCE
#define CONVENIENCE( sel, initsel ) \
+(instancetype)sel { \
  return AUTORELEASE([[self alloc] initsel]); \
} 

#define SHORTCONVENIENCE( name, initsel )  CONVENIENCE( name##initsel , init##initsel )
#endif


//--- compatibility:

//#define	accessor	idAccessor
//#define accessor_h	idAccessor_h


//---- RETAIN/RELEASE Macros for GNUStep compatibility

#if __has_feature(objc_arc)
#define DEALLOC( x) \
-(void)dealloc { \
    x; \
}
#else
#define DEALLOC( x) \
-(oneway void)dealloc { \
    x; \
    [super dealloc]; \
}
#endif

#ifndef RETAIN
#if !__has_feature(objc_arc)
#define RETAIN(x)  ([(x) retain])
#else
#define RETAIN(x)   (x)
#endif
#endif

#ifndef RELEASE
#if !__has_feature(objc_arc)
#define RELEASE(x)  ([(x) release])
#else
#define RELEASE(x)
#endif
#endif


#ifndef DESTROY
#define DESTROY(x)  RELEASE(x)
#endif

#ifndef ASSIGN
#define ASSIGN(var,value) ASSIGN_ID(var,value)
#endif	

#ifndef ASSIGNCOPY
#define ASSIGNCOPY(var,value) ASSIGN(var,[(value) copy])
#endif


#endif
