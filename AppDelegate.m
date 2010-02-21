#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "NSManagedObjectContext+Additions.h"
#import "Account+Logic.h"
#import "Project+Logic.h"
#import "Status+Logic.h"
#import "Entry+Logic.h"
#import "Put.h"
#import "Propfind.h"
#import "Keychain.h"
#import "Report.h"
#import "ProxyAccount.h"
#import "Task+Logic.h"
#import "MessageToken.h"
#import "NSArray+Utils.h"
#import "MessageTokenTransformer.h"

#define kAnimationKey @"transitionViewAnimation"

@implementation AppDelegate

@synthesize preferencesWindow, extraPanel, accountController, projectsController, statusItem, nameMenuField;
@synthesize tableView, putTimer,  status, runningPutRequests, statusController, startedAt;
@synthesize visibleCalendarsController, proxyAccountsController, oldProxyAccounts, connectionProblems, proxyAccountsNotFound;
@synthesize messageExpression, messageExpressionTemplates, highlightedMenuItem, hasConnectivity;

static NSString *PropertyObservationContext;
static NSString *ProxyAccountsObservationContext;
static NSString *StatusObservationContext;
static NSString* CheckConnectionContext;
static NSString* LoadProxyAccountsContext;
static NSString* PutEntryContext;
static NSString* HasConnectivityContext;

typedef enum {
    
    START_STOP_TAG = 1,
    PREFERENCES_TAG= 2,
    ICAL_TAG       = 3,
    QUIT_TAG       = 4,
    EDIT_EXTRAS_TAG= 5,
    STOPWATCH_TAG  = 6,
    NO_PROJECTS_TAG= 7

    
} MENU_TAG;

#pragma mark CoreData

