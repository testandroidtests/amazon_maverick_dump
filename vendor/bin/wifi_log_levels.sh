#!/system/bin/sh
## Copyright (c) 2017 - 2019 Amazon.com, Inc. or its affiliates. All rights reserved.
##
## PROPRIETARY/CONFIDENTIAL. USE IS SUBJECT TO LICENSE TERMS.
LOGSRC="wifi"
LOGNAME="wifi_log_levels"
METRICSTAG="metrics.$LOGNAME"
LOGCATTAG="main.$LOGNAME"
DELAY=120
LOOPSTILMETRICS=29 # Should send to metrics buffer every hour
currentLoop=0
IWPRIV=/vendor/bin/iwpriv

if [ ! -x $IWPRIV ] ; then
	exit
fi

function set_wlan_interface ()
{
	WLAN_INTERFACE=`getprop wifi.interface`
}

function iwpriv_conn_status ()
{
	IFS=$'\t\n'
	CONN_STATUS1=($($IWPRIV $WLAN_INTERFACE connStatus))

	for line in ${CONN_STATUS1[@]}; do
		case $line in
			"connStatus:"*)
				CONN_STATUS=${line#*\: }
				CONN_STATUS=${CONN_STATUS%% \(*}
				;;
		esac
	done
	unset IFS
}

# Output sample of command "iwpriv wlan0 driver 'ant_switch_test 25'"
#	Status: Connected (AP: Guest[18:64:72:74:42:73])
#	AS_ORIENTATION_TOTAL = 0
#	AS_ORIENTATION_REMAIN = 54
#	AS_ORIENTATION_DISCONNECT = 1
#	AS_ORIENTATION_SCAN = 1
#	AS_ORIENTATION_STRONG = 21
#	AS_ORIENTATION_SUCCESS = 0
#	AS_ORIENTATION_SWITCHBACK = 0
#	AS_SCAN_TOTAL = 21
#	AS_SCAN_CURRENT_NORSP = 0
#	AS_SCAN_TARGET_NORSP = 0
#	AS_SWITCH_TOTAL = 0
#	AS_SWITCH_BTBUSY = 0
#	AS_SWITCH_TIMEOUT = 0
#	AS_SWITCH_WRONGANT = 0
#	AS_SWITCH_OTHER = 0
function iwpriv_ant_switch_tokens ()
{
	IFS=$'\t\n'
	STAT=($($IWPRIV $WLAN_INTERFACE driver "ant_switch_test 25"))

	for line in ${STAT[@]}; do
		case $line in
			"AS_ORIENTATION_REMAIN"*)
				ORIENTATION_REMAIN=`expr ${line#*= } + $ORIENTATION_REMAIN`
				;;
			"AS_ORIENTATION_DISCONNECT"*)
				ORIENTATION_DISCONNECT=`expr ${line#*= } + $ORIENTATION_DISCONNECT`
				;;
			"AS_ORIENTATION_SCAN"*)
				ORIENTATION_SCAN=`expr ${line#*= } + $ORIENTATION_SCAN`
				;;
			"AS_ORIENTATION_STRONG"*)
				ORIENTATION_STRONG=`expr ${line#*= } + $ORIENTATION_STRONG`
				;;
			"AS_ORIENTATION_SUCCESS"*)
				ORIENTATION_SUCCESS=`expr ${line#*= } + $ORIENTATION_SUCCESS`
				;;
			"AS_ORIENTATION_SWITCHBACK"*)
				ORIENTATION_SWITCHBACK=`expr ${line#*= } + $ORIENTATION_SWITCHBACK`
				;;
			"AS_SCAN_TOTAL"*)
				SCAN_TOTAL=`expr ${line#*= } + $SCAN_TOTAL`
				;;
			"AS_SCAN_CURRENT_NORSP"*)
				SCAN_CURRENT_NORSP=`expr ${line#*= } + $SCAN_CURRENT_NORSP`
				;;
			"AS_SCAN_TARGET_NORSP"*)
				SCAN_TARGET_NORSP=`expr ${line#*= } + $SCAN_TARGET_NORSP`
				;;
			"AS_SWITCH_TOTAL"*)
				SWITCH_TOTAL=`expr ${line#*= } + $SWITCH_TOTAL`
				;;
			"AS_SWITCH_BTBUSY"*)
				SWITCH_BTBUSY=`expr ${line#*= } + $SWITCH_BTBUSY`
				;;
			"AS_SWITCH_TIMEOUT"*)
				SWITCH_TIMEOUT=`expr ${line#*= } + $SWITCH_TIMEOUT`
				;;
			"AS_SWITCH_WRONGANT"*)
				SWITCH_WRONGANT=`expr ${line#*= } + $SWITCH_WRONGANT`
				;;
			"AS_SWITCH_OTHER"*)
				SWITCH_OTHER=`expr ${line#*= } + $SWITCH_OTHER`
				;;
		esac
	done

	unset IFS
}

