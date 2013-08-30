//
//  ViewController.m
//  FlickrGallery
//
//  Created by Javier Delgado on 30/08/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) PendingOperations *pendingOperations;
@end

@implementation ViewController

#pragma mark - Private Attributes

- (NSMutableArray *)photos
{
    if (!_photos) {
        [[FlickrManager sharedManager] setDelegate:self];
        [[FlickrManager sharedManager] startDownloadPublicImages];
    }
    return _photos;
}

- (void)jsonFromFlickrFinished:(NSArray *)flickrPhotos
{
    _photos = [NSMutableArray arrayWithArray:flickrPhotos];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self testInternetConnection];
    self.title = @"Flickr Gallery";
    self.tableView.rowHeight = 80.0;
}

- (void)didReceiveMemoryWarning
{
    [self cancelAllOperations];
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self cancelAllOperations];
    [self setPhotos:nil];
    [self setPendingOperations:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activityIndicatorView;
    
    FlickrPhoto *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    if (aRecord.hasImage) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = aRecord.thumbnail;
        cell.textLabel.text = aRecord.title;
    }
    else if (aRecord.isFailed) {
        
        if ([internetReachable isReachable])
        {
            [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            cell.textLabel.text = @"";
            
            if (!tableView.dragging && !tableView.decelerating) {
                [self startOperationsForFlickrPhotoRecord:aRecord atIndexPath:indexPath];
            }
            
            [self startOperationsForFlickrPhotoRecord:aRecord atIndexPath:indexPath];
        }
        else
        {
            [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
            cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
            cell.textLabel.text = @"Failed to load";
        }
    }
    else {
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        
        if (!tableView.dragging && !tableView.decelerating) {
            [self startOperationsForFlickrPhotoRecord:aRecord atIndexPath:indexPath];
        }
        
        [self startOperationsForFlickrPhotoRecord:aRecord atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrPhoto *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    if ([aRecord hasImage])
    {
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        [detailViewController setPhotoSelected:aRecord];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([aRecord isFailed])
    {
        [[[UIAlertView alloc] initWithTitle:@"Failed to download" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Image not downloaded yet" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
    }
}

#pragma mark - Operations

- (void)startOperationsForFlickrPhotoRecord:(FlickrPhoto *)record atIndexPath:(NSIndexPath *)indexPath
{
    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForRecord:(FlickrPhoto *)record atIndexPath:(NSIndexPath *)indexPath
{
    // Comprobar si ya existe la operación de descarga mediante su posicion en la tabla.
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithFlickrPhoto:record atIndexPath:indexPath withDelegate:self];
        
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadsQueue addOperation:imageDownloader];
    }
}

#pragma mark - ImageDownloader delegate

- (void)imageDownloaderFinished:(ImageDownloader *)downloader
{
    // 1: Obtenemos la posición en la table del objeto que ha finalizado de descargarse
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    // 2: Obtenemos la instancia del objeto PhotoRecord.
    FlickrPhoto *theRecord = downloader.flickrPhotoRecord;
    
    // 3: Reemplazamos la información actulizada del objeto PhotoRecord en el array de la tabla (Photos array).
    [self.photos replaceObjectAtIndex:indexPath.row withObject:theRecord];
    
    // 4: Actualizamos la IU.
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // 5: Eliminamos la operación del diccionario de descargas pendientes.
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Si el usuario está desplazandose por la tabla suspenderemos todas las operaciones.
    [self suspendAllOperations];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Si el usuario deja de desplazarse reanudamos las operaciones
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Hacemos lo mismo que en el método scrollViewDidEndDragging:willDecelerate:
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}

#pragma mark - Cancelling, suspending, resuming queues/operations

- (void)suspendAllOperations {
    [self.pendingOperations.downloadsQueue setSuspended:YES];
}


- (void)resumeAllOperations {
    [self.pendingOperations.downloadsQueue setSuspended:NO];
}


- (void)cancelAllOperations {
    [self.pendingOperations.downloadsQueue cancelAllOperations];
}

- (void)loadImagesForOnscreenCells
{
    // 1: Obtenemos las celdas visibles.
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    
    // 2: Obtenemos todas las operaciones pendientes de ambas colas (descarga y filtro).
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 3: Filas que necesitan una operacion = filas visibles con operaciones pendientes.
    [toBeStarted minusSet:pendingOperations];
    
    // 4: Filas en las que sus operaciones deberían estar canceladas.
    [toBeCancelled minusSet:visibleRows];
    
    // 5: Recorremos atraves de aquellas que deben ser canceladas, las cancelamos y eliminamos sus referencias de los diccionarios del objeto PendingOperation.
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];

    }
    toBeCancelled = nil;
    
    // 6: Recorremos atraves de aquellas que deben ser reanudadas, y llamaremos desde cada una al método startOperationsForPhotoRecord:atIndexPath:.
    for (NSIndexPath *anIndexPath in toBeStarted) {
        
        FlickrPhoto *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationsForFlickrPhotoRecord:recordToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
}

#pragma mark - Internet Connection

- (void)testInternetConnection
{
    internetReachable = [Reachability reachabilityWithHostname:@"www.flickr.com"];
    
    __weak ViewController *weakSelf = self;
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Internet on");
            [weakSelf.tableView reloadData];
            [weakSelf resumeAllOperations];
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Internet Off");
            [[[UIAlertView alloc] initWithTitle:@"Your connection is down" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
            [weakSelf cancelAllOperations];
            [weakSelf.tableView reloadData];
        });
    };
    
    [internetReachable startNotifier];
}

@end
