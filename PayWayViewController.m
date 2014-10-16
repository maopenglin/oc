
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"
#import "AFNetworking.h"
#import "JSON.h"
#import "NSString+MD5.h"

#import "BKDefine.h"

#import "CommonUtil.h"
#import "WXApi.h"


@interface PayWayViewController ()
@property (nonatomic, copy) NSString *timeStamp;
@property (nonatomic, copy) NSString *nonceStr;
@property (nonatomic, copy) NSString *traceId;
@end

@implementation PayWayViewController
@synthesize result = _result;

- (void)dealloc
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}
-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"self.order_num:%@",self.order_num);
     self.alipayButton.userInteractionEnabled=NO;
    NSString* getTokenStr = [MDMNetMgr genReqUrlclosing];
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSDictionary *dic=@{@"otoken":[MDMLoginInfo sharedLoginInfo].oToken,@"oid":self.order_num};
    
      [mgr POST:getTokenStr parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        ITLog([responseObject JSONString]);
          
          if([[responseObject valueForKey:@"status"] intValue]==0){
          
              NSDictionary *dic=[responseObject valueForKey:@"data"];
              self.price=[[dic valueForKey:@"price"] floatValue];
              self.realPrice=[[dic valueForKey:@"real_price"] floatValue];
              self.title=[dic valueForKey:@"title"];
              self.subject=self.body=self.title;
              self.discount=[[dic valueForKey:@"sale"] floatValue];
            [self.priceLabel setText:[NSString stringWithFormat:@"%.2f",self.price]];
              self.ordernum=[dic valueForKey:@"order_num"];
              self.discountTextLabel.text=[NSString stringWithFormat:@"亲！在线支付%.1f折优惠哦",self.discount];
            [self.discountLabel setText:[NSString stringWithFormat:@"%.2f",self.realPrice]];
              self.alipayButton.userInteractionEnabled=YES;
          }
    
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//          NSLog(@"%@", error);
      }];
//    NSLog(@"self.realPrice=%f,self.discount=%f",self.discount,self.realPrice);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:ORDER_PAY_NOTIFICATION object:nil];
    _result = @selector(paymentResult:);
    
       UIButton * u = (UIButton*)[self.view viewWithTag:88];
    
    u.layer.cornerRadius =3;
    
    for (UIView * view in _viewArray)
    {
        view.layer.cornerRadius = 3;
    }
    self.payWay = 0;
//    [self.alipayButton sendAction:@selector(choose:) to:self forEvent:UIControlStateNormal];
    
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)choose:(UIButton*)sender
{
//    int i = [self.buttonArray indexOfObject:sender];
    
    if (sender == _wachatpayButton)
    {
        self.payWay = 1;
        _wchatSelectedButton.selected = YES;
        _alipaySelectedButton.selected = NO;
    }
    else if (sender == _alipayButton)
    {
        self.payWay = 2;
        _wchatSelectedButton.selected = NO;
        _alipaySelectedButton.selected = YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)pay:(id)sender
{
    if (self.payWay==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择你的支付方式" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [_contentView showProgressHUDWithLabelText:@"正在获取订单信息" withAnimated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.payWay==1)
        {
            [self WXpay];
        }
        else if(self.payWay==2)
        {
            NSString *appScheme = @"maidoumi";
            NSString* orderInfo = [self getOrderInfo];
            NSString* signedStr = [self doRsa:orderInfo];
            
//            NSLog(@"%@",signedStr);
            
            NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                     orderInfo, signedStr, @"RSA"];
            
            [AlixLibService payOrder:orderString AndScheme:appScheme seletor:@selector(paymentResultDelegate:) target:self];
        }
    });
}
/**
 微信支付
*/
 -(void)WXpay
{

    [self getAccessToken];
}


-(NSString*)getOrderInfo
{
    /*
	 *点击获取prodcut实例并初始化订单信息
	 */
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
    order.tradeNO = self.ordernum; //订单ID（由商家自行制定）
	//order.productName = self.title; //商品标题
    order.productName = self.subject;
	order.productDescription = self.body; //商品描述
	order.amount = [NSString stringWithFormat:@"%.2f",self.realPrice]; //商品价格
	order.notifyURL = NOTEURL; //回调URL
	
	return [order description];
}


//wap回调函数

//- (NSString *)generateTradeNO
//{
//	const int N = 15;
//	
//	NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
//	NSMutableString *result = [[NSMutableString alloc] init] ;
//	srand(time(0));
//	for (int i = 0; i < N; i++)
//	{
//		unsigned index = rand() % [sourceString length];
//		NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
//		[result appendString:s];
//	}
//	return result;
//}

-(NSString*)doRsa:(NSString*)orderInfo
{
    id<DataSigner> signer;
    signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}

