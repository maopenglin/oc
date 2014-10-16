

#ifndef EAssistant_BKDefine_h
#define EAssistant_BKDefine_h

/**
 *  微信开放平台申请得到的 appid, 需要同时添加在 URL schema
 */
#define WXAppId @"wx2b98634b5cefdc33"

/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
#define WXAppKey @"qxwLKCxKPfioPRk3mq2nBCQSoJn2NKH4nQu8gjPDqa6TyD9N5RizMKMpjDo16QQL32k9CbqQrpojY1qUUc8Ls2GcaLHDNkIElOYbPQi1UQNCGJMI22yBWkeK9Nu1Pd4J"

/**
 * 微信开放平台和商户约定的密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
#define WXAppSecret @"4fa6b7ac291ddaf5acbc0ea83086b339"

/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
#define WXPartnerKey @"cafe4d6a3696ddac39c26c61b9237c61"

/**
 *  微信公众平台商户模块生成的ID
 */
#define WXPartnerId @"1219486601"

#define ORDER_PAY_NOTIFICATION @"OrderPayNotification"

#define AccessTokenKey @"access_token"
#define PrePayIdKey @"prepayid"
#define errcodeKey @"errcode"
#define errmsgKey @"errmsg"
#define expiresInKey @"expires_in"

#endif
