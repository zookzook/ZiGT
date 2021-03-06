#import <Cocoa/Cocoa.h>
#import "Configs.h"

@class Status;
@class Project;
@class Task;

@interface AppDelegate : NSObject {
    
    NSWindow                     *preferencesWindow;    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel         *managedObjectModel;
    NSManagedObjectContext       *managedObjectContext;
    NSObjectController           *statusController;
    NSObjectController           *accountController;
    NSArrayController            *visibleCalendarsController;
    NSArrayController            *projectsController;
    NSArrayController            *proxyAccountsController;
    NSArray                      *oldProxyAccounts;
    NSStatusItem                 *statusItem;
    NSTextField                  *nameMenuField;
    NSTableView                  *tableView;    
    NSTimer                      *putTimer;
    Status                       *status;
    NSMutableSet                 *runningPutRequests;
    NSPanel                      *extraPanel;
    NSPanel                      *projectChooserPanel;
    NSDate                       *startedAt;
    NSImageView                  *connectionProblems;
    NSImageView                  *proxyAccountsNotFound;
    NSTokenField                 *messageExpression;
    NSTokenField                 *messageExpressionTemplates;
    NSMenuItem                   *highlightedMenuItem;
    Project                      *selectedProject;
    Task                         *selectedTask;
    BOOL                         hasConnectivity;
}

@property (nonatomic, retain) IBOutlet NSWindow                      *preferencesWindow;
@property (nonatomic, retain) IBOutlet NSPanel                       *extraPanel;
@property (nonatomic, retain) IBOutlet NSPanel                       *projectChooserPanel;
@property (nonatomic, retain) IBOutlet NSObjectController            *statusController;
@property (nonatomic, retain) IBOutlet NSObjectController            *accountController;
@property (nonatomic, retain) IBOutlet NSArrayController             *projectsController;
@property (nonatomic, retain) IBOutlet NSArrayController             *visibleCalendarsController;
@property (nonatomic, retain) IBOutlet NSArrayController             *proxyAccountsController;
@property (nonatomic, retain) IBOutlet NSTextField                   *nameMenuField;
@property (nonatomic, retain) IBOutlet NSTableView                   *tableView;
@property (nonatomic, retain) IBOutlet NSImageView                   *connectionProblems;
@property (nonatomic, retain) IBOutlet NSImageView                   *proxyAccountsNotFound;
@property (nonatomic, retain) IBOutlet NSTokenField                  *messageExpression;
@property (nonatomic, retain) IBOutlet NSTokenField                  *messageExpressionTemplates;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, retain)           NSStatusItem                 *statusItem;
@property (nonatomic, retain)           NSTimer                      *putTimer;
@property (nonatomic, retain)           Status                       *status;
@property (nonatomic, retain)           NSMutableSet                 *runningPutRequests;
@property (nonatomic, retain)           NSDate                       *startedAt;
@property (nonatomic, retain)           NSArray                      *oldProxyAccounts;
@property (nonatomic, retain)           NSMenuItem                   *highlightedMenuItem;
@property (nonatomic, retain)           Project                      *selectedProject;
@property (nonatomic, retain)           Task                         *selectedTask;
@property (nonatomic)                   BOOL                         hasConnectivity;

/**
 * Starte ein Projekt.
 */
- (void)startProject:(Project*)theProject task:(Task*)theTask;

- (IBAction)saveAction:sender;

/**
 * iCal starten
 */
- (IBAction)launchIcal:sender;

/**
 * Applikation beenden
 */
-(IBAction)terminate:(id)sender;

/**
 * leere Action
 */
- (IBAction)noop:sender;

/**
 * Aufzeichnung wird gestoppt.
 */
- (IBAction)stopRecording:sender;

/**
 * Projekt wird gewechselt.
 */
- (IBAction)changeProject:sender;

/**
 * Öffne das Einstellungsfenster
 */
- (IBAction)showPreferences:(id)sender;

/**
 * Fügt ein neues Projekt hinzu und aktiviert automatisch das Feld für den Namen.
 */
- (IBAction)addProject:(id)sender;

/**
 * Überprüft die Verbindungsdaten mit einem Request.
 */
- (IBAction)checkConnection:(id)sender;

/**
 * Liefert das Menü zurück.
 */
- (NSMenu *)menu;

/**
 * Aktualisiert den Inhalt das Status-Menü
 */
- (void)updateStatusMenu;

/**
 * Aktualisiert je nach Status die Status-Bar
 */
- (void)updateStatusBar;

/**
 * Ist das Einstellungsfenster offen?
 */
- (BOOL)isPreferencesWindowOpen;

/**
 * Synchronisation starten
 */
- (IBAction)pushAction:(id)sender;

/**
 * Proxy-Accounts werden aktualisiert.
 */
- (IBAction)refreshProxyAccounts:(id)sender;

- (IBAction)continueChange:(id)sender;

- (IBAction)cancelChange:(id)sender;

/**
 * Starte nun das Tracking nach expliziter Auswahl
 */
- (IBAction)startTracking:(id)sender;

/**
 * Es passiert nichts, der Anwender will noch nichts starten...
 */
- (IBAction)pauseTracking:(id)sender;
    

/**
 * Ist ein Fenster offen?
 */
- (BOOL)isWindowOpen;

- (void)startObservingProxyAccounts:(NSArray *)accounts;
- (void)stopObservingProxyAccounts:(NSArray *)accounts;
    
@end