# Output sample of command "iwpriv wlan0 stat"
#	Tx success = 88561
#	Tx retry count = 16387
#	Tx fail to Rcv ACK after retry = 0
#	Rx success = 31032
#	Rx with CRC = 3774376
#	Rx drop due to out of resource = 0
#	Rx duplicate frame = 0
#	False CCA(total) =
#	False CCA(one-second) =
#	RSSI = -52
#	P2P GO RSSI =
#	SNR-A =
#	SNR-B (if available) =
#	NoiseLevel-A =
#	NoiseLevel-B =
#
#	[STA] connected AP MAC Address = 18:64:72:74:42:7c
#	PhyMode:802.11n
#	RSSI =
#	Last TX Rate = 65000000
#	Last RX Rate = 65000000
function iwpriv_stat_tokens ()
{
	IFS=$'\t\n'
	STAT=($($IWPRIV $WLAN_INTERFACE stat))

	for line in ${STAT[@]}; do
		case $line in
			"Tx success"*)
				TXFRAMES=${line#*= }
				;;
			"Tx retry count"*)
				TXRETRIES=${line#*= }
				TXRETRIES=${TXRETRIES%,*}
				TXPER=${line#*PER=}
				;;
			"Tx fail to Rcv ACK after retry"*)
				TXRETRYNOACK=${line#*= }
				TXRETRYNOACK=${TXRETRYNOACK%,*}
				TXPLR=${line#*PLR=}
				;;
			"Rx success"*)
				RXFRAMES=${line#*= }
				;;
			"Rx with CRC"*)
				RXCRC=${line#*= }
				RXCRC=${RXCRC%,*}
				RXPER=${line#*PER=}
				;;
			"Rx drop due to out of resource"*)
				RXDROP=${line#*= }
				;;
			"Rx duplicate frame"*)
				RXDUP=${line#*= }
				;;
			"False CCA(total)"*)
				TOTALCCA=${line#*= }
				;;
			"False CCA(one-second)"*)
				ONECCA=${line#*= }
				;;
			"RSSI"*)
				if [ "$HADRSSI" -eq 0 ]; then
					RSSI=${line#*= }
					HADRSSI=1
				fi
				;;
			"PhyRate:"*)
				if [ "$HADPHYRATE" -eq 0 ] ; then
					PHYRATE=${line#*PhyRate:}
				fi
				HADPHYRATE=1
				;;
			"PhyMode:"*)
				if [ "$HADPHYRATE" -eq 0 ] ; then
					PHYMODE=${line#*PhyMode:}
				fi
				HADPHYMODE=1
				;;
			"Last TX Rate"*)
				if [ "$HADLASTTXRATE" -eq 0 ]; then
					LASTTXRATE=${line#*= }
					HADLASTTXRATE=1
				fi
				;;
			"Last RX Rate"*)
				if [ "$HADLASTRXRATE" -eq 0 ]; then
					LASTRXRATE=${line#*= }
					HADLASTRXRATE=1
				fi
				;;
			"SNR-A"*)
				SNRA=${line#*= }
				;;
			"SNR-B"*)
				SNRB=${line#*= }
				;;
			"NoiseLevel-A"*)
				NOISEA=${line#*= }
				;;
			"NoiseLevel-B"*)
				NOISEB=${line#*= }
				;;
		esac
	done

	unset IFS
}

# Output sample of command "iwpriv wlan0 get_int_stat"
#	Abnormal Interrupt:0
#	Software Interrupt:0
#	TX Interrupt:25
#	RX data:23
#	RX Event:39
#	RX mgmt:0
#	RX others:0
function iwpriv_int_stat_tokens ()
{
	IFS=$'\t\n'
	INTSTAT=($($IWPRIV $WLAN_INTERFACE get_int_stat))

	for line in ${INTSTAT[@]}; do
		case $line in
			"Abnormal Interrupt"*)
				ABNORMALINT=${line#*:}
				;;
			"Software Interrupt"*)
				SOFTINT=${line#*:}
				;;
			"TX Interrupt"*)
				TXINT=${line#*:}
				;;
			"RX data"*)
				RXDATAINT=${line#*:}
				;;
			"RX Event"*)
				RXEVENTINT=${line#*:}
				;;
			"RX mgmt"*)
				RXMGMTINT=${line#*:}
				;;
			"RX others"*)
				RXOTHERINT=${line#*:}
				;;
		esac
	done

	unset IFS
}

function get_max_signal_stats
{
	maxRssi=$RSSI
	maxNoise=$NOISEA

	if [[ "$maxRssi" -ne 0 && "$maxNoise" -ne 0 ]] ; then
		maxSnr=$(($maxRssi - $maxNoise))
	fi
}

function iwpriv_show_channel
{
	IFS=$'\t\n'
	#wlan
	WLANCHANNEL=($($IWPRIV $WLAN_INTERFACE show_Channel))
	WLANCHANNEL=${WLANCHANNEL#* }
        WLANCHANNEL=${WLANCHANNEL#*show_Channel:}
        unset IFS
}

function log_metrics_phymode
{
	if [ "$PHYMODE" ] ; then
		mode=${PHYMODE#802.*}
		mode=${mode%% *}
		# There's a bug where 5 GHz 11a is marked as 11g.
		if [[ "$mode" == "11g" && $CHANNEL -gt 14 ]] ; then
			mode="11a"
		fi
		logStr="$LOGSRC:$LOGNAME:WifiMode$mode=1;CT;1:NR"
		log -t $METRICSTAG $logStr

		width=${PHYMODE#* }
		width=${width%Mhz*}"MHz"
		logStr="$LOGSRC:$LOGNAME:ChannelBandwidth$width=1;CT;1:NR"
		log -t $METRICSTAG $logStr
	fi
}

function log_metrics_rssi
{
	# dev rssi
	if [ "$maxRssi" -eq 0 ]; then
		return 0
	fi
	logStr="$LOGSRC:$LOGNAME:RssiLevel$maxRssi=1;CT;1:NR"
	log -t $METRICSTAG $logStr
}

function log_metrics_snr
{
	# dev snr
	if [ "$maxSnr" ]; then
		logStr="$LOGSRC:$LOGNAME:SnrLevel$maxSnr=1;CT;1:NR"
		log -t $METRICSTAG $logStr
	fi
}

function log_metrics_noise
{
	# dev noise
	if [ "$maxNoise" -eq 0 ]; then
		return 0
	fi
	logStr="$LOGSRC:$LOGNAME:NoiseLevel$maxNoise=1;CT;1:NR"
	log -t $METRICSTAG $logStr
}

function log_metrics_mcs
{
	#dev mcs
	mcs=${LASTRXRATE/,*/}
	if [ "$mcs" ] ; then
		logStr="$LOGSRC:$LOGNAME:$mcs=1;CT;1:NR"
		log -t $METRICSTAG $logStr
	fi
}

function log_connstatus_metrics
{
	if [[ $CONN_STATUS = "Connected" ]]; then
		logStr="$LOGSRC:$LOGNAME:ConnStatusConnected=1;CT;1;NR"
	elif [[ $CONN_STATUS = "Not connected" ]]; then
		logStr="$LOGSRC:$LOGNAME:ConnStatusDisconnected=1;CT;1;NR"
	else
		logStr="$LOGSRC:$LOGNAME:ConnStatusOther=1;CT;1;NR"
	fi
	log -t $METRICSTAG $logStr
}

function log_kdm_ant_switch_metrics
{
	if [ "${ORIENTATION_REMAIN}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=orient_total;DV;1,Counter=${ORIENTATION_REMAIN};CT;1,unit=counter;DV;1,metadata=!{"d"#{"type"#"fail"$"reason"#"remain"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${ORIENTATION_DISCONNECT}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=orient_total;DV;1,Counter=${ORIENTATION_DISCONNECT};CT;1,unit=counter;DV;1,metadata=!{"d"#{"type"#"fail"$"reason"#"disconnect"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${ORIENTATION_SCAN}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=orient_total;DV;1,Counter=${ORIENTATION_SCAN};CT;1,unit=counter;DV;1,metadata=!{"d"#{"type"#"fail"$"reason"#"scan"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${ORIENTATION_STRONG}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=orient_total;DV;1,Counter=${ORIENTATION_STRONG};CT;1,unit=counter;DV;1,metadata=!{"d"#{"type"#"success"$"reason"#"strong"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${ORIENTATION_SUCCESS}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=orient_total;DV;1,Counter=${ORIENTATION_SUCCESS};CT;1,unit=counter;DV;1,metadata=!{"d"#{"type"#"success"$"reason"#"success"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${ORIENTATION_SWITCHBACK}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=orient_total;DV;1,Counter=${ORIENTATION_SWITCHBACK};CT;1,unit=counter;DV;1,metadata=!{"d"#{"type"#"success"$"reason"#"switchback"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${SCAN_TOTAL}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=scan_total;DV;1,Counter=`expr ${SCAN_TOTAL} - ${SCAN_CURRENT_NORSP} - ${SCAN_TARGET_NORSP}`;CT;1,unit=counter;DV;1,metadata=!{"d"#{"reason"#"normal"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${SCAN_CURRENT_NORSP}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=scan_total;DV;1,Counter=${SCAN_CURRENT_NORSP};CT;1,unit=counter;DV;1,metadata=!{"d"#{"reason"#"current_noresp"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${SCAN_TARGET_NORSP}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=scan_total;DV;1,Counter=${SCAN_TARGET_NORSP};CT;1,unit=counter;DV;1,metadata=!{"d"#{"reason"#"target_noresp"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${SWITCH_BTBUSY}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=switch_total;DV;1,Counter=${SWITCH_BTBUSY};CT;1,unit=counter;DV;1,metadata=!{"d"#{"reason"#"btbusy"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${SWITCH_TIMEOUT}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=switch_total;DV;1,Counter=${SWITCH_TIMEOUT};CT;1,unit=counter;DV;1,metadata=!{"d"#{"reason"#"timeout"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${SWITCH_WRONGANT}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=switch_total;DV;1,Counter=${SWITCH_WRONGANT};CT;1,unit=counter;DV;1,metadata=!{"d"#{"reason"#"wrongant"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi

	if [ "${SWITCH_OTHER}" -ne 0 ]; then
		logStr="wifiKDM:AntSwitch:fgtracking=false;DV;1,key=switch_total;DV;1,Counter=${SWITCH_OTHER};CT;1,unit=counter;DV;1,metadata=!{"d"#{"reason"#"other"}};DV;1:NR"
		log -t $METRICSTAG -v $logStr
	fi
}

function log_wifi_metrics
{
	log_metrics_rssi
	log_metrics_snr
	log_metrics_noise
	log_metrics_mcs
	log_metrics_phymode
	log_kdm_ant_switch_metrics
}

function log_logcat
{
	logStr="$LOGNAME:rssi=$maxRssi;noise=$maxNoise;channel=$WLANCHANNEL;"
	logStr=$logStr"txframes=$TXFRAMES;txretries=$TXRETRIES;txper=$TXPER;txnoack=$TXRETRYNOACK;txplr=$TXPLR;"
	logStr=$logStr"rxframes=$RXFRAMES;rxcrc=$RXCRC;rxper=$RXPER;rxdrop=$RXDROP;rxdup=$RXDUP;"
	logStr=$logStr"falsecca=$TOTALCCA;onesecfalsecca=$ONECCA;"
	logStr=$logStr"phymode=$PHYMODE;phyrate=$PHYRATE;lasttxrate=$LASTTXRATE;lastrxrate=$LASTRXRATE;"
	logStr=$logStr"abnormal_int=$ABNORMALINT;soft_int=$SOFTINT;tx_int=$TXINT;rxdata_int=$RXDATAINT;"
	logStr=$logStr"rxevent_int=$RXEVENTINT;rxmgmt_int=$RXMGMTINT;rxother_int=$RXOTHERINT;"
	log -t $LOGCATTAG $logStr

	log_maxmin_signals
}

# Log the maximum and minimum values regarding signal quality
function log_maxmin_signals
{
	if [[ ! "$PREVIOUS_CHANNEL" ]] ; then
		PREVIOUS_CHANNEL=$CHANNEL
	elif [[ $PREVIOUS_CHANNEL != $CHANNEL ]] ; then
		PREVIOUS_CHANNEL=$CHANNEL
		MAX_RSSI=''
		MIN_RSSI=''
		MAX_NOISE=''
		MIN_NOISE=''
	fi

	if [[ ! "$MAX_RSSI" && ! "$MIN_RSSI" && ! "$maxRssi" -eq 0 ]] ; then
		MAX_RSSI=$maxRssi
		MIN_RSSI=$maxRssi
	fi

	if [[ ! "$MAX_NOISE" && ! "$MIN_NOISE" && ! "$maxNoise" -eq 0 ]] ; then
		MAX_NOISE=$maxNoise
		MIN_NOISE=$maxNoise
	fi

	if [ ! $maxRssi -eq 0 ] ; then
		if [ $maxRssi -gt $MAX_RSSI ] ; then
			MAX_RSSI=$maxRssi
		fi

		if [ $maxRssi -lt $MIN_RSSI ] ; then
			MIN_RSSI=$maxRssi
		fi
	fi

	if [ ! $maxNoise -eq 0 ] ; then
		if [ $maxNoise -gt $MAX_NOISE ] ; then
			MAX_NOISE=$maxNoise
		fi

		if [ $maxNoise -lt $MIN_NOISE ] ; then
			MIN_NOISE=$maxNoise
		fi
	fi

	logStr="$LOGNAME:max_rssi=$MAX_RSSI;min_rssi=$MIN_RSSI;max_noise=$MAX_NOISE;min_noise=$MIN_NOISE;"
	log -t $LOGCATTAG $logStr
}

function clear_stale_stats
{
	RSSI=""
	SNRA=""
	SNRB=""
	NOISEA=""
	NOISEB=""
	LASTRXRATE=""
	PHYMODE=""

	HADLASTRXRATE=0
	HADLASTTXRATE=0
	HADPHYRATE=0
	HADPHYMODE=0
	HADRSSI=0
}

function clear_metric_count
{
	ORIENTATION_TOTAL=0
	ORIENTATION_REMAIN=0
	ORIENTATION_DISCONNECT=0
	ORIENTATION_SCAN=0
	ORIENTATION_STRONG=0
	ORIENTATION_SUCCESS=0
	ORIENTATION_SWITCHBACK=0
	SCAN_TOTAL=0
	SCAN_CURRENT_NORSP=0
	SCAN_TARGET_NORSP=0
	SWITCH_BTBUSY=0
	SWITCH_TIMEOUT=0
	SWITCH_WRONGANT=0
	SWITCH_OTHER=0
}

function run ()
{
	set_wlan_interface

	if [[ -n $WLAN_INTERFACE ]]; then
		iwpriv_show_channel
		iwpriv_ant_switch_tokens
		iwpriv_stat_tokens
		iwpriv_int_stat_tokens
		get_max_signal_stats
		iwpriv_conn_status
		log_logcat

		if [[ $currentLoop -eq $LOOPSTILMETRICS ]] ; then
			iwpriv_conn_status

			if [[ $CONN_STATUS = "Connected" ]]; then
				log_wifi_metrics
				clear_metric_count
			fi
			log_connstatus_metrics
			currentLoop=0
		else
			((currentLoop++))
		fi

		clear_stale_stats
	fi
	# Send commands to driver to reset their counters.
	$($IWPRIV $WLAN_INTERFACE driver "ant_switch_test 26")
}


# Run the collection repeatedly, pushing all output through to the metrics log.
while true ; do
	run
	sleep $DELAY
done
