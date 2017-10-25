//
//  AIPictureViewer.m
//  AIAnimationDemo
//
//  Created by joker on 2017/02/09.
//  Copyright © 2017 joker All rights reserved.
//

#import "AIPictureViewer.h"
#import "AIPictureCollectionViewCell.h"
#import <Photos/Photos.h>
#import "AGIPCToolbarItem.h"
#import "AGImagePickerController.h"
#import "UIView+UIViewController.h"
#define GETIMAGISEVERSION  NO
#define Base_Color3 RGB(214, 215, 216)  //下一步不可选中灰色
#define RGB(R,G,B)		[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#define MainSize [UIScreen mainScreen].bounds.size

@interface AIPictureViewer ()<UICollectionViewDataSource,AIPictureCollectionCellDelegate,UIScrollViewDelegate,UICollectionViewDelegate,AGImagePickerControllerDelegate>
{
    UIButton *_sendPhoto ;
    ALAssetsLibrary *_library;
    int  _clickNum ;
    BOOL _isOriginImage;//是否发送原图
    AGImagePickerController *_ipc;

}
//弹窗选择的图片数组
@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@property (nonatomic,strong)NSMutableArray *array;
@property (nonatomic, strong) PHImageRequestOptions *options;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets2;
@property(nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSIndexPath *currentIndexPath;
@property (nonatomic,strong)UIView *bottomView;//底部view
@property (nonatomic, strong) NSMutableDictionary *cellDic;
@property (nonatomic,strong)NSMutableArray *indexPaths;
@property (nonatomic,strong)NSMutableArray *clickNumArray;//点击数目
/** 固定的frame*/
@property(nonatomic,assign)CGRect fixedRect;
@property(nonatomic,assign)CGPoint translationPoint;

@property (nonatomic,assign)CGRect originFrame;

@end
static const CGFloat pictureHeight = 133;
static const CGFloat selfHeight = 172;
static const CGFloat padding       = 4;


@implementation AIPictureViewer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //固定大小
        _selfHeight = 172;
        _indexPaths = [NSMutableArray array];
        _clickNumArray = [NSMutableArray array];
        self.userInteractionEnabled = YES;
        self.frame            = CGRectMake(0, MainSize.height - selfHeight, MainSize.width,selfHeight);
        [self addSubview:self.collectionView];
        [self addBottomView];
        
        [self loadData];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:@"HaveSaveImageNotification" object:nil];
        
    }
    return self;
}
#pragma mark 重新加载相册数据
-(void)loadData
{
    if (GETIMAGISEVERSION) {
        //PhotoKit 框架
        [self getAllPhotosFromAlbum];
    }else{
        //AlASS 框架
        [self addSystemPhoto];
    }
}
#pragma mark  -lazy
-(CGRect)fixedRect{
    _fixedRect = CGRectMake(0, 0, MainSize.width, pictureHeight);
    return _fixedRect;
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize                    = CGSizeMake(90, pictureHeight);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing= 0;
        _collectionView                        =\
        [[UICollectionView alloc]initWithFrame:self.fixedRect collectionViewLayout:flowLayout];
        _collectionView.backgroundColor         = RGB( 255, 251, 240);
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource             = self;
        _collectionView.delegate               = self;
        _collectionView.contentSize            = CGSizeMake(flowLayout.itemSize.width+padding * self.imageArrayM.count, pictureHeight);
        _collectionView.directionalLockEnabled = YES;
    }
    //PhotoKit 获取照片
    return _collectionView;
}
-(NSMutableDictionary *)cellDic
{
    if (!_cellDic) {
         self.cellDic = [[NSMutableDictionary alloc] init];
    }
    return self.cellDic;
}
#pragma 创建底部视图
-(void)addBottomView
{
    _bottomView = ({
        UIView *view = [UIView new];
        view.userInteractionEnabled= YES;
        view.layer.borderWidth = 0.3;
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1].CGColor;
        view.frame = CGRectMake(0, 134, MainSize.width, 39);
        view;
    });
    [self addSubview:_bottomView];
    UIButton *openPhotos = ({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        [view setTitle:@"相册" forState:UIControlStateNormal];
        [view addTarget:self action:@selector(openSystemPhoto) forControlEvents:UIControlEventTouchUpInside];
        [view setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        view.frame = CGRectMake(10, 11, 40, 20);
        view.titleLabel.font = [UIFont systemFontOfSize:17];
        view;
    });
    
    UIButton *cicleView = ({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.frame = CGRectMake(71, 11, 60, 22);
        [view setImage:[UIImage imageNamed:@"cicleView"] forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"cicleViewSelec"] forState:UIControlStateSelected];
        [view setTitle:@"原图" forState:UIControlStateNormal];
        view.titleLabel.font = [UIFont systemFontOfSize:17];
        [view addTarget:self action:@selector(setHighScreenImage:) forControlEvents:UIControlEventTouchUpInside];
        [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        view;
    });
    _sendPhoto = ({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.frame = CGRectMake(MainSize.width-10-66, 8, 66, 25);
        [view.titleLabel setFont:[UIFont systemFontOfSize:15]];
        view.layer.cornerRadius = 2;
        view.backgroundColor = Base_Color3;
        [view setTitle:@"发送" forState:UIControlStateNormal];
        [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(sendImage) forControlEvents:UIControlEventTouchUpInside];
        view;
    });


    [_bottomView addSubview:openPhotos];
    [_bottomView addSubview:cicleView];
    [_bottomView addSubview:_sendPhoto];
    //初始化图片选择器
}
#pragma mark 初始化 
-(void)initImagePickerView
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请前往设置->隐私->相册授权应用访问相册权限" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
        alertView.delegate = self;
        [alertView show];
        return;
    }
    self.selectedPhotos = [NSMutableArray array];
    self.originFrame = self.frame;
    __block AIPictureViewer *blockSelf = self;

    _ipc = [AGImagePickerController sharedInstance:self];
    _ipc.shouldShowSavedPhotosOnTop = NO;
    _ipc.shouldChangeStatusBarStyle = YES;
    _ipc.selection = self.selectedPhotos;
    _ipc.maximumNumberOfPhotosToBeSelected = 3;//最多选择照片数量
    _ipc.delegate = self;
    _ipc.didFailBlock = ^(NSError *error) {

        if (error == nil) {
            [blockSelf.selectedPhotos removeAllObjects];
            [blockSelf.viewController dismissViewControllerAnimated:NO completion:^{
                blockSelf.frame = blockSelf.originFrame;
            }];
        } else {
            
            // We need to wait for the view controller to appear first.
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [blockSelf.viewController dismissViewControllerAnimated:NO completion:^{
                    blockSelf.frame = blockSelf.originFrame;
                }];
            });
        }
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
    };
    _ipc.didFinishBlock = ^(NSArray *info) {
        [blockSelf.selectedPhotos setArray:info];
        if (blockSelf.selectedPhotos.count!=0) {
            if (blockSelf.delegate&&[blockSelf.delegate respondsToSelector:@selector(pictureViewOpenSystemPhoto:withimageArray:)]) {
                [blockSelf.delegate pictureViewOpenSystemPhoto:blockSelf withimageArray:blockSelf.selectedPhotos];
            }
        }
        [blockSelf.viewController dismissViewControllerAnimated:NO completion:^{
            blockSelf.frame = blockSelf.originFrame;
        }];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    };
}
#pragma mark  设置高清图
-(void)setHighScreenImage:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _isOriginImage = sender.selected;
}
#pragma mark  打开系统相册 建议用代理外部实现