+ (void) initialize {
    
    MessageTokenTransformer* mtt = [[[MessageTokenTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer:mtt forName:@"MessageTokenTransformer"];
}

/**
 * Returns the support directory for the application, used to store the Core Data
 * store file.  This code uses a directory named "ZiGT" for
 * the content, either in the NSApplicationSupportDirectory location or (if the
 * former cannot be found), the system's temporary directory.
 */
- (NSString *)applicationSupportDirectory {
    
    NSArray  *paths   = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath= ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:APPLICATION_SUPPORT_FOLDERNAME];
}

/** 
 * Creates, retains, and returns the managed object model for the application 
 * by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if( !self->managedObjectModel )        
        self->managedObjectModel= [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
	
    return self->managedObjectModel;
}

/**
 * Returns the persistent store coordinator for the application.  This 
 * implementation will create and return a coordinator, having added the 
 * store for the application to it.  (The directory for the store is created, 
 * if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    
    if( !self->persistentStoreCoordinator )  {
        
        NSFileManager*  fileManager                = [NSFileManager defaultManager];
        NSString*       applicationSupportDirectory= [self applicationSupportDirectory];
        NSError*        error                      = nil;
        NSURL*          url                        = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: DATA_FILENAME]];
        
        if( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] )         
            [fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        
        self->persistentStoreCoordinator= [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];        
        [self->persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error];
    } // if 
    
    return self->persistentStoreCoordinator;
}

/**
 * Returns the managed object context for the application (which is already
 * bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if( !self->managedObjectContext ) {
        
        self->managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self->managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    } // if 
    
    return self->managedObjectContext;
}

/**
 * Returns the NSUndoManager for the application.  In this case, the manager
 * returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    
    return [self.managedObjectContext undoManager];
}

/**
 * Implementation of the applicationShouldTerminate: method, used here to
 * handle the saving of changes in the application managed object context
 * before the application terminates.
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error = nil;

    [self stopRecording:self];
    [self.putTimer invalidate];
    
    self.status.finishedNormaly= [NSNumber numberWithBool:YES];
    
    [self.managedObjectContext commitEditing];
    [self.managedObjectContext save:&error];
    
    return NSTerminateNow;
}

#pragma mark Initialisierung

/**
 * Initialisierung der Applikation. Beim ersten Laden wird ein leerer Account angelegt. Ansonsten wird dieser geladen.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    self.runningPutRequests= [NSMutableSet set];
    
    // Account ggf. erzeugen
    Account* acc= (Account*)[self.managedObjectContext firstMOForEntityNamed:@"Account"];
    if( !acc )         
        acc= [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.managedObjectContext];    
    
    [self.accountController setContent:acc];
    
    // Status ggf. erzeugen
    self.status= (Status*)[self.managedObjectContext firstMOForEntityNamed:@"Status"];
    if( !self.status )        
        self.status= [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    
    [self.statusController setContent:self.status];
    
    [self.status stop];
    
    [Task prepareStandardTasks:self.managedObjectContext];
    
    if( ![self.status.finishedNormaly boolValue] ) {
        
        Entry* currentEntry= self.status.entry;
        if( currentEntry ) {
            
            [self.managedObjectContext deleteObject:currentEntry];
        } // if
        
    } // if 

    self.status.finishedNormaly= [NSNumber numberWithBool:NO];

    [self saveAction:self];

    // ggfs. Password aus dem Keychain lesen
    if( acc.username ) 
        acc.password= [[Keychain defaultKeychain] passwordForGenericService:KEYCHAIN_SERVICE_NAME forAccount:acc.username];
    
    // Status-Menü einblenden
    self.statusItem= [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [self.statusItem setHighlightMode:YES];     
    [self updateStatusMenu];
    
    // Key-Value-Observing
    [self addObserver:self forKeyPath:@"status.state" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&StatusObservationContext];
    [self addObserver:self forKeyPath:@"hasConnectivity" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&HasConnectivityContext];
    
    self.oldProxyAccounts= [NSMutableArray array];
    [self.proxyAccountsController addObserver:self forKeyPath:@"arrangedObjects" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&ProxyAccountsObservationContext];
    [self startObservingProxyAccounts:self.proxyAccountsController.arrangedObjects];
    
    // Put-Timer starten
    self.putTimer= [NSTimer scheduledTimerWithTimeInterval:[self.status.pushToServerTimeinterval intValue]*60 target:self selector:@selector(putTimerFired:) userInfo:nil repeats:YES];

    [self checkConnection:self];
    
    [self.messageExpression setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"^"]];
    [self.messageExpressionTemplates setObjectValue:[MessageToken possibleMessageTokens]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidSendAction:)
                                                 name:NSMenuDidSendActionNotification object:nil];
}

#pragma mark TabView-Delegate

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    
    [self.managedObjectContext commitEditing];
    if( [[tabViewItem identifier] isEqualToString:PROXY_TAB_VIEW] ) {
        
        [self refreshProxyAccounts:self];
    } // if 
    else if( [[tabViewItem identifier] isEqualToString:PROJECT_TAB_VIEW] ) {

        [self.visibleCalendarsController prepareContent];
    } // if 
}

- (void)proxiesFound:(Report*) reportRequest {
    
    Account* acc= [self.accountController content];
    [acc mergeProxies:reportRequest.proxies];
    [self saveAction:self];
    
    for( ProxyAccount* pa in acc.proxyAccounts ) {
        
        Propfind* pf= [[[Propfind alloc] initWithAccount:acc forGUID:pa.guid delegate:pa context:NULL] autorelease];
        [pf run];
    } // for 

    if( reportRequest.context == &LoadProxyAccountsContext ) {
        
        [[self.proxyAccountsNotFound animator] setAlphaValue:0];
        [self.proxyAccountsNotFound setToolTip:nil];
    } // if 
    
    [reportRequest release];
}

- (void)proxiesNotFound:(Report*) reportRequest {
    
    if( reportRequest.context == &LoadProxyAccountsContext ) {
        
        [[self.proxyAccountsNotFound animator] setAlphaValue:1];
        [self.proxyAccountsNotFound setToolTip:@"Keine Stellvertreter gefunden!"];
    } // if 

    [reportRequest release];
}

#pragma mark Window-Delegate
/**
 * Ein Fenster wird geschlossen.
 */
- (void)windowWillClose:(NSNotification *)notification {
    
    // Ist es das Einstellungsfenster, dann werden die Tags der Projekte aktualisiert.
    if( [notification object] == self.preferencesWindow ) {
        
        NSInteger index= 10;
        for( Project* p in [self.managedObjectContext allMOsForEntityNamed:@"Project"] ) {                        
            p.tag= [NSNumber numberWithInt:index];
            index+= 1;
        } // for 
                
        [self.managedObjectContext commitEditing];
        
        if( [self.status isRunning] ) {
            
            if( !self.status.entry ) {
                [self.status stop];
            } // if 
        } // if 
        
        [self saveAction:self];

        Account* acc= self.accountController.content;     
        if( acc.username && acc.password ) 
            [[Keychain defaultKeychain] addGenericPassword:acc.password onService:KEYCHAIN_SERVICE_NAME forAccount:acc.username replaceExisting:YES];
        else
            if( acc.username )
                [[Keychain defaultKeychain] deletePasswordForGenericService:KEYCHAIN_SERVICE_NAME forAccount:acc.username];
        
        // Menü wird aktualisiert.
        [self updateStatusMenu];

        [self.putTimer invalidate];
        self.putTimer= [NSTimer scheduledTimerWithTimeInterval:[self.status.pushToServerTimeinterval intValue] * 60 target:self selector:@selector(putTimerFired:) userInfo:nil repeats:YES];

    } // if
}

#pragma mark MenuItem-Delegate
/**
 * Aktualisierung des Status-Menüs. Wenn das Einstellungsfenster auf ist,
 * werden bis auf Quit alle Einträge ausgeblendet.
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    
    BOOL result= YES;
    
    if( [self isWindowOpen] ) {
        
        result= [menuItem tag] == QUIT_TAG;

        if( [menuItem tag] == STOPWATCH_TAG ) {
            
            if( [self.status isRunning]  ) {
                
                [menuItem setTitle: [self.status.entry timeIntervalDescription:nil]];
            } // if 
            else {
                
                [menuItem setTitle: NSLocalizedString( @"Durcation 00:00:00", @"StopWatch" )];                    
            } // else 
        } // if 
        
    } // if 
    else {
        
        if( [menuItem tag] == START_STOP_TAG ) {
            
            if( [self.status isRunning] ) {
                
                [menuItem setTitle:NSLocalizedString( @"Stop", @"Stops current project" )];
                [menuItem setAction:@selector(stopRecording:)];        
                result= YES;
            } // if 
            else {
                    result= NO;           
                } // else
        } // if     
        else
            if( [menuItem tag] == EDIT_EXTRAS_TAG ) {
                result= [self.status isRunning];
            } // if 
        else {
            if( [menuItem tag] == STOPWATCH_TAG ) {
                
                if( [self.status isRunning]  ) {
                    
                    [menuItem setTitle: [self.status.entry timeIntervalDescription:nil]];
                } // if 
                else {
                    [menuItem setTitle: NSLocalizedString( @"Durcation 00:00:00", @"StopWatch" )];                    
                } // else 
                result= NO;
            } // if 
        }
        
        id object= [menuItem representedObject];        
        if( object ) {
            
            if( [object isKindOfClass:[Project class]] ) {
                Project* p= (Project*)object;
                [menuItem setState: (self.status.currentProject == p)? NSOnState : NSOffState];                
            } // if
            else 
            if( [object isKindOfClass:[Task class]] ) {
                
                Task* t= (Task*)object;
                Project* p= [[(NSMenuItem*)menuItem parentItem] representedObject];
                [menuItem setState:( self.status.currentProject == p && self.status.currentTask == t) ? NSOnState:NSOffState];
            } // if 
        } // if 
        
    } // else
    

    return result;
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)menuItem {

    if( self.highlightedMenuItem ) {
        
        Task* t= [self.highlightedMenuItem representedObject];        
        [self.highlightedMenuItem setImage:[t menuItemImage]];
        self.highlightedMenuItem= nil;
    } // if

    if( [menuItem representedObject] ) {
        
        if( [[menuItem representedObject] isKindOfClass:[Task class]] ) {
            
            Task* t= [menuItem representedObject];        
            
            [menuItem setImage:[t highlightedMenuItemImage]];    
            self.highlightedMenuItem= menuItem;
        } // if 
    } // if     
}

- (void)menuDidSendAction:(NSNotification*)notification {
    
    [self menu:nil willHighlightItem:nil];
}

# pragma mark IBActions

/**
 * Performs the save action for the application, which is to send the save:
 * message to the application's managed object context.  Any encountered errors
 * are presented to the user.
 */
- (IBAction) saveAction:(id)sender {
    
    NSError *error = nil;    
    [self.managedObjectContext commitEditing];
    [self.managedObjectContext save:&error];    
}

/**
 * Fügt ein neues Projekt hinzu und aktiviert automatisch das Feld für den Namen.
 */
- (IBAction)addProject:(id)sender {
    
    [self.projectsController add:sender];    
    [self performSelector:@selector(scrollTableView:) withObject:nil afterDelay:0];
}

/**
 * Scroll zum neuen Projekt.
 */
- (void)scrollTableView:(id)sender {
    
    NSUInteger selectedRow = [self.projectsController selectionIndex];
	if( selectedRow > 0 && selectedRow != NSNotFound )        
		[self.tableView scrollRowToVisible:selectedRow];
    
    [self.nameMenuField becomeFirstResponder];
}

/**
 * Öffne das Einstellungsfenster
 */
- (IBAction)showPreferences:sender {
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.preferencesWindow center];
    [self.preferencesWindow makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication] arrangeInFront:self];
}

