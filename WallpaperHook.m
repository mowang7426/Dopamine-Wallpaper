#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString * const DWWallpaperFile = @"DopamineWallpaper.png";
static NSString *DWPath(void) {
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[dirs.firstObject stringByAppendingPathComponent:DWWallpaperFile] copy];
}

@interface DOMainViewController : UIViewController
@property(nonatomic, strong) UIImageView *backgroundImageView;
- (void)setupBackground;
@end

@interface DWPickerDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, weak) DOMainViewController *controller;
@end

@implementation DWPickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    if (image) {
        NSData *data = UIImagePNGRepresentation(image);
        if ([data writeToFile:DWPath() atomically:YES]) {
            [self.controller setupBackground];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end

static DWPickerDelegate *gPickerDelegate;

static void DWApply(DOMainViewController *self) {
    NSString *path = DWPath();
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (!image) return;
    UIImageView *view = self.backgroundImageView;
    if (!view) {
        view = [[UIImageView alloc] initWithFrame:self.view.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.userInteractionEnabled = NO;
        [self.view insertSubview:view atIndex:0];
        self.backgroundImageView = view;
    }
    view.image = image;
    [self.view sendSubviewToBack:view];
}

static void DWChoose(DOMainViewController *self) {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    gPickerDelegate = [DWPickerDelegate new];
    gPickerDelegate.controller = self;
    picker.delegate = gPickerDelegate;
    [self presentViewController:picker animated:YES completion:nil];
}

static void DWReset(DOMainViewController *self) {
    [[NSFileManager defaultManager] removeItemAtPath:DWPath() error:nil];
    [self setupBackground];
}

static void DWMenu(DOMainViewController *self) {
    UIAction *choose = [UIAction actionWithTitle:@"Choose Wallpaper" image:[UIImage systemImageNamed:@"photo"] identifier:nil handler:^(__kindof UIAction *a) { DWChoose(self); }];
    UIAction *reset = [UIAction actionWithTitle:@"Reset Wallpaper" image:[UIImage systemImageNamed:@"arrow.counterclockwise"] identifier:nil handler:^(__kindof UIAction *a) { DWReset(self); }];
    UIMenu *menu = [UIMenu menuWithTitle:@"Wallpaper" children:@[choose, reset]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Wallpaper" menu:menu];
    self.navigationItem.leftBarButtonItem = item;
}

static void (*DWOrigSetup)(DOMainViewController *, SEL);
static void DWSetup(DOMainViewController *self, SEL _cmd) {
    DWOrigSetup(self, _cmd);
    DWApply(self);
}

__attribute__((constructor)) static void DWInstall(void) {
    Class cls = NSClassFromString(@"DOMainViewController");
    if (!cls) return;
    SEL setup = @selector(setupBackground);
    Method method = class_getInstanceMethod(cls, setup);
    if (method) {
        DWOrigSetup = (void *)method_getImplementation(method);
        method_setImplementation(method, (IMP)DWSetup);
    }
    SEL viewDidLoad = @selector(viewDidLoad);
    Method load = class_getInstanceMethod(cls, viewDidLoad);
    if (load) {
        IMP original = method_getImplementation(load);
        id block = ^(DOMainViewController *self) {
            ((void (*)(id, SEL))original)(self, viewDidLoad);
            DWMenu(self);
            DWApply(self);
        };
        method_setImplementation(load, imp_implementationWithBlock(block));
    }
}