-(void)openSystemPhoto
{
    // Show saved photos on top

    // Custom toolbar items
//    AGIPCToolbarItem *selectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"选中全部" style:UIBarButtonItemStylePlain target:nil action:nil] andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
//        return YES;
//    }];
    
    AGIPCToolbarItem *flexible = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] andSelectionBlock:nil];
    AGIPCToolbarItem *deselectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"取消所选" style:UIBarButtonItemStylePlain target:nil action:nil] andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
        return NO;
    }];
    _ipc.toolbarItemsForManagingTheSelection = @[flexible,flexible, deselectAll];
    
    [self.viewController presentViewController:_ipc animated:YES completion:NULL];
    
    // Show first assets list, modified by springox(20140503)
    [_ipc showFirstAssetsController];

}
#pragma  mark  打开相册 点击事件
//已废弃的方法
-(void)addSystemPhoto
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请前往设置->隐私->相册授权应用访问相册权限" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
        alertView.delegate = self;
        [alertView show];
        return;
    }
    //初始化系统相册
    [self initImagePickerView];

    _array = [NSMutableArray array];
    
    _library = [[ALAssetsLibrary alloc] init];
    
    [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {

                if (result) {
                    [_array addObject:result];
                }
            }];
        }
        _imageArrayM = (NSArray *)_array;
        [self getImageData];
    } failureBlock:^(NSError *error) {
//        [ProgressHUD showError:@"无法访问您的相册!"];
    }];

}
#pragma mark 发送照片

