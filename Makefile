# ifeq ($(shell [ -f ./framework/makefiles/common.mk ] && echo 1 || echo 0),0)
# all clean package install::
# 	git submodule update --init
# 	./framework/git-submodule-recur.sh init
# 	$(MAKE) $(MAKEFLAGS) MAKELEVEL=0 $@
# else

LIBRARY_NAME = libapplist
libapplist_OBJC_FILES = ALApplicationList.x ALApplicationTableDataSource.m ALValueCell.m
libapplist_CFLAGS = -I./
libapplist_FRAMEWORKS = UIKit CoreGraphics QuartzCore
libapplist_LIBRARIES = MobileGestalt substrate
libapplist_USE_MODULES = 0

BUNDLE_NAME = AppList
AppList_OBJC_FILES = ALApplicationPreferenceViewController.m
AppList_FRAMEWORKS = UIKit CoreGraphics
AppList_PRIVATE_FRAMEWORKS = Preferences
AppList_LDFLAGS = -L$(FW_OBJ_DIR) -L$(THEOS_OBJ_DIR)
AppList_LIBRARIES = applist
AppList_INSTALL_PATH = /System/Library/PreferenceBundles
AppList_USE_MODULES = 0

ifdef SIMULATOR
TARGET = simulator:clang:11.2:8.0
else #SIMULATOR
TARGET = iphone:clang:11.2:7.0
THEOS_PLATFORM_SDK_ROOT_armv6 = /Applications/Xcode_Legacy.app/Contents/Developer
ifneq ($(wildcard $(THEOS_PLATFORM_SDK_ROOT_armv6)/*),)
THEOS_PLATFORM_SDK_ROOT_armv7 = /Volumes/Xcode/Xcode.app/Contents/Developer
THEOS_PLATFORM_SDK_ROOT_armv7s = /Volumes/Xcode/Xcode.app/Contents/Developer
THEOS_PLATFORM_SDK_ROOT_arm64 = /Volumes/Xcode_9.4.1/Xcode.app/Contents/Developer
SDKVERSION_armv6 = 5.1
INCLUDE_SDKVERSION_armv6 = latest
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION_armv6 = 3.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION_armv7 = 3.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION_armv7s = 6.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64 = 7.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64e = 8.4
IPHONE_ARCHS = armv6 armv7 arm64 arm64e
libapplist_IPHONE_ARCHS = armv6 armv7 armv7s arm64 arm64e
else
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.4
IPHONE_ARCHS = armv7 arm64 arm64e
libapplist_IPHONE_ARCHS = armv7 armv7s arm64 arm64e
ifeq ($(FINALPACKAGE),1)
$(error Building final package requires a legacy Xcode install!)
endif
endif
endif #SIMULATOR

ifeq ($(THEOS_CURRENT_ARCH),armv6)
GO_EASY_ON_ME=1
endif

ADDITIONAL_CFLAGS = -Ipublic -Ioverlayheaders -I. -Wno-error=deprecated-declarations

TWEAK_NAME = Applist

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/library.mk
include $(THEOS)/makefiles/bundle.mk
ifdef SIMULATOR
include $(THEOS)/makefiles/locatesim.mk
endif

stage::
	mkdir -p $(THEOS_STAGING_DIR)/usr/include/AppList
	$(ECHO_NOTHING)rsync -a ./public/* $(THEOS_STAGING_DIR)/usr/include/AppList $(FW_RSYNC_EXCLUDES)$(ECHO_END)

ifdef SIMULATOR
after-stage::
	@rm $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/AppList.dylib
	@cp $(THEOS_STAGING_DIR)/usr/lib/libapplist.dylib $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/AppList.dylib
endif

setup::
	#lib
	@[ -f /usr/lib/$(LIBRARY_NAME).dylib ] || sudo ln -s $(PL_SIMJECT_ROOT)/usr/lib/$(LIBRARY_NAME).dylib /usr/lib/$(LIBRARY_NAME).dylib || true
	@[ -f /usr/lib/$(LIBRARY_NAME).dylib ] || echo -e "\x1b[1;35m>> warning: create symlink in /usr/lib yourself\x1b[m" || true

remove::
	#lib
	@sudo rm -f /usr/lib/$(LIBRARY_NAME).dylib