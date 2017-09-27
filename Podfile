#use_frameworks!

target :'FruitMix' do 

platform :ios,’8.0’
pod 'YYWebImage'
pod 'AFNetworking', '~> 3.1.0'
pod 'YYModel'
pod 'YYText'
pod 'YYKeyboardManager'
pod 'YYDispatchQueuePool'
pod 'YYAsyncLayer'
pod 'Masonry'
pod 'MBProgressHUD'
pod 'MWPhotoBrowser', '~> 2.1.1'
pod 'pop'
pod 'FMDB', '~> 2.5'
pod 'CHTCollectionViewWaterfallLayout', '~> 0.9.4'
pod 'MarqueeLabel', '~> 2.7.1'
pod 'CocoaLumberjack'
pod 'BEMCheckBox'
pod 'ReactiveObjC'
pod 'MJRefresh'
pod 'WechatOpenSDK'
end

post_install do |installer|
    
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|
            
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            
        end
        
    end
    
end
