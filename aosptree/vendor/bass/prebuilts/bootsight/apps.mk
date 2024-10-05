PRODUCT_PACKAGES += \
	BootSight \


PRODUCT_COPY_FILES += vendor/bass/prebuilts/bootsight/permissions/com.bliss.bootsight-priv-app-permissions.xml:system/etc/permissions/com.bliss.bootsight-priv-app-permissions.xml

PRODUCT_COPY_FILES += vendor/bass/prebuilts/bootsight/default-permissions/com.bliss.bootsight-default-permissions.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/com.bliss.bootsight-default-permissions.xml