/**
 * Aufzeichnung wird gestoppt.
 */
- (IBAction)stopRecording:sender {
    
    [self.status stop];
        
    Entry* theEntry= self.status.entry;
    
    if( theEntry ) {

        if( [[NSDate date] timeIntervalSinceDate:self.startedAt] >= [self.status.minTimeinterval intValue] * 60 || YES ) {            
            
            [self.status.currentProject stop:theEntry];            
            if( [self.status.rounding boolValue] ) {                
                
                NSInteger minutes= [self.status.minTimeinterval intValue];
                [theEntry roundStartedAtBy:minutes];
                [theEntry roundFinishedAtBy:minutes];
            } // if                         
            NSLog( @"Eintrag %@ gespeichert", theEntry );
        } // if
        else {
            NSLog( @"Zeitinterval ist zu klein %f", theEntry.timeInterval );
            [self.managedObjectContext deleteObject:theEntry];
        } // else
        
        self.status.entry= nil;
    } // if 
    
    [self saveAction:self];                    
}

/**
 * leere Action
 */
- (IBAction)noop:(id)sender {
    
}

/**
 * iCal starten
 */
- (IBAction)launchIcal:(id)sender {
    
    [[NSWorkspace sharedWorkspace] launchApplication:ICAL_APPLICATION_NAME];
}

