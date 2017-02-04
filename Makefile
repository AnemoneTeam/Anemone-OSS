THEOS_PACKAGE_DIR_NAME = debs
TARGET = iphone:clang:latest:6.0
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = Anemone
Anemone_FILES = Badges.xm Clock.xm Calendar.xm PageDots.xm NoRespring.xm
Anemone_FRAMEWORKS = UIKit CoreGraphics QuartzCore
ifeq ($(NO_OPTITHEME),1)
	Anemone_CFLAGS += -DNO_OPTITHEME
endif
Anemone_OBJ_FILES = UIColor+HTMLColors.mm.obj
Anemone_LDFLAGS = -Wl,-segalign,4000 -lrocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Anemone; sleep 0.2; sblaunch com.anemonetheming.anemone"
else
	install.exec "killall SpringBoard"
endif

#SUBPROJECTS = app uikit core recache colors dock icons iconeffects cardump mask html fonts
SUBPROJECTS = core
#ifneq ($(NO_OPTITHEME),1)
#SUBPROJECTS += anemoneoptimizer
#endif
#SUBPROJECTS += anemonefontpreviewgenerator
include $(THEOS_MAKE_PATH)/aggregate.mk
