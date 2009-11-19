//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxCoreData.h"
#import "OxDebug.h"
#import <stdarg.h>

@implementation NSManagedObjectContext (Oaxaca2)

static void throwQueryFailure(NSError* error)
{
    /* an error occurred */
    assert (error != nil);
    OxLog (@"Error occured in fetch: %@", error);
    @throw [NSException exceptionWithName:QUERYFAILUREEXCEPTION
                                   reason:[error description]
                                 userInfo:[NSDictionary 
                                           dictionaryWithObject:error
                                           forKey:@"error"]];
}

- (NSArray*)executeArrayQueryFromFetchRequest:(NSFetchRequest*)fetchRequest
{
    OxIndented(@"executeArrayQueryFromFetchRequest: %@", fetchRequest) {
        NSManagedObjectContext *mctx = self;
        NSError *error = nil;
        NSArray *array = [mctx executeFetchRequest:fetchRequest 
                                             error:&error];
        if (array == nil) {
            /* an error occurred */
            throwQueryFailure(error);
        }
        return array;
    } OxUndented;
    return nil; // can't get here
}    

- (NSArray*) allObjectsOfEntityType:(NSString*)entityType
{
    NSManagedObjectContext *moc = self;
    NSEntityDescription *entityDescription = 
    [NSEntityDescription entityForName:entityType
                inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    if (array == nil) {
        throwQueryFailure(error);
    }
    
    return array;
}

- objectOfEntityType:(NSString*)entityType
{
    NSArray *array = [self allObjectsOfEntityType:entityType];
    if ([array count] > 1) {
        @throw [NSException exceptionWithName:QUERYFAILUREEXCEPTION
                                       reason:@"Too many results"
                                     userInfo:nil];
    }
    else if ([array count] == 1)
        return [array objectAtIndex:0];
    else
        return nil;    
}

- objectOfEntityType:(NSString*)entityType matchingPredicate:(NSPredicate*)predicate
{
    NSArray *array = [self objectsOfEntityType:entityType matchingPredicate:predicate];
    if ([array count] > 1) {
        @throw [NSException exceptionWithName:QUERYFAILUREEXCEPTION
                                       reason:@"Too many results"
                                     userInfo:nil];
    }
    else if ([array count] == 1)
        return [array objectAtIndex:0];
    else
        return nil;    
}

- objectOfEntityType:(NSString*)entityType matchingPredicateFormat:(NSString*)format, ...
{
    va_list ap;
    
    va_start(ap, format);    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:ap];    
    va_end(ap);
    
    return [self objectOfEntityType:entityType matchingPredicate:predicate];
}

- (NSArray*) objectsOfEntityType:(NSString*)entityType matchingPredicate:(NSPredicate*)predicate
{
    NSManagedObjectContext *moc = self;
    NSEntityDescription *entityDescription = 
    [NSEntityDescription entityForName:entityType
                inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
        throwQueryFailure(error);
    return array;
}

- (NSArray*) objectsOfEntityType:(NSString*)entityType matchingPredicateFormat:(NSString*)format, ...
{
    va_list ap;
    
    va_start(ap, format);    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:ap];    
    va_end(ap);
    
    return [self objectsOfEntityType:entityType matchingPredicate:predicate];
}

- (NSManagedObject*) createNewObjectForEntityForName:(NSString*)entName
                                   withValuesAndKeys:(id)firstValue, ...
{
    NSManagedObject *res = [NSEntityDescription insertNewObjectForEntityForName:entName 
                                                         inManagedObjectContext:self];
    va_list ap;
    
    va_start(ap, firstValue);
    id value = firstValue;
    while (value != nil) {
        id key = va_arg(ap, id);
        [res setValue:value forKey:key];
        value = va_arg(ap, id);
    }
    va_end(ap);
    
    return res;
}

- (NSManagedObject*) createNewObjectForEntityForName:(NSString*)entName
                               copyingPropertiesFrom:(NSManagedObject*)fromObject
{
    NSManagedObject *res = [NSEntityDescription insertNewObjectForEntityForName:entName 
                                                         inManagedObjectContext:self];
    NSDictionary *toProps = [[res entity] propertiesByName];
    NSEntityDescription *fromEnt = [fromObject entity];
    Class attrDesc = [NSAttributeDescription class];
    for (NSPropertyDescription *prop in [fromEnt properties]) {
        if (![prop isMemberOfClass:attrDesc])
            continue; // only attributes
        NSString *propName = [prop name];
        
        // n.b.: if there is no such property, then objectForKey: will return
        // nil, which will yield false when sent the isMemberOfClass message.
        if (![[toProps objectForKey:propName] isMemberOfClass:attrDesc])
            continue;
        id propValue = [fromObject valueForKey:propName];
        [res setValue:propValue forKey:propName];
    }
    
    return res;
}

- (NSArray*) copyAllObjectsForEntityForName:(NSString*)entName
                                fromContext:(NSManagedObjectContext*)fromCtx
{
    NSMutableArray *res = [NSMutableArray array];
    for (NSManagedObject *obj in [fromCtx allObjectsOfEntityType:entName]) {
        NSManagedObject *copiedObj = [self createNewObjectForEntityForName:entName
                                                     copyingPropertiesFrom:obj];
        if (obj) {
            [res addObject:copiedObj];
        }
    }
    return res;
}

- (NSManagedObject*) copyObject:(NSManagedObject*)object
{
    NSString *entName = [[object entity] name];
    return [self createNewObjectForEntityForName:entName copyingPropertiesFrom:object];
}

- (NSArray*) copyAllObjects:(NSArray*)objects
{
    NSManagedObjectModel *model = [[self persistentStoreCoordinator] managedObjectModel];
    NSDictionary *entities = [model entitiesByName];
    NSMutableArray *res = [NSMutableArray array];
    for (NSManagedObject * obj in objects) {
        NSString *entName = [[obj entity] name];
        if ([entities objectForKey:entName]) {
            NSManagedObject *copiedObj = [self createNewObjectForEntityForName:entName
                                                         copyingPropertiesFrom:obj];
            if (copiedObj) [res addObject:copiedObj];
        }
    }
    return res;
}

@end
