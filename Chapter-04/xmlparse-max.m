#import <MPWXmlKit/MPWMAXParser.h>

@interface MedParser:NSObject 
{
    NSMutableArray *abstracts;
}

@property (retain,nonatomic) NSMutableArray *abstracts;

@end

@implementation MedParser

@synthesize abstracts;

-defaultElement:elements attributes:attrs parser:parser
{
   return nil;
}

-AbstractTextElement:elements attributes:attrs parser:parser
{
   id text = [elements combinedText];
   [abstracts addObject:text ? text : @""];   
   return nil;
}

@end

static NSString *attrs[]={

@"CitedMedium",
@"CompleteYN",
@"DateType",
@"EIdType",
@"IssnType",
@"Label",
@"MajorTopicYN",
@"Owner",
@"PubModel",
@"RefType",
@"Source",
@"Type",
@"ValidYN",
@"Version",
@"version",
nil
};

static NSString *tags[]={
@"Abstract",
@"AbstractText",
@"Acronym",
@"Affiliation",
@"Agency",
@"Article",
@"ArticleTitle",
@"Author",
@"AuthorList",
@"Chemical",
@"ChemicalList",
@"CitationSubset",
@"CommentsCorrections",
@"CommentsCorrectionsList",
@"CopyrightInformation",
@"Country",
@"DateCompleted",
@"DateCreated",
@"DateRevised",
@"Day",
@"DescriptorName",
@"ForeName",
@"Grant",
@"GrantID",
@"GrantList",
@"ISOAbbreviation",
@"ISSN",
@"ISSNLinking",
@"Initials",
@"Issue",
@"Journal",
@"JournalIssue",
@"Language",
@"LastName",
@"MedlineCitation",
@"MedlineJournalInfo",
@"MedlinePgn",
@"MedlineTA",
@"MeshHeading",
@"MeshHeadingList",
@"Month",
@"NameOfSubstance",
@"NlmUniqueID",
@"NumberOfReferences",
@"PMID",
@"Pagination",
@"PubDate",
@"PublicationType",
@"PublicationTypeList",
@"QualifierName",
@"RefSource",
@"RegistryNumber",
@"Suffix",
@"Title",
@"Volume",
@"Year",
nil};




int main(int argc, char *argv[] ) {
    id data,parser,medparser;
    [NSAutoreleasePool new];
    data = [NSData dataWithContentsOfMappedFile:[NSString stringWithUTF8String:argv[1]]];
    parser = [MPWMAXParser parser]; 
    medparser=[MedParser new];
    [medparser setAbstracts:[NSMutableArray array]];
    [parser setUndefinedTagAction:MAX_ACTION_NONE];
   [parser setHandler:medparser forElements:[NSArray arrayWithObjects:tags count:56] inNamespace:nil prefix:@"" map:nil];
   [parser declareAttributes:[NSArray arrayWithObjects:attrs count:13] inNamespace:nil];
    [parser setAutotranslateUTF8:NO];
    printf("<enter> to start parsing:"); getchar();
    for (int i=0;i<1;i++) {
	[parser parse:data];
    }
    NSLog(@"%d abstracts",[[medparser abstracts] count]);

    return 0;
}