-(void)paymentResultDelegate:(NSString *)result
{
//    NSLog(@"支付结果%@",result);
}
////////////////////////微信支付
// 获取token
- (void)getAccessToken
{
    NSString *tokenUrl = @"cgi-bin/token";
    NSDictionary *param = @{@"grant_type":@"client_credential", @"appid":WXAppId, @"secret":WXAppSecret};
    
    NSString *urlstr=[NSString stringWithFormat:@"%@%@?grant_type=client_credential&appid=%@&secret=%@",BASE_URL,tokenUrl,WXAppId,WXAppSecret];
//    NSLog(@"url:%@",urlstr);
    NSURL *url=[[NSURL alloc]initWithString:urlstr];
    NSMutableURLRequest  *request=[[NSMutableURLRequest alloc]initWithURL:url];
    NSError *err=nil;
    NSData *data=[NSURLConnection sendSynchronousRequest:request
                                       returningResponse:nil
                                                   error:&err];
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",aStr);
    if (aStr) {
       NSDictionary *dic= [aStr JSONValue];
        if (dic[AccessTokenKey]) {
//            NSLog(@"%@",dic[AccessTokenKey]);
            [self getPrepayId:dic[AccessTokenKey]];
        }
    }
//    [HttpUtil doGetWithUrl:BASE_URL
//                      path:tokenUrl
//                    params:param
//                  callback:^(BOOL isSuccessed, NSDictionary *result){
//                      
//                      NSString *accessToken = result[AccessTokenKey];
//                      [self getPrepayId:accessToken];
//                  }];
}

// 生成预支付订单
- (void)getPrepayId:(NSString *)accessToken
{
    NSString *prepayIdUrl = [NSString stringWithFormat:@"pay/genprepay?access_token=%@", accessToken];
    
    // 拼接详细的订单数据
    NSDictionary *postDict = [self getProductArgs];
    NSString *urlstr=[NSString stringWithFormat:@"%@%@",BASE_URL,prepayIdUrl];
    //NSLog(@"url:%@",urlstr);
    NSURL *url=[[NSURL alloc]initWithString:urlstr];
    NSMutableURLRequest  *request=[[NSMutableURLRequest alloc]initWithURL:url];
    NSError *err=nil;
    [request setHTTPMethod:@"POST"];
   NSData* xmlData = [[postDict JSONFragment] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:xmlData];
    NSData *data=[NSURLConnection sendSynchronousRequest:request
                                       returningResponse:nil
                                                   error:&err];
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   // NSLog(@"%@",aStr);
    if (aStr) {
        NSDictionary *dic= [aStr JSONValue];
         NSString *prePayId = dic[PrePayIdKey];
        if (prePayId)
        {
//            NSLog(@"--- PrePayId: %@", prePayId);
            
            // 调起微信支付
            PayReq *request   = [[PayReq alloc] init];
            request.partnerId = WXPartnerId;
            request.prepayId  = prePayId;
            request.package   = @"Sign=WXPay";
            request.nonceStr  = self.nonceStr;
            request.timeStamp = [self.timeStamp intValue];
            
            // 构造参数列表
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:WXAppId forKey:@"appid"];
            [params setObject:WXAppKey forKey:@"appkey"];
            [params setObject:request.nonceStr forKey:@"noncestr"];
            [params setObject:request.package forKey:@"package"];
            [params setObject:request.partnerId forKey:@"partnerid"];
            [params setObject:request.prepayId forKey:@"prepayid"];
            [params setObject:self.timeStamp forKey:@"timestamp"];
            request.sign = [self genSign:params];
            
            [WXApi safeSendReq:request];
        }
    }
 
}

#pragma mark - 生成各种参数
// 获取时间戳
- (NSString *)genTimeStamp
{
    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
}

/**
 *  获取32位内的随机串, 防重发
 *
 *  注意：商户系统内部的订单号,32个字符内、可包含字母,确保在商户系统唯一
 */
- (NSString *)genNonceStr
{
    return [CommonUtil md5:[NSString stringWithFormat:@"%d", arc4random() % 10000]];
}

/**
 *  获取商家对用户的唯一标识
 *
 *  traceId 由开发者自定义，可用于订单的查询与跟踪，建议根据支付用户信息生成此id
 *  建议 traceid 字段包含用户信息及订单信息，方便后续对订单状态的查询和跟踪
 */
- (NSString *)genTraceId
{
    
    return [NSString stringWithFormat:@"maidoumi_%@", [MDMLoginInfo sharedLoginInfo].nToken];
}

- (NSString *)genOutTradNo
{
    return self.ordernum;//[CommonUtil md5:[NSString stringWithFormat:@"%d", arc4random() % 10000]];
}

