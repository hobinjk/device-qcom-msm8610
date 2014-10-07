TARGET_USES_QCOM_BSP := true
TARGET_USES_QCA_NFC := true

ifeq ($(TARGET_USES_QCOM_BSP), true)
# Add QC Video Enhancements flag
TARGET_ENABLE_QC_AV_ENHANCEMENTS := true
endif #TARGET_USES_QCOM_BSP

DEVICE_PACKAGE_OVERLAYS := device/qcom/msm8610/overlay

#TARGET_DISABLE_DASH := true
#TARGET_DISABLE_OMX_SECURE_TEST_APP := true

ifeq ($(TARGET_ENABLE_QC_AV_ENHANCEMENTS), true)
# media_profiles and media_codecs xmls for 8610
PRODUCT_COPY_FILES += device/qcom/msm8610/media/media_codecs_8610.xml:system/etc/media_codecs.xml
ifeq ($(TARGET_USES_265MB_CONFIG), true)
PRODUCT_COPY_FILES += device/qcom/msm8610/media/media_profiles_8610_256MB.xml:system/etc/media_profiles.xml
else
PRODUCT_COPY_FILES += device/qcom/msm8610/media/media_profiles_8610.xml:system/etc/media_profiles.xml
endif #TARGET_USES_265MB_CONFIG
endif #TARGET_ENABLE_QC_AV_ENHANCEMENTS

$(call inherit-product, frameworks/native/build/phone-hdpi-512-dalvik-heap.mk)
$(call inherit-product, device/qcom/common/common.mk)

PRODUCT_PROPERTY_OVERRIDES += \
       ro.moz.omx.hw.max_width=1280 \
       ro.moz.omx.hw.max_height=720 \

PRODUCT_NAME := msm8610
PRODUCT_DEVICE := msm8610

PRODUCT_BOOT_JARS += qcmediaplayer:oem-services:qcom.fmradio:org.codeaurora.Performance:vcard

# Audio configuration file
PRODUCT_COPY_FILES += \
    device/qcom/msm8610/audio_policy.conf:system/etc/audio_policy.conf \
    device/qcom/msm8610/audio_effects.conf:system/vendor/etc/audio_effects.conf \
    device/qcom/msm8610/mixer_paths.xml:system/etc/mixer_paths.xml

PRODUCT_PACKAGES += \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libqcompostprocbundle

# Bluetooth configuration files
PRODUCT_COPY_FILES += \
    system/bluetooth/data/main.le.conf:system/etc/bluetooth/main.conf

#fstab.qcom
PRODUCT_PACKAGES += fstab.qcom
PRODUCT_COPY_FILES += \
    device/qcom/msm8610/WCNSS_qcom_cfg.ini:system/etc/wifi/WCNSS_qcom_cfg.ini \
    device/qcom/msm8610/WCNSS_qcom_wlan_nv.bin:persist/WCNSS_qcom_wlan_nv.bin

#ANT stack
PRODUCT_PACKAGES += \
    AntHalService \
    libantradio \
    antradio_app

PRODUCT_PACKAGES += \
    wpa_supplicant_overlay.conf \
    p2p_supplicant_overlay.conf

PRODUCT_PACKAGES += wcnss_service

# Sensors feature definition file/s
PRODUCT_COPY_FILES += \
   frameworks/native/data/etc/android.hardware.sensor.barometer.xml:system/etc/permissions/android.hardware.sensor.barometer.xml

# Enable strict operation
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.strict_op_enable=false

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.whitelist=/system/etc/whitelist_appops.xml

PRODUCT_COPY_FILES += \
    device/qcom/msm8610/whitelist_appops.xml:system/etc/whitelist_appops.xml

# NFC packages
ifeq ($(TARGET_USES_QCA_NFC),true)
NFC_D := true

ifeq ($(NFC_D), true)
    PRODUCT_PACKAGES += \
        libnfcD-nci \
        libnfcD_nci_jni \
        nfc_nci.msm8610 \
        NfcDNci \
        Tag \
        com.android.nfc_extras \
        com.android.nfc.helper
else
    PRODUCT_PACKAGES += \
    libnfc-nci \
    libnfc_nci_jni \
    nfc_nci.msm8610 \
    NfcNci \
    Tag \
    com.android.nfc_extras
endif

# file that declares the MIFARE NFC constant
# Commands to migrate prefs from com.android.nfc3 to com.android.nfc
# NFC access control + feature files + configuration
PRODUCT_COPY_FILES += \
        packages/apps/Nfc/migrate_nfc.txt:system/etc/updatecmds/migrate_nfc.txt \
        frameworks/native/data/etc/com.nxp.mifare.xml:system/etc/permissions/com.nxp.mifare.xml \
        frameworks/native/data/etc/com.android.nfc_extras.xml:system/etc/permissions/com.android.nfc_extras.xml \
        frameworks/native/data/etc/android.hardware.nfc.xml:system/etc/permissions/android.hardware.nfc.xml
endif # BOARD_HAVE_QCA_NFC

# Gecko low-memory killer setting overrides
#
# It would be nice to use PRODUCT_COPY_FILES here instead but that is not
# currently possible due to various |rm -rf ...| commands in
# {gaia,gonk-misc}/Android.mk that Make does not know about.
#
out/target/product/$(TARGET_PRODUCT)/system/gecko: gaia/profile/defaults/pref/lmk.js
.PHONY: gaia/profile/defaults/pref/lmk.js
gaia/profile/defaults/pref/lmk.js: gaia/profile.tar.gz
	echo 'pref("hal.processPriorityManager.gonk.BACKGROUND.KillUnderKB", 10240);' > $@
	echo 'pref("hal.processPriorityManager.gonk.notifyLowMemUnderKB", 9216);' >> $@

# Target-specific Gaia configuration
LOCAL_PATH:=$(dir $(firstword $(MAKEFILE_LIST)))
GAIA_DISTRIBUTION_SRC_FILES:=$(GAIA_DISTRIBUTION_SRC_FILES)
GAIA_DISTRIBUTION_SRC_FILES+=$(wildcard $(LOCAL_PATH)/gaia_distribution/*)