-(void)sendImage
{
    NSMutableArray *imgeArr = [NSMutableArray array];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pictureViewer:didGestureSelectedImage:withOriginSoure:andImageWorldRect:)]) {
        for (int i = 0; i<_indexPaths.count; i++) {
            NSIndexPath *indexPath = _indexPaths[i];
            AIPictureCollectionViewCell *cell =(AIPictureCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            //重设cell 的选中状态
            [cell resetCircleView];
            //获取到缩略图
             ALAsset *result =_imageArrayM[indexPath.item];
            //改为兼容发送GIF的格式
//            [[asset defaultRepresentation] fullResolutionImage]  // 原图
//            CGImageRef cimg =_isOriginImage?[[result defaultRepresentation] fullResolutionImage]:[[result defaultRepresentation] fullResolutionImage];
//            [result aspectRatioThumbnail];
//            UIImage *img = [UIImage imageWithCGImage:cimg];//aspectRatioThumbnail
            [imgeArr addObject:result];
        }
        [self.delegate pictureView:self didSelectedImage:imgeArr];
        
    }
    //重设点击数目
    _clickNum =0;
    _indexPaths = [NSMutableArray array];
    _clickNumArray = [NSMutableArray array];
    _sendPhoto.userInteractionEnabled = NO;
    _sendPhoto.backgroundColor = Base_Color3;
}
//从系统中捕获所有相片---适配iOS8.0以上版本 - - - - - - - - - - - - - - - - - -  - - - - - - - - --  - - - - - - - -- - - - - - -- - -
- (void)getAllPhotosFromAlbum {
    /*
     PHAssetMediaType：
     PHAssetMediaTypeUnknown = 0,//在这个配置下，请求不会返回任何东西
     PHAssetMediaTypeImage   = 1,//图片
     PHAssetMediaTypeVideo   = 2,//视频
     PHAssetMediaTypeAudio   = 3,//音频
     */
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请前往设置->隐私->相册授权应用访问相册权限" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
        alertView.delegate = self;
        [alertView show];
        return;
    }
    
    self.options = [[PHImageRequestOptions alloc] init];//请求选项设置
    self.options.resizeMode = PHImageRequestOptionsResizeModeExact;//自定义图片大小的加载模式
    self.options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    self.options.synchronous = YES;//是否同步加载
    //容器类
    self.imageArrayM = [self getAllAssetInPhotoAblumWithAscending:YES]; //得到所有图片
    [self.collectionView reloadData];

  
    
}
#pragma mark 解析相册资源
-(void)getImageData
{
    //取出对应的资源数据
    NSEnumerator *enumerator = [self.imageArrayM reverseObjectEnumerator];
    self.imageArrayM = (NSMutableArray*)[enumerator allObjects];
    [self.collectionView reloadData];
}
#pragma mark - 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithOptions:option];

    for (int i = 0; i < result.count; i++) {
        PHAsset *set = result[i];
        [assets addObject:set];
    }
  
    return assets;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.fixedRect;
}

