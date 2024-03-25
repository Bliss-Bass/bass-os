-include vendor/bass/apps.mk

# Common Overlays
DEVICE_PACKAGE_OVERLAYS += vendor/bass/overlay/common

# Allow overlays to be excluded from enforcing RRO
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/bass/overlay/common

# Define property overrides we want to enforce
PRODUCT_PROPERTY_OVERRIDES := \
    persist.logd.size=8388608 \
    persist.logd.size.radio="4M" \
    persist.logd.size.system="4M" \
    persist.logd.size.crash="1M"

# Bootanimation
TARGET_SCREEN_WIDTH ?= 800
TARGET_SCREEN_HEIGHT ?= 800
PRODUCT_PACKAGES += \
    bootanimation.zip

# packages we like
PRODUCT_PACKAGES += \
    nano

ifeq ($(USE_PER_DISPLAY_FOCUS),true)

PRODUCT_PACKAGES += \
    MultiDisplay

ifeq ($(USE_PER_DISPLAY_FOCUS_ZQY_IME),true)

PRODUCT_PACKAGES += \
    zqyMultiClientInputMethod

PRODUCT_PROPERTY_OVERRIDES += \
    persist.debug.multi_client_ime=com.zqy.multidisplayinput/.MultiClientInputMethod \
    ro.sys.multi_client_ime=com.zqy.multidisplayinput/.MultiClientInputMethod
else

    nozqyime=true

endif

ifeq ($(USE_PER_DISPLAY_FOCUS_IME),true)
PRODUCT_PACKAGES += \
    MultiClientInputMethod

PRODUCT_PROPERTY_OVERRIDES += \
    persist.debug.multi_client_ime=com.example.android.multiclientinputmethod/.MultiClientInputMethod \
    ro.sys.multi_client_ime=com.example.android.multiclientinputmethod/.MultiClientInputMethod

else

    nomcime=true

endif

# if nozqyime and nomcime are true, then we have no ime
ifeq ($(nozqyime),true)
ifeq ($(nomcime),true)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.boot.bliss.force_ime_on_all_displays=true

endif
endif

endif

ifeq ($(USE_MOUSE_PRESENTATION),true)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.boot.bliss.mouse.presentation=1 

endif

ifeq ($(FORCE_NAVBAR_ON_SECONDARY_DISPLAYS),true)
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.boot.force.navbar_on_secondary_displays=1

endif

ifeq ($(FORCE_STATUS_BAR_ON_SECONDARY_DISPLAYS),true)
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.boot.force.statusbar_on_secondary_displays=1

endif

ifeq ($(USE_BLISS_SETUPWIZARD), true)
PRODUCT_PACKAGES += \
    BlissSetupWizard \
    LineageSetupWizard

# SeedVault
PRODUCT_PACKAGES += \
    Seedvault \
    BasicDreams \

endif

# Bliss Ethernet Manager
ifeq ($(USE_BLISS_ETHERNET_MANAGER), true)
PRODUCT_PACKAGES += \
    BlissEthernetManagerApp

endif

# Bliss Power Manager
ifeq ($(USE_BLISS_POWER_MANAGER), true)
PRODUCT_PACKAGES += \
    BlissPowerManagerApp

endif

# Bliss Kiosk App
ifeq ($(USE_BLISS_KIOSK_LAUNCHER), true)

PRODUCT_PACKAGES += \
    BlissKioskLauncher

endif

# Bliss Restricted Launcher
ifeq ($(USE_BLISS_RESTRICTED_LAUNCHER), true)

PRODUCT_PACKAGES += \
    BlissRestrictedLauncher

endif

# Add any extra packages
ifneq ($(BLISS_BUILD_EXTRA_PACKAGES),)
    PRODUCT_PACKAGES += $(BLISS_BUILD_EXTRA_PACKAGES)
endif

ifeq ($(FORCE_RIGHT_MOUSE_AS_BACK),true)
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.boot.force.right_mouse_as_back=true

endif

# Secure ADB defaults
ifeq ($(BLISS_BUILD_SECURE_ADB), true)
    PRODUCT_PROPERTY_OVERRIDES += \
        persist.usb.debug=0 \
		persist.adb.notify=1 \
		persist.sys.usb.config="mtp" \
		ro.secure=1 \
		service.adb.root=0 \
		persist.sys.root_access=0 \
		persist.service.adb.enable=0 \
		service.adb.tcp.port=5555

endif

ifneq ($(TARGET_BUILD_VARIANT),user)
    ifneq ($(BLISS_BUILD_SECURE_ADB),true)
        # Disable ADB authentication
        PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
            ro.adb.secure=0 
    else
        # Enable ADB authentication
        PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
            ro.adb.secure=1
    endif
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.adb.secure=1
endif

ifeq ($(INCLUDE_AGPRIVAPPS), true)
include vendor/ag_privapp/ag_privapp.mk
endif

# Copy any Permissions files, overriding anything if needed
$(foreach f,$(wildcard $(LOCAL_PATH)/permissions/*.xml),\
    $(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/$(notdir $f)))
