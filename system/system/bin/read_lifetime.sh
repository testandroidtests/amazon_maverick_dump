#!/system/bin/sh
#
# Copyright (c) 2019 Amazon.com, Inc. or its affiliates.  All rights reserved.
#
# PROPRIETARY/CONFIDENTIAL.  USE IS SUBJECT TO LICENSE TERMS.

lifetime_file_name="/sys/block/mmcblk0/device/life_time";
lifetime=$(<$lifetime_file_name)
setprop sys.amzn_bsp_diag.emmc_lifetime "$lifetime"
