#import <MPWXmlKit/MPWMAXParser.h>
#import <MPWXmlKit/MPWXmlParser.h>

@interface MedParser:NSObject 
{ 
	NSMutableString *content;
        NSMutableDictionary *dict;
	NSMutableArray *abstracts;
}

@property (retain,nonatomic) NSMutableString *content;
@property (retain,nonatomic) NSMutableDictionary *dict;
@property (retain,nonatomic) NSMutableArray *abstracts;

@end

@implementation MedParser

@synthesize content,dict,abstracts;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
   if ( [elementName isEqual:@"AbstractText"] ) {
       [self setContent:[NSMutableString string]];
   } else {
       [self setContent:nil];
   }
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
     if ( [elementName isEqual:@"Abstract"] ) {
     } else if ( [elementName isEqual:@"AbstractText"] ) {
         [abstracts addObject:content];
	   [self setContent:nil];
     } else if ( [elementName isEqual:@"Acronym"] ) {
     } else if ( [elementName isEqual:@"Affiliation"] ) {
     } else if ( [elementName isEqual:@"Agency"] ) {
     } else if ( [elementName isEqual:@"Article"] ) {
     } else if ( [elementName isEqual:@"ArticleTitle"] ) {
     } else if ( [elementName isEqual:@"Author"] ) {
     } else if ( [elementName isEqual:@"AuthorList"] ) {
     } else if ( [elementName isEqual:@"Chemical"] ) {
     }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [content appendString:string];
}

@end



int main(int argc, char *argv[] ) {
    id data,parser,medparser;
    [NSAutoreleasePool new];
    data = [NSData dataWithContentsOfMappedFile:[NSString stringWithUTF8String:argv[1]]];
    for (int i=0;i<1; i++) {
//    parser = [[MPWXmlParser alloc] initWithData:data];
    parser = [[NSXMLParser alloc] initWithData:data];
    medparser=[MedParser new];
    [medparser setDict:[NSMutableDictionary dictionary]];
    [medparser setAbstracts:[NSMutableArray array]];
    [parser setDelegate:medparser];
   printf("<enter> to start parsing:"); fflush(stdout); getchar();
//    printf("starting to parse...\n");
    [parser parse];
//    printf("finished <enter> to release"); fflush(stdout); getchar();
//    [parser release]; 
      NSLog(@"%d abstracts",[[medparser abstracts] count]);
    }
    printf("finished <enter> to quit"); fflush(stdout); getchar();
    return 0;
}

