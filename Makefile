TARGET := iphone:clang:16.5:15.0
include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = DopamineWallpaper
DopamineWallpaper_FILES = WallpaperHook.m
DopamineWallpaper_CFLAGS = -fobjc-arc -Wall -Wextra
DopamineWallpaper_FRAMEWORKS = UIKit Foundation
DopamineWallpaper_LDFLAGS = -Wl,-install_name,@rpath/DopamineWallpaper.dylib

include $(THEOS_MAKE_PATH)/library.mk