/**
 * Projekt wird gewechselt.
 */
- (IBAction)changeProject:sender {
    
    [self stopRecording:self];
    
    if( sender ) {
        
        Task* t= [(NSMenuItem*)sender representedObject];
        Project* p= [[(NSMenuItem*)sender parentItem] representedObject];
        if( p ) {
            
            self.startedAt= [NSDate date];
            [self.status startProject:p withTask:t];
            [self saveAction:self];
        } // if 
    }
}

- (IBAction)editExtras:(id)sender {
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.extraPanel center];
    [self.extraPanel makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication] arrangeInFront:self];
}

- (IBAction)continueChange:(id)sender {
    
    [self.extraPanel close];
    [self saveAction:self];                    
}

- (IBAction)cancelChange:(id)sender {
    
    [self.extraPanel close];
    [self.managedObjectContext rollback];
}

/**
 * Überprüft die Verbindungsdaten mit einem Request.
 */
- (IBAction)checkConnection:(id)sender {
        
    [self.managedObjectContext commitEditing];
    Account* acc= self.accountController.content;
    Propfind* propfind= [[[Propfind alloc] initWithAccount:acc forGUID:acc.username delegate:self context:&CheckConnectionContext] autorelease];
    [propfind run];    
}

- (void)calendarsNotFound:(Propfind*)reportRequest {
        
    if( reportRequest.context == &CheckConnectionContext ) {
        
        self.hasConnectivity= NO;
        [[self.connectionProblems animator] setAlphaValue:1];
    }
}

- (void)calendarsFound:(Propfind*) reportRequest {
    
    if( reportRequest.context == &CheckConnectionContext ) {
        
        self.hasConnectivity= YES;
        [[self.connectionProblems animator] setAlphaValue:0];
    }
}

/**
 * Synchronisation starten
 */
- (IBAction)pushAction:(id)sender {
    
    // nach Datum sortieren...
    NSArray*         entries= [Entry unstoredWithContext:self.managedObjectContext];        
    for( Entry* e in entries ) {
        
        if( [e hasConnectivity] ) {
            
            Put* putRequest= [Put putWithAccount:[self.accountController content] delegate:self event:e context:&PutEntryContext];
            if( ![self.runningPutRequests containsObject:putRequest] ) {
                
                [self.runningPutRequests addObject:putRequest];
                [putRequest run];        
                e.stored= [NSNumber numberWithBool:YES];
            } // if 
            // maximal drei Requests auf einmal
            if( [self.runningPutRequests count] > 2 ) {
                break;
            } // if 
        } // if 
    } // for 
    
    if( [self.status isRunning] ) {
        
        if( [self.status.entry hasConnectivity] ) {
            Put* putRequest= [Put putWithAccount:[self.accountController content] delegate:self event:self.status.entry context:&PutEntryContext];
            if( ![self.runningPutRequests containsObject:putRequest] ) {
                putRequest.recordEvent= YES;
                [self.runningPutRequests addObject:putRequest];
                [putRequest run];                    
            } // if 
        } // if 
    } // if 
    
    [self saveAction:self];
}

