//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

// Adds a convenient interface to for implementing CoreData queries
// as methods.  To use, define a method for each query you would like
// to do, like so:
// 
// - (NSArray*) expensesBeforeDate:(NSDate*)date;
// - (Payee*) payeeNamed:(NSString*)name;
//
// to implement the methods, use the DEFINEARRAYQUERY and DEFINEOBJECTQUERY
// macros like so:
//
// - (NSArray*) expensesBeforeDate:(NSDate*)date
// { DEFINEARRAYQUERY(@"Expense", @"date <= %@", date); }
// - (Payee*) payeeNamed:(NSString*)name
// { DEFINEOBJECTQUERY(@"Payee", @"name == %@", name); }
//
// An array query is one that is permitted to return any number of values.
// An object query can only return one or zero values.  Should any
// error occur, or too many results be returned as the result of an object
// query, then an exception is thrown with name QUERYFAILUREEXCEPTION.
//
// These query methods replace CoreData stored queries, which seem to have
// bugs and cause unpredictable crashes.  
//
// TODO --- redefine the macros to be more efficient.  For example, they could
// cache the resulting NSFetchRequest objects.
//
// TODO --- the current macros require that an argument be given for args,
// even if none would otherwise be required for the query.  You can always provide
// nil, it does no harm, but it would be more elegant if none were needed.

#define QUERYFAILUREEXCEPTION @"QueryFailure"

#define DEFINEARRAYQUERY(entity,format,args...) \
return [self objectsOfEntityType:entity \
matchingPredicate:[NSPredicate predicateWithFormat:format, args]];
#define DEFINEOBJECTQUERY(entity,format,args...) \
return [self objectOfEntityType:entity \
matchingPredicate:[NSPredicate predicateWithFormat:format, args]];

@interface NSManagedObjectContext (Oaxaca2)

- (NSArray*)executeArrayQueryFromFetchRequest:(NSFetchRequest*)request;
- (NSArray*)allObjectsOfEntityType:(NSString*)entityType;
- objectOfEntityType:(NSString*)entityType; // only valid if there is exactly 1 object of this type
- objectOfEntityType:(NSString*)entityType matchingPredicate:(NSPredicate*)predicate;
- objectOfEntityType:(NSString*)entityType matchingPredicateFormat:(NSString*)predicate, ...;
- (NSArray*) objectsOfEntityType:(NSString*)entityType matchingPredicate:(NSPredicate*)predicate;
- (NSArray*) objectsOfEntityType:(NSString*)entityType matchingPredicateFormat:(NSString*)format, ...;

- (NSManagedObject*) createNewObjectForEntityForName:(NSString*)entName
                                   withValuesAndKeys:(id)firstValue, ...;

- (NSManagedObject*) createNewObjectForEntityForName:(NSString*)entName
                               copyingPropertiesFrom:(NSManagedObject*)fromObject;

- (NSManagedObject*) copyObject:(NSManagedObject*)object;
- (NSArray*) copyAllObjects:(NSArray*)objects;

// For each object of entitiy type "entName" in "fromCtx", invokes 
// createNewObjectForEntityForName:copyingPropertiesFrom: and returns the
// result in an array.
- (NSArray*) copyAllObjectsForEntityForName:(NSString*)entName
                                fromContext:(NSManagedObjectContext*)fromCtx;

@end

