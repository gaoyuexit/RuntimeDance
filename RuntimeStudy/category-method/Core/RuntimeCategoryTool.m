//
//  CategoryTool.m
//  RuntimeStudy
//
//  Created by zhugefang on 2018/8/20.
//  Copyright © 2018年 zhugefang. All rights reserved.
//

#import "RuntimeCategoryTool.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSInvocation+Arguments.h"

static inline void hardforwardSelectorToInvocation(Class cls,SEL originalSelector){
    IMP toolForwardImp = class_getMethodImplementation([RuntimeCategoryTool class], @selector(forwardInvocation:));
    IMP forwardIMP = (IMP)_objc_msgForward;
    const char *types = "v@:@";
    if (!class_respondsToSelector(cls, @selector(forwardInvocation:))) {
        class_addMethod(cls, @selector(forwardInvocation:), forwardIMP, types);
        class_replaceMethod(cls, @selector(forwardInvocation:), toolForwardImp, types);
    }else{
        class_replaceMethod(cls, @selector(forwardInvocation:), toolForwardImp, types);
    }
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    IMP originalIMP = method_getImplementation(originalMethod);
    NSString *selectorNewAdd = [NSString stringWithFormat:@"category_%@",NSStringFromSelector(originalSelector)];
    class_addMethod(cls, NSSelectorFromString(selectorNewAdd), originalIMP, method_getTypeEncoding(originalMethod));
    class_replaceMethod(cls, originalSelector, forwardIMP, types);
}

@interface  RuntimeCategoryTool ()

@property (nonatomic, strong) NSMutableDictionary *positionMap;

@end

@implementation  RuntimeCategoryTool

+ (instancetype)sharedInstance{
    static  RuntimeCategoryTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ RuntimeCategoryTool alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _positionMap = [NSMutableDictionary dictionary];
    }
    return self;
}

//调用分类方法的时候，会越过分类，直接调用原有的方法。
- (void)callOriginalSelector:(SEL)sel insteadofCategoryInClass:(Class)cls{
    [[ RuntimeCategoryTool sharedInstance].positionMap setObject:@"instead_category" forKey:[NSString stringWithFormat:@"%@_%@",NSStringFromClass(cls),NSStringFromSelector(sel)]];
    hardforwardSelectorToInvocation(cls, sel);
}

- (void)callOriginalSelector:(SEL)sel beforeCategoryInClass:(Class)cls{
    [[ RuntimeCategoryTool sharedInstance].positionMap setObject:@"before_category" forKey:[NSString stringWithFormat:@"%@_%@",NSStringFromClass(cls),NSStringFromSelector(sel)]];
    hardforwardSelectorToInvocation(cls, sel);
}

//调用分类方法之后，会再调用原有的方法
- (void)callOriginalSelector:(SEL)sel afterCategoryInClass:(Class)cls{
    [[ RuntimeCategoryTool sharedInstance].positionMap setObject:@"after_category" forKey:[NSString stringWithFormat:@"%@_%@",NSStringFromClass(cls),NSStringFromSelector(sel)]];
    hardforwardSelectorToInvocation(cls, sel);
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSString *strategy = [[ RuntimeCategoryTool sharedInstance].positionMap valueForKey:[NSString stringWithFormat:@"%@_%@",NSStringFromClass([anInvocation.target class]),NSStringFromSelector(anInvocation.selector)]];
    //调用结束后，需要从map中移除position，只会生效一次
    [[RuntimeCategoryTool sharedInstance].positionMap removeObjectForKey:[NSString stringWithFormat:@"%@_%@",NSStringFromClass([anInvocation.target class]),NSStringFromSelector(anInvocation.selector)]];
    NSArray *args = [anInvocation getAllArguments];
    unsigned int count;
    Method *methodList = class_copyMethodList([anInvocation.target class], &count);
    for (int i = count-1; i>=0; i--) {
        Method method = methodList[i];
        if ([NSStringFromSelector(method_getName(method)) isEqualToString:NSStringFromSelector(anInvocation.selector)]) {
            if ([strategy isEqualToString:@"after_category"]) {
                //调用分类中的方法
                NSString *originalSelName = [NSString stringWithFormat:@"category_%@",NSStringFromSelector(anInvocation.selector)];
                SEL originSel = NSSelectorFromString(originalSelName);
                anInvocation.selector = originSel;
                [anInvocation invoke];
            }
            if (args.count == 0) {
                ((void(*)(id,SEL))method_getImplementation(method))(self,method_getName(method));
            }else if (args.count == 1){
                  ((void(*)(id,SEL,id))method_getImplementation(method))(self,method_getName(method),args[0]);
            }else if (args.count == 2){
                  ((void(*)(id,SEL,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1]);
            }else if (args.count == 3){
                  ((void(*)(id,SEL,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2]);
            }else if (args.count == 4){
                  ((void(*)(id,SEL,id,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2],args[3]);
            }else if (args.count == 5){
                  ((void(*)(id,SEL,id,id,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2],args[3],args[4]);
            }else if (args.count == 6){
                  ((void(*)(id,SEL,id,id,id,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2],args[3],args[4],args[5]);
            }else if (args.count == 7){
                  ((void(*)(id,SEL,id,id,id,id,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
            }else if (args.count == 8){
                  ((void(*)(id,SEL,id,id,id,id,id,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
            }else if (args.count == 9){
                 ((void(*)(id,SEL,id,id,id,id,id,id,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]);
            }else if (args.count == 10){
                 ((void(*)(id,SEL,id,id,id,id,id,id,id,id,id,id))method_getImplementation(method))(self,method_getName(method),args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9]);
            }
            if ([strategy isEqualToString:@"before_category"]) {
                //调用分类中的方法
                NSString *originalSelName = [NSString stringWithFormat:@"category_%@",NSStringFromSelector(anInvocation.selector)];
                SEL originSel = NSSelectorFromString(originalSelName);
                anInvocation.selector = originSel;
                [anInvocation invoke];
            }
            break;
        }
    }
}

@end