/**
 * Proxy-Accounts werden aktualisiert.
 */
- (IBAction)refreshProxyAccounts:(id)sender {
    
    Report* report= [[Report alloc] initWithAccount:self.accountController.content delegate:self context:&LoadProxyAccountsContext];
    [report run];    
}

# pragma mark misc

- (NSMenu *)taskMenu {
    
    NSMenu     *result= [[NSMenu alloc] initWithTitle:@"TaskMenu"];    
    NSMenuItem *item;
    
    NSArray* tasks= [Task tasks:self.managedObjectContext];
    for( Task* t in tasks ) {
        
        item= [[NSMenuItem alloc] initWithTitle:t.displayName action:NULL keyEquivalent:@""];    
        
        [item setRepresentedObject:t];
        [item setTarget:self];
        [item setAction:@selector(changeProject:)];
        [item setImage:[t menuItemImage]];    
        [result addItem:item];
        [item release];     
    } // if 
    
    [result setDelegate:self];
    return [result autorelease];
}


/**
 * Liefert das Menü zurück.
 */
- (NSMenu *)menu {
    
    // das Menü wird hier konstruiert...
    NSMenu     *result= [[NSMenu alloc] initWithTitle:@"ZiGT"];    
    NSMenuItem *item= [[NSMenuItem alloc] initWithTitle:NSLocalizedString( @"Start", @"Starts current project" ) action:NULL keyEquivalent:@""];
    
    [item setAction:@selector(noop:)];
    [item setTag:START_STOP_TAG];
    [item setTarget:self];
    [result addItem:item];
    [item release];
    
    item= [[NSMenuItem alloc] initWithTitle:NSLocalizedString( @"Edit extra info", @"Edits the extra information for the current project." ) action:NULL keyEquivalent:@""];    
    [item setTarget:self];
    [item setAction:@selector(editExtras:)];
    [item setTag:EDIT_EXTRAS_TAG];
    [result addItem:item];
    [item release];
    
    [result addItem:[NSMenuItem separatorItem]];

    item= [[NSMenuItem alloc] initWithTitle:NSLocalizedString( @"00:00:00", @"StopWatch" ) action:NULL keyEquivalent:@""];    
    [item setTarget:self];
    [item setAction:@selector(noop:)];
    [item setTag:STOPWATCH_TAG];
    [result addItem:item];
    [item release];
    
    [result addItem:[NSMenuItem separatorItem]];
    
    NSArray* projects= [Project projectsContext:self.managedObjectContext];
    for( Project* p in projects ) {
        
        NSString *menuName= p.menuName;
        if( !menuName )
            menuName= NSLocalizedString( @"No name", @"Current project has no name for the menu." );
        
        item= [[NSMenuItem alloc] initWithTitle:menuName action:NULL keyEquivalent:@""];    
        
        [item setRepresentedObject:p];
        [item setSubmenu:[self taskMenu]];
        [item setTarget:self];
        [item setAction:@selector(noop:)];
        [item setState:[p.active boolValue] ? NSOnState : NSOffState ];
        [result addItem:item];
        [item release];     
    } // if 
    
    if( [projects count] == 0 ) {
        
        item= [[NSMenuItem alloc] initWithTitle:NSLocalizedString( @"No projects defined.", @"There are no projects defined so far." ) action:NULL keyEquivalent:@""];    
        [item setEnabled:NO];
        [item setTag:NO_PROJECTS_TAG];
        [result addItem:item];
        [item release];     
    } // if 
    
    [result addItem:[NSMenuItem separatorItem]];
    
    item= [[NSMenuItem alloc] initWithTitle:NSLocalizedString( @"Preferences...", @"Shows the preferences." )  action:NULL keyEquivalent:@""];    
    [item setTarget:self];
    [item setAction:@selector(showPreferences:)];
    [item setTag:PREFERENCES_TAG];
    [result addItem:item];
    [item release];
    
    item= [[NSMenuItem alloc] initWithTitle:NSLocalizedString( @"Open iCal", @"Opens the iCal application." )  action:NULL keyEquivalent:@""];    
    [item setTarget:self];
    [item setAction:@selector(launchIcal:)];
    [item setTag:ICAL_TAG];
    [result addItem:item];
    [item release];
    
    item= [[NSMenuItem alloc] initWithTitle:NSLocalizedString( @"Quit", @"Quits the application." )  action:NULL keyEquivalent:@""];    
    [item setTarget:self];
    [item setAction:@selector(terminate:)];
    [item setTag:QUIT_TAG];
    [result addItem:item];
    [item release];
    
    [result setAutoenablesItems:YES];
    [result setDelegate:self];
    return [result autorelease];
}