#pragma mark --UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArrayM.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    NSString *identifier = [_cellDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"%@%@", @"photoCollecview", [NSString stringWithFormat:@"%@", indexPath]];
        [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
        // 注册Cell
        [self.collectionView registerClass:[AIPictureCollectionViewCell class]  forCellWithReuseIdentifier:identifier];
    }
    
    AIPictureCollectionViewCell * cell =[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (_indexPaths.count==0) {
        [cell resetCircleView];
    }
    cell.delegate                     = self;
#pragma mark  PhotoKit框架获取

    if (GETIMAGISEVERSION) {
        PHAsset *s = self.imageArrayM[indexPath.row];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.synchronous = YES;
        PHCachingImageManager *imageManager = [[PHCachingImageManager alloc]init];
        [imageManager requestImageForAsset:s targetSize:CGSizeMake(640, 1136) contentMode:PHImageContentModeAspectFill options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            cell.imageV.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageV.image = result;
        }];
    }
#pragma mark  ALAss 框架
    else{
        
        ALAsset *result =_imageArrayM[indexPath.item];
            //获取到缩略图
        CGImageRef cimg = [result aspectRatioThumbnail];//[[result defaultRepresentation] fullResolutionImage];//[result aspectRatioThumbnail];
        UIImage *img = [UIImage imageWithCGImage:cimg];//aspectRatioThumbnail
        //转换为UIImage
        cell.imageV.image   = img;

        cell.imageV.soureData = result;
        ALAssetRepresentation *rep = [result defaultRepresentation];
        NSLog(@"%@",rep.filename);
        if ([result.description containsString:@"gif"]||[result.description containsString:@"GIF"]) {
            cell.GIFIdeL.hidden = NO;
        }else{
            cell.GIFIdeL.hidden = YES;
        }
        

    }

      return cell;
}
- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ALAsset *result =_imageArrayM[indexPath.item];
    //获取到缩略图
    CGImageRef cimg = [result aspectRatioThumbnail];//[[result defaultRepresentation] fullResolutionImage];//[result aspectRatioThumbnail];
    UIImage *img = [UIImage imageWithCGImage:cimg];//aspectRatioThumbnail
    CGFloat fixelW = CGImageGetWidth(img.CGImage);
//    CGFloat fixelH = CGImageGetHeight(img.CGImage);
    //转换为UIImage
    if (fixelW>200) {
        return CGSizeMake(fixelW*0.4, pictureHeight);
    }
    return CGSizeMake(fixelW*0.9, pictureHeight);

}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}
#pragma mark  UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AIPictureCollectionViewCell *cell =(AIPictureCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.cicleView.selected) {
        [cell.cicleView popInsideWithDuration:0.4];
        cell.cicleView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [cell.cicleView setTitle:@"" forState:UIControlStateNormal];
        cell.cicleView.selected = NO;
        [_indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (obj == indexPath) {
                
                *stop = YES;
                if (*stop == YES) {
                    _clickNum--;
                    
                    [_indexPaths removeObject:obj];
                    [_clickNumArray addObject:cell.cicleView.titleLabel.text];
                }
                
            }
        }];
        
    }else{
        if (_clickNum>=3) {
//            [JohnAlertManager showFailedAlert:@"最多选择3张图片" andTitle:@"提示"];
            return;
        }
        _clickNum ++;
        NSString *numStr = [NSString stringWithFormat:@"%d",_clickNum];
        [_indexPaths addObject:indexPath];
        [cell.cicleView popOutsideWithDuration:0.5];
        cell.cicleView.selected = YES;
        cell.cicleView.backgroundColor = [UIColor orangeColor];
        NSString *num;
        if (_clickNumArray.count>0) {
            int  min_value = [[_clickNumArray valueForKeyPath:@"@min.floatValue"] intValue];  //最小值
            num =[NSString stringWithFormat:@"%d",min_value];
            [_clickNumArray removeObject:num];
        }else{
            num = numStr;
        }
        
        [cell.cicleView setTitle:num forState:UIControlStateNormal];
        [cell.cicleView animate];
    }
    if (_indexPaths.count==0) {
        _sendPhoto.userInteractionEnabled = NO;
        _sendPhoto.backgroundColor = Base_Color3;
    }else{
        _sendPhoto.userInteractionEnabled = YES;
        _sendPhoto.backgroundColor = [UIColor orangeColor];

    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint pInView = [self convertPoint:self.collectionView.center toView:self.collectionView];

    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pInView];

    self.currentIndexPath = indexPathNow;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark --AIPictureCollectionCellDelegate
