//
//  FacialLayout.m
//  Baixing
//
//  Created by 王冠立 on 2/7/14.
//
//

#import "FacialLayout.h"
#import "FacialCell.h"
#import "EmotionUtil.h"

#define FACIAL_COLUMN_COUNT 6
#define FACIAL_SIZE 30

@interface FacialLayout()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) id<EmotionDelegate> delegate;
@end

@implementation FacialLayout

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(FACIAL_SIZE, FACIAL_SIZE);
        layout.sectionInset = UIEdgeInsetsMake(5, 15, 5, 15);
        layout.minimumInteritemSpacing = 15;
        layout.minimumLineSpacing = 2;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                             collectionViewLayout:layout];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [_collectionView registerClass:[FacialCell class] forCellWithReuseIdentifier:@"cellIdentifer"];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_collectionView];
    }
    return self;
}

- (void) setDelegate:(id<EmotionDelegate>)delegate {
    _delegate = delegate;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[EmotionUtil getAllEmotions] count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FacialCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifer" forIndexPath:indexPath];
    EmotionData* data = [[EmotionUtil getAllEmotions] objectAtIndex:indexPath.row];
    if(nil != data) {
        [cell.img setImage:[UIImage imageNamed:[data emotionImg]]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    EmotionData* data = [[EmotionUtil getAllEmotions] objectAtIndex:indexPath.row];
    if(nil != _delegate) {
        [_delegate onEmotionSelected:data];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