/**
 * Applikation beenden
 */
-(IBAction)terminate:(id)sender {
    
    [[NSApplication sharedApplication] terminate:self];
}

/**
 * Aktualisiert den Inhalt das Status-Menü
 */
- (void)updateStatusMenu {
    
    [self.statusItem setMenu:[self menu]];
    [self updateStatusBar];
}

/**
 * Ist das Einstellungsfenster offen?
 */
- (BOOL)isPreferencesWindowOpen {
    
    return [self.preferencesWindow isVisible];
}

/**
 * Ist das Einstellungsfenster offen?
 */
- (BOOL)isWindowOpen {
    
    return [self.preferencesWindow isVisible] || [self.extraPanel isVisible];
}

/**
 * Aktualisiert je nach Status den updateStatusBar
 */
- (void)updateStatusBar {
    
    if( [self.status isRunning] ) {
        
        [self.statusItem setTitle: @""];
        [self.statusItem setImage: [self.status image:NO hasConnectivity:self.hasConnectivity]];
        [self.statusItem setAlternateImage:[self.status image:YES hasConnectivity:self.hasConnectivity]];
    } // if
    else {
        
        [self.statusItem setTitle: @""];
        [self.statusItem setImage: [NSImage imageNamed:@"statusmenu"]];
        [self.statusItem setAlternateImage:[NSImage imageNamed:@"statusmenu_hl"]];
    } // else 
}


/**
 * Zeitanzeige aktualisieren...
 */
- (void)timerFired:(NSTimer*)timer {
    
    // [self updateStatusBar];
}

/**
 * Events zum Server übertragen...
 */
- (void)putTimerFired:(NSTimer*)timer {
    
    if( ![self isWindowOpen] ) {
        
        [self pushAction:timer];
    } // if 
}

/**
 * Bei erfolgreicher Übertragen können wir die Einträge entfernen.
 */
- (void)calendarStored:(Put*) putRequest  {
    
    NSLog( @"Event %@ stored", putRequest.event );    
    if( ![putRequest isRecordEvent] ) {
        [self.managedObjectContext deleteObject:putRequest.event];
        [self saveAction:self];
    } // if 
    
    [self.runningPutRequests removeObject:putRequest];    
    self.hasConnectivity= YES;
}

/**
 * Ansonsten versuchen wir es beim nächsten Mal wieder.
 */
- (void)calendarFailed:(Put*) putRequest {
    
    NSLog( @"Event %@ failed", putRequest.event );
    if( ![putRequest isRecordEvent] ) {
        
        putRequest.event.stored= [NSNumber numberWithBool:NO];
        [self saveAction:self];
    } // if 
    
    [self.runningPutRequests removeObject:putRequest];
    self.hasConnectivity= NO;
}

/**
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    
    if (context == &ProxyAccountsObservationContext) {
        
		/*
		 Should be able to use
		 NSArray *oldGraphics = [change objectForKey:NSKeyValueChangeOldKey];
		 etc. but the dictionary doesn't contain old and new arrays.
		 */
		NSArray* newProxies = [object valueForKeyPath:@"arrangedObjects"];
		
		NSMutableArray* onlyNew = [newProxies mutableCopy];
		[onlyNew removeObjectsInArray:self.oldProxyAccounts];
		[self startObservingProxyAccounts:onlyNew];
		
		NSMutableArray *removed = [self.oldProxyAccounts mutableCopy];
		[removed removeObjectsInArray:newProxies];
		[self stopObservingProxyAccounts:removed];
		
        self.oldProxyAccounts= newProxies;
    }
	else
	if (context == &PropertyObservationContext) {
        
        [Project syncCalendarsFromProxy:object managedObjectContext:self.managedObjectContext];
	} // if 
    else
    if( context == &StatusObservationContext || context == &HasConnectivityContext ) {

        [self updateStatusBar];
    } // if 
    
}