// 订单详情
- (NSString *)genPackage
{
    // 构造订单参数列表
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"WX" forKey:@"bank_type"];
    [params setObject:self.body forKey:@"body"];
    [params setObject:@"1" forKey:@"fee_type"];
    [params setObject:@"UTF-8" forKey:@"input_charset"];
    [params setObject:NOTEURL forKey:@"notify_url"];
    [params setObject:[self genOutTradNo] forKey:@"out_trade_no"];
    [params setObject:WXPartnerId forKey:@"partner"];
    [params setObject:[CommonUtil getIPAddress:YES] forKey:@"spbill_create_ip"];
//    NSLog(@"self.price:%f",self.price);
    //self.price=12.50;
    [params setObject:[NSString stringWithFormat:@"%.f",100*self.realPrice] forKey:@"total_fee"];    // 1 =＝ ¥0.01
    
    NSArray *keys = [params allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
   
    
    NSMutableString *package = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [package appendString:key];
        [package appendString:@"="];
        [package appendString:[params objectForKey:key]];
        [package appendString:@"&"];
    }
    
    [package appendString:@"key="];
    [package appendString:WXPartnerKey];
    NSString *packageSign = [[CommonUtil md5:[package copy]] uppercaseString];
    package = nil;
   
    NSString *value = nil;
    package = [NSMutableString string];
    for (NSString *key in sortedKeys)
    {
        [package appendString:key];
        [package appendString:@"="];
        value = [params objectForKey:key];
        value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, nil, (CFStringRef)@"!*'&=();:@+$,/?%#[]", kCFStringEncodingUTF8));
        
        [package appendString:value];
        [package appendString:@"&"];
    }
    NSString *packageParamsString = [package substringWithRange:NSMakeRange(0, package.length - 1)];
    
    NSString *result = [NSString stringWithFormat:@"%@&sign=%@", packageParamsString, packageSign];
//    NSLog(@"result:%@",result);
    
    return result;
}

// 签名
- (NSString *)genSign:(NSDictionary *)signParams
{
    // 排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    // 生成
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [sign appendString:key];
        [sign appendString:@"="];
        [sign appendString:[signParams objectForKey:key]];
        [sign appendString:@"&"];
    }
    NSString *signString = [[sign copy] substringWithRange:NSMakeRange(0, sign.length - 1)];
    
    NSString *result = [CommonUtil sha1:signString];
//    NSLog(@"--- Gen sign: %@", result);
    return result;
}

// 构造订单参数列表
- (NSDictionary *)getProductArgs
{
    self.timeStamp = [self genTimeStamp];   // 获取时间戳
    self.nonceStr = [self genNonceStr];     // 获取32位内的随机串, 防重发
    self.traceId = [self genTraceId];       // 获取商家对用户的唯一标识
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:WXAppId forKey:@"appid"];
    [params setObject:WXAppKey forKey:@"appkey"];
    [params setObject:self.timeStamp forKey:@"noncestr"];
    [params setObject:self.timeStamp forKey:@"timestamp"];
    [params setObject:self.traceId forKey:@"traceid"];
    [params setObject:[self genPackage] forKey:@"package"];
    [params setObject:[self genSign:params] forKey:@"app_signature"];
    [params setObject:@"sha1" forKey:@"sign_method"];
    
    return params;
}

#pragma mark - 支付结果
- (void)getOrderPayResult:(NSNotification *)notification
{
    [_contentView hideProgressHUDWithAnimated:NO];
    if ([notification.object isEqualToString:@"success"])
    {
//        MDMDishDetailVC *dishDetailVC = [[MDMDishDetailVC alloc] init];
////        dishDetailVC.cartID = cartID;
//        [self.navigationController pushViewController:dishDetailVC animated:YES];
        UINavigationController *navC = self.navigationController;
        if ([_payforViewController isKindOfClass:[MDMDishDetailVC class]])
        {
            [navC popToViewController:_payforViewController animated:YES];
        }
        else if ([_payforViewController isKindOfClass:[MDMOrderDetailVC class]])
        {
            [navC popToViewController:_payforViewController animated:YES];
        }
        else if ([_payforViewController isKindOfClass:[MDMOrderVC class]])
        {
            [navC popToViewController:_payforViewController animated:NO];
            
            MDMDishDetailVC *dishDetailVC = [[MDMDishDetailVC alloc] init];
            dishDetailVC.cartID = _cartID;
            [navC pushViewController:dishDetailVC animated:YES];
        }
        else if ([_payforViewController isKindOfClass:[MDMHomeVC class]])
        {
            [navC popToViewController:_payforViewController animated:NO];
            
            MDMOrderDetailVC *orderDetailVC = [[MDMOrderDetailVC alloc] init];
            orderDetailVC.orderID = _order_num;
            [navC pushViewController:orderDetailVC animated:YES];
        }
//        NSLog(@"success: 支付成功");
    }
    else
    {
//        NSLog(@"fail: 支付失败");
    }
}

@end