-(void)pictureCollection:(AIPictureCollectionViewCell*)pictureCollectionCell didGestureSelectedImage:(UIImage*)image  withOriginSoure:(ALAsset *)sorueData andImageWorldRect:(CGRect)imageWorldRect{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pictureViewer:didGestureSelectedImage:withOriginSoure:andImageWorldRect:)]) {
        [self.delegate pictureViewer:self didGestureSelectedImage:image withOriginSoure:sorueData andImageWorldRect:imageWorldRect];
    }

    // 获取这一点的indexPath
    NSIndexPath *indexPathNow = [self.collectionView indexPathForCell:pictureCollectionCell];
    
    [_indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (obj == indexPathNow) {
            
            *stop = YES;
            
            if (*stop == YES) {
                
                [_indexPaths removeObject:obj];
                _clickNum--;
                [_clickNumArray addObject:pictureCollectionCell.cicleView.titleLabel.text];

            }
            
        }
    }];
    if (_indexPaths.count==0) {
        _sendPhoto.userInteractionEnabled = NO;
        _sendPhoto.backgroundColor = Base_Color3;
        _clickNum = 0;
    }
}


-(void)pictureCollection:(AIPictureCollectionViewCell *)pictureCollectionCell lockScollViewWithOnWindow:(BOOL)isOnWindow{
    self.collectionView.scrollEnabled = !isOnWindow;
}
-(void)sendImage:(UIButton *)sender event:(id)event
{

    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_collectionView];
    NSIndexPath *indexPath= [_collectionView indexPathForItemAtPoint:currentTouchPosition];
    [self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
}
#pragma mark AGImagePickerDelegate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (NSUInteger)agImagePickerController:(AGImagePickerController *)picker
         numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
              andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (deviceType == AGDeviceTypeiPad)
    {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            return 11;
        else
            return 8;
    } else {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            if (480 == self.bounds.size.width) {
                return 6;
            }
            return 7;
        } else
            return 4;
    }
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
}

- (BOOL)agImagePickerController:(AGImagePickerController *)picker shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode
{
    return (selectionMode == AGImagePickerControllerSelectionModeSingle ? NO : YES);
}

- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(AGImagePickerController *)picker
{
    return AGImagePickerControllerSelectionBehaviorTypeRadio;
}
-(void)didFinishPickingAssets:(NSArray *)selectedAssets
{
    
}
#pragma mark UIAlertViewDelegate
- (void)alertViewCancel:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0)
{
    
    
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0);
//
//// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
//// If not defined in the delegate, we simulate a click in the cancel button
//- (void)alertViewCancel:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);
//
//- (void)willPresentAlertView:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);  // before animation and showing view
//- (void)didPresentAlertView:(UIAlertView *)alertView NS_DEPRECATED_IOS(2_0, 9_0);  // after animation
//
//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0); // before animation and hiding view
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0);  // after animation
@end