/**
 * Vordefinierte Sortierung
 */
- (NSArray*)calendarSortDescriptors {
    
    static NSArray* _calendarSortDescriptors;
    if( !_calendarSortDescriptors ) {
        
        NSSortDescriptor* result= [[[NSSortDescriptor alloc] initWithKey:@"fullname" ascending:YES] autorelease];
        _calendarSortDescriptors= [[NSArray arrayWithObject:result] retain];
    } // if
    
    return _calendarSortDescriptors;
}

- (NSArray*)taskSortDescriptors {
    
    static NSArray* _taskSortDescriptors;
    if( !_taskSortDescriptors ) {
        
        NSSortDescriptor* result= [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
        _taskSortDescriptors= [[NSArray arrayWithObject:result] retain];
    } // if
    
    return _taskSortDescriptors;
}

#pragma mark Key-Value-Observing

- (void)startObservingProxyAccounts:(NSArray *)accounts {

    for (NSObject* acc in accounts) {
        
		[acc addObserver:self
					 forKeyPath:@"visible"
						options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
						context:&PropertyObservationContext];
	} // for 
}

- (void)stopObservingProxyAccounts:(NSArray *)accounts {

    for (NSObject* acc in accounts) {
        
		[acc removeObserver:self forKeyPath:@"visible"];
	} // for     
}

#pragma mark NSTokenField-Delegate

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject {
    
    NSTokenStyle result= NSPlainTextTokenStyle;
    if( self.messageExpression == tokenField ) {        
        if( [representedObject isKindOfClass:[MessageToken class]] )
            result= NSRoundedTokenStyle;
    } // if
    else 
        result= NSRoundedTokenStyle;

    return result;
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject {

    NSString* result= nil;
    if( [representedObject isKindOfClass:[MessageToken class]] ) {
        
        result= ((MessageToken*)representedObject).token;
        result= NSLocalizedString( result, "" );
    } // if 
    
    return result;
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString: (NSString *)editingString {
    
    return [MessageToken findMessageTokenForString:editingString];
}

- (BOOL)tokenField:(NSTokenField *)tokenField writeRepresentedObjects:(NSArray *)objects toPasteboard:(NSPasteboard *)pboard {
        
    objects= [objects map:^(id tm){ return (id)[tm token]; }];
    [pboard writeObjects:objects];
    
    return YES;
}
- (NSArray *)tokenField:(NSTokenField *)tokenField readFromPasteboard:(NSPasteboard *)pboard {
    
    static NSArray* _classes;
    if( !_classes ) {
        _classes= [[NSArray alloc] initWithObjects:[NSString class],nil];
    } // if
    
    NSArray* result= [[pboard readObjectsForClasses:_classes options:[NSDictionary dictionary]] map:^(id object) { 
        
        id tempResult= [MessageToken findMessageTokenForString:object];
        if( !tempResult )
            tempResult= object;
        return tempResult;
    }];
    
    return result;
}

/**
 Implementation of dealloc, to release the retained variables.
 */

- (void)dealloc {
    
    [self.putTimer invalidate];    

    [self->managedObjectContext release];
    [self->persistentStoreCoordinator release];
    [self->managedObjectModel release];
    
    self->managedObjectContext      = nil;
    self->persistentStoreCoordinator= nil;
    self->managedObjectModel        = nil;
    
    self.putTimer                  = nil;    
    self.preferencesWindow         = nil;    
    self.runningPutRequests        = nil;
    self.extraPanel                = nil;
    self.accountController         = nil;
    self.projectsController        = nil;
    self.visibleCalendarsController= nil;
    self.proxyAccountsController   = nil;
    self.statusItem                = nil;
    self.nameMenuField             = nil;
    self.tableView                 = nil;
    self.status                    = nil;
    self.statusController          = nil;
    self.proxyAccountsNotFound     = nil;
    self.connectionProblems        = nil;
    self.messageExpression         = nil;
    self.highlightedMenuItem       = nil;
    
    [super dealloc];
}


@end
