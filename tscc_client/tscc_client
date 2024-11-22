#!/usr/bin/env bash
# vim: set filetype=sh tabstop=4 :

module reset -t 2>/dev/null
module load slurm

declare -i E_INVALID_ACCOUNT=1
declare -i E_INVALID_USER=2
declare -i E_INVALID_DATE=3

set -e
#set -x

error_and_exit(){
			printf "ERROR: %s\n" "${2}"
				cleanup_and_exit "${1}"
		}

cleanup_and_exit(){
			/bin/rm -f "${sreport_tmp}" "${sacctmgr_tmp}"
				exit "$1"
		}

usage(){
			echo "Usage: $0 [-h] [[-A account | -d description | -o organization] [-u user|-a] [-i] [-s billing|YYYY-mm-dd] [-e YYYY-mm-dd]" 1>&2
	}

_help(){
			echo "Usage: $0 [-h] [[-A account | -d description | -o organization] [-u user|-a] [-i] [-s YYYY-mm-dd] [-e YYYY-mm-dd]"

				cat <<EOF

				  The $(basename "$0") tool is a wrapper around multiple Slurm and SDC accounting
				    related commands that can provide information about usage and available
  balance for Slurm bank accounts.

  Input Options:

    -h               Display this help information.

    -A account       Provide a single Slurm Account to provide banking
                     information for.

    -d description   Provide a Slurm Account Description substring to gather
                     accounts to provide banking information for.

    -o organization  Provide a Slurm Account Organiziation substring to gather
                     accounts to provide banking information for.

    -u user          Provide a Slurm User to gather accounts to provide
                     banking informations for.

    -a               Specify to provide banking information for all Slurm
                     users in default or specified accounts.

    -i               Ignore users of Slurm bank accounts with no usage during
                     the accounting period.

    -s YYYY-mm-dd |
       billing       Specify a start date for the Slurm accounting period. If
                     no start date is provided the beginning of the current
                     month is used. The special option "billing" will use the
                     start of billing on TSCC as the Start value.

                     NOTE: Slurm sreport default of 00:00:00 for HH:MM:SS for
                     Start parameter is retained.

    -e YYYY-mm-dd    Specify an end date for the Slurm accounting period. If no
                     end date is provided the end of the current month is used.

                     NOTE: Slurm sreport default of HH:59:59 for HH:MM:SS for
                     End parameter where HH is 23 (for previous day) or current
                     HH - 1 is used.

  Notes:

  - Slurm Account Descriptions and Organizations are manually managed by
    the system staff. If they are not correct for a specific Slurm bank
    account please let us know at tscc-support@ucsd.edu.

  - If no Account is specified then all Slurm bank accounts of the user
    running the command are shown.

  - If no specific User or the -a/all users option is not provided only
    the usage of the user running the command is shown.

  - When the -a and -i options are used together all users with usage in the
    specified accounts are shown.

  - Banking reports are only provide for whole days unless the end date is
    for or after the current date. In that case the banking report will
    include usage for the current day up to the end of the previous hour.

  - If/when a start date is not supplied explicitly an appropriate start
    date is chosen for the allocation based on it's HOTEL or CONDO status.
    HOTEL allocations do not have expiration dates and effectively start
    when TSCC 2.0 entered production operations or when they were first 
    created, which ever was earlier. CONDO allocations represent real time
    related to purchased hardware and are reset annually and do not roll
    over year-to-year. The CONDO reset date is the 4th Monday of September.

  EXAMPLE(s):

  - Output for a HOTEL allocation which is shared by multiple individual
    users each with their own independent allowed usage.

  - Remaining balance for each individual user is unique and in proprotion
    to their individual allowed usage with completed usage removed.

  - In this particular case the Account Proportion and Balance (for Account)
    are not meaningful and should be disregarded.


$ tscc_client.sh -A <hotel_account>
======================================================================================================
 TSCC Cluster Utilization from 2024-03-05 until 2024-10-21T16:00:00
======================================================================================================
        bank account: <hotel_account>
         description: indiv-<hotel_account>
        organization: ucsd
          allocation: 3713616288 SUs
            end date: 24-APR-30
           avail QOS: hotel,hotel-gpu,normal
                NOTE: avail QOS for user may differ from account
------------------------------------------------------------------------------------------------------
             Account                                                       Account
             or User          Usage          Allow      Usage/Allow     Proportion        Balance
---------------------   ------------   ------------   --------------   ------------   ------------
     <hotel_account>:        2369636     3713616288          0.063 %      100.000 %     3711246652
---------------------   ------------   ------------   --------------   ------------   ------------
        hotel_user_1:         206574        1119480         18.452 %        8.717 %         912906
        hotel_user_2:            266         111660          0.238 %        0.011 %         111394
        hotel_user_3:         915575        3120000         29.345 %       38.637 %        2204425
        hotel_user_4:          64705        1954620          3.310 %        2.730 %        1889915
        hotel_user_5:          19056         537180          3.547 %        0.804 %         518124
        hotel_user_6:          18275        1823460          1.002 %        0.771 %        1805185
        hotel_user_7:         880941         920640         95.687 %       37.176 %          39699
        hotel_user_8:         235516         286140         82.307 %        9.938 %          50624
        hotel_user_9:          19386         576780          3.361 %        0.818 %         557394
       hotel_user_10:           9342         553020          1.689 %        0.394 %         543678
------------------------------------------------------------------------------------------------------

  - Output for a CONDO allocation which is shared by multiple users under a single PI. All users
    share the entire allocation value and any one user can use up to 100% of the allocation.

  - The remaining balance of the entire allocation is available to each and every user in the
    allocation regardless of how much usage each has incurred.

$ tscc_client.sh -A <condo_account>
======================================================================================================
 TSCC Cluster Utilization from 2024-09-23 until 2024-10-21T15:00:00
======================================================================================================
        bank account: <condo_account>
         description: <condo_account>-group
        organization: ucsd
          allocation: 468556001 SUs
            end date: 21-SEP-25
           avail QOS: condo,condo-gpu,hca-<condo_account>,hcp-<condo_account>,normal
                NOTE: avail QOS for user may differ from account
------------------------------------------------------------------------------------------------------
             Account                                                       Account
             or User          Usage          Allow      Usage/Allow     Proportion        Balance
---------------------   ------------   ------------   --------------   ------------   ------------
     <condo_account>:       19060507      468556001          4.067 %      100.000 %      449495494
---------------------   ------------   ------------   --------------   ------------   ------------
        condo_user_1:             94      468556001          0.000 %        0.000 %      449495494
        condo_user_2:         193391      468556001          0.041 %        1.014 %      449495494
        condo_user_3:           2765      468556001          0.000 %        0.014 %      449495494
        condo_user_4:        2959706      468556001          0.631 %       15.527 %      449495494
        condo_user_5:             93      468556001          0.000 %        0.000 %      449495494
        condo_user_6:       10059085      468556001          2.146 %       52.774 %      449495494
        condo_user_7:        5845372      468556001          1.247 %       30.667 %      449495494
------------------------------------------------------------------------------------------------------

EOF
}

# Defaults
DEF_IFS="${IFS}"
user=""
acct=""
all_accounts="TRUE"
all_users="FALSE"
ignore_no_usage="FALSE"
opt_by_desc="FALSE"
opt_by_org="FALSE"
opt_provide_start="FALSE"
opt_provide_end="FALSE"

# Beginning of TSCC charging was March 5, 2024 at noon.
# charge_start_epoch=1709668800 # -> 2024-03-05T12:00:00
# First CONDO usage reset was Sept 23, 2024 at midnight
# charge_start_epoch=1727074800 # -> 2024-09-23T00:00:00
DEFAULT_HOTEL_CHARGE_START=1709668800
DEFAULT_CONDO_CHARGE_START=1727074800

hotel_charge_start_epoch=${DEFAULT_HOTEL_CHARGE_START}
condo_charge_start_epoch=${DEFAULT_CONDO_CHARGE_START}

# legacy uniformly use the CONDO reset date unless -s is specified
# or allocation is detected as HOTEL
charge_start_epoch=${condo_charge_start_epoch}
charge_start=$(date -d "@${charge_start_epoch}" +%Y-%m-%d)

# Slurm sreport interval begins at 00:00:00 on previous day or specified
# Start date. eg. Start=2024-03-05 will start at 2024-03-05T00:00:00
sreport_start=${charge_start}

# Slurm sreport interval ends at 23:59:59 on previous day. When End is not
# specifed Yesterday is End date. When End is specified End is the date
# before the specified day. eg. End=2024-04-01 will end at 2024-03-31T23:59:59
#
# NOTE: There is a notable exception to the above. When the calculated or
# specified End date is equal to or later than the current date then sreport
# will report utilization only to the end of the previous hour. eg. if the
# current date is 2024-03-24T13:07:19 then the End in the sreport output will
# be 2024-03-24T12:59:59. This means the same interval can provide different
# results if queried before and after the calculated or specified End
# date.
sreport_end=$(date +%Y-%m-%d)

sreport_tmp=$(mktemp -p /var/tmp)
sacctmgr_tmp=$(mktemp -p /var/tmp)

declare -a accounts
declare -a users

# Options
while getopts ":A:d:o:s:e:u:aih" OPTION; do
	case "${OPTION}" in
		A)
			all_accounts="FALSE"
			# parse comma separated account list into array
			acct="${OPTARG}"
			accounts+=("${acct}")
			;;
		d)
			opt_by_desc="TRUE"
			desc_pat="${OPTARG}"
			;;
		o)
			opt_by_org="TRUE"
			org_pat="${OPTARG}"
			;;
		s)
			set +e
			opt_provide_start="TRUE"
			os=${OPTARG}
			if [ "billing" == "${os}" ];
			then
				sreport_start="${charge_start}"
				sreport_end="$(date +%Y-%m-%d)"
			else
				opt_start="$(date --date="${os}" +%Y-%m-%d 2>/dev/null)"
				# shellcheck disable=SC2181
				if [ $? -ne 0 ]; then
					error_and_exit $E_INVALID_DATE "Supplied start date is not a valid date."
				else
					sreport_start="${opt_start}"
                	sreport_end="$(date -d "${sreport_start} +1 month -1 day" +%Y-%m-%d)"
				fi
			fi
			set -e
			;;
					e)
										set +e
													opt_provide_end="TRUE"
																opt_end="$(date --date="${OPTARG}" +%Y-%m-%d 2>/dev/null)"
																			# shellcheck disable=SC2181
																						if [ $? -ne 0 ]; then
																												error_and_exit $E_INVALID_DATE "Supplied end date is not a valid date."
																															else
																																					sreport_end="${opt_end}"
																																								fi
																																											set -e
																																														;;
																																																u)
																																																					all_users="FALSE"
																																																								user="${OPTARG}"
																																																											;;
																																																													a)
																																																																		all_users="TRUE"
																																																																					;;
																																																																							i)
																																																																												ignore_no_usage="TRUE"
																																																																															;;
																																																																																	h)
																																																																																						_help
																																																																																									cleanup_and_exit 0
																																																																																												;;
																																																																																												       	*)
																																																																																																			usage
																																																																																																						cleanup_and_exit 0
																																																																																																									;;
																																																																																																										esac
																																																																																																								done

																																																																																																								# If user requested banking by account description then search for appropriate
																																																																																																								# list of slurm bank accounts.
																																																																																																								if [ "TRUE" == "${opt_by_desc}" ];
																																																																																																								then
																																																																																																											sacctmgr -nP show account format=Account,Description > "${sacctmgr_tmp}"
																																																																																																												readarray -t accts <<< "$(grep -E "${desc_pat}" "${sacctmgr_tmp}" | awk -F\| '{print $1}' | sort -u)"
																																																																																																													all_accounts="FALSE"
																																																																																																														acct="${accts[0]}"
																																																																																																															accounts=("${accts[@]}")
																																																																																																								fi

																																																																																																								# If user requested banking by account org then search for appropriate
																																																																																																								# list of slurm bank accounts.
																																																																																																								if [ "TRUE" == "${opt_by_org}" ];
																																																																																																								then
																																																																																																											sacctmgr -nP show account format=Account,Organization > "${sacctmgr_tmp}"
	readarray -t accts <<< "$(grep -E "${org_pat}" "${sacctmgr_tmp}" | awk -F\| '{print $1}' | sort -u)"
	all_accounts="FALSE"
	acct="${accts[0]}"
	accounts=("${accts[@]}")
																																																																																																								fi

# If user wasn't specified via -u then assume ${USER}
# UNLESS -A is specified.
if [ -z "${user}" ];
then
	if [ -z "${acct}" ];
	then
		user="${USER}"
	else
		# acct is specified
		all_users="TRUE"
	fi
else
	# user is specified
	acct=""
fi

# Obtain Slurm user details...
if [ -n "${user}" ];
then
	IFS="|"
	read -r slurm_user defacct _ <<< "$(sacctmgr -nP show user "${user}")"
	IFS="${DEF_IFS}"

	if [ -z "${slurm_user}" ];
	then
		error_and_exit ${E_INVALID_USER} "Specified user (${user}) must be valid Slurm user with current allocation."
	else
		user="${slurm_user}"
	fi

	if [ "${acct}" != "${defacct}" ];
	then
		acct="${defacct}"
	fi
fi

# Obtains Slurm accounts for Slurm user...
if [ "TRUE" == "${all_accounts}" ];
then
	IFS="|"
	read -r -a slurm_accounts <<< "$(sacctmgr -nP show assoc where user="${user}" format=account | sort -u | grep -Ev "${acct}")"
	IFS="${DEF_IFS}"
	accounts=("${acct}" "${slurm_accounts[@]}")
else
	if [ "FALSE" == "${opt_by_desc}" ] && [ "FALSE" == "${opt_by_org}" ];
	then
		accounts=("${acct}")
	fi
fi
# printf "DEBUG: accounts: %s\n" "${accounts[*]}"

declare -i acct_alloc
declare -i acct_usage
declare -i user_alloc
declare -i user_usage

for acct in "${accounts[@]}"
do
	# Need some error handling here for non-existant accounts
	IFS="|"
	read -r _ desc org <<< "$(sacctmgr -nP show account "${acct}")"
	IFS="${DEF_IFS}"

	if [ -z "${desc}" ];
	then
		error_and_exit ${E_INVALID_ACCOUNT} "Specified account (${acct}) must be valid Slurm account with current allocation."
	fi

	# Obtain account allocation for Slurm account
	read -r acct_alloc <<< "$(sacctmgr -nP show assoc User='' Account="${acct}" format=GrpTRESMins | awk -F= '/billing=/ {print $2}')"

	if [[ 0 -eq ${acct_alloc-0} ]];
	then
		acct_alloc=0
	fi

	# Obtain available QOS list for Slurm account
	read -r acct_qos <<< "$(sacctmgr -nP show assoc User='' Account="${acct}" format=QOS)"

	if [[ -z "${acct_qos}" ]];
	then
		acct_qos="normal"
	fi

	# If user did not provide start with -s option then determine
	# optimal start depending on account type: HOTEL vs CONDO
	if [[ "FALSE" == "${opt_provide_start}" ]];
	then
		if [[ "${acct}" =~ ^htl* ]];
		then
			# account is HOTEL
			charge_start_epoch=${hotel_charge_start_epoch}
		else
			# account is CONDO
			charge_start_epoch=${condo_charge_start_epoch}
		fi
    	sreport_start=$(date -d "@${charge_start_epoch}" +%Y-%m-%d)

		# If user did not provide start or end then determine
		# optimal end as the last hour so that output is current
		# as of latest hourly rollup all accounts. NOTE: This
		# is different than the previous default where end was end
		# of yesterday or day before specified day so that daily
		# rollup value was used and it could be compared with
		# SAM ACL generated value.
		if [[ "FALSE" == "${opt_provide_end}" ]];
		then
			sreport_end=$(date +%Y-%m-%dT%H:00:00)
		fi
	fi

	# Obtain account usage for current period. NOTE: This contains both
	# account and account:user usage. Query only once for each account.
	sreport -nP \
		cluster AccountUtilizationByUser \
		Tree \
		-t minutes \
		-T "billing" \
		-a \
		Accounts="${acct}" \
		Start="${sreport_start}" \
		End="${sreport_end}" \
		format=Accounts%16,Login%30,Used > "${sreport_tmp}"

	# Parse account usage from sreport output
	declare -i au
	IFS='|'
	read -r _ _ au <<< "$(grep -E "${acct}||" "${sreport_tmp}")"
	IFS="${DEF_IFS}"
	if [[ 0 -eq ${au} ]];
	then
		acct_usage=0
	else
		acct_usage="${au}"
	fi

	# Print details for account
	dbl="======================================================================================================"
	sgl="------------------------------------------------------------------------------------------------------"

	# Print header...
	printf "%s\n" "${dbl}"
	printf " TSCC Cluster Utilization from %s until %s\n" "${sreport_start}" "${sreport_end}"
	printf "%s\n" "${dbl}"

	# Print account information...
	printf "        bank account: %s\n" "${acct}"
	printf "         description: %s\n" "${desc}"
	printf "        organization: %s\n" "${org}"
	printf "          allocation: %s SUs\n" "${acct_alloc}"
	acct_end="$(grep ":${acct}:" "$(dirname "${SLURM_CONF}")/acl.out" | awk '{print $10}' | sort -u)"
	printf "            end date: %s\n" "${acct_end}"
	printf "           avail QOS: %s\n" "${acct_qos}"
	printf "                NOTE: avail QOS for user may differ from account\n"
	printf "%s\n" "${sgl}"
	printf "%20s   %12s   %12s   %14s   %12s   %12s\n" \
			"Account" "" "" "" "Account" ""
	printf "%20s   %12s   %12s   %14s   %12s   %12s\n" \
			"or User" "Usage" "Allow" "Usage/Allow" "Proportion" "Balance"
	printf "%20s   %12s   %12s   %14s   %12s   %12s\n" \
			"---------------------" "------------" "------------" "--------------" "------------" "------------"

	acct_pct=$(echo "scale=3; 100 * ${acct_usage-0} / ${acct_alloc}" | bc -l)
	acct_bal="$(echo "scale=1; ${acct_alloc} - ${acct_usage}" | bc -l)"
	printf "%20s:   %12d   %12d     %10.3f %%   %10.3f %%   %12d\n" \
		"${acct}" "${acct_usage}" "${acct_alloc}" "${acct_pct}" "100" "${acct_bal}"
	printf "%20s   %12s   %12s   %14s   %12s   %12s\n" \
			"---------------------" "------------" "------------" "--------------" "------------" "------------"

	# Create a list of users to report for this account.
	# Either the user running the command, the user specified with -u or
	# all users in the account is -a is specified
	if [ "TRUE" == "${all_users}" ]
	then
		read -r -a users <<< "$(sacctmgr -nP show assoc where account="${acct}" format=user | tr '\n' ' ')"
		users=("${users[*]}")
	else
		users=("${user}")
	fi
	# printf "DEBUG: users: %s\n" "${users[*]}"

	# Obtain user associations for Slurm account
	sacctmgr -nP show assoc Account="${acct}" format=Account,User,GrpTRESMins > "${sacctmgr_tmp}"

	# Print user(s) entries
	# shellcheck disable=SC2048
	for u in ${users[*]};
	do
		# Parse user assocation for Slurm account:user tuple
		IFS="|"
		read -r _ _ user_alloc <<< "$(grep "${u}" "${sacctmgr_tmp}")"
		IFS="${DEF_IFS}"

		# If there is no value for GrpTRESMins for account:user then the user share is 100% and _is_ the same as the account alloction
		if [ 0 == ${user_alloc} ];
		then
			user_alloc=${acct_alloc}
		fi

		# NOTE: sreport for a specific user can be empty
		IFS="|"
		read -r _ _ uu <<< "$(grep -E " ${acct}\|${u}" "${sreport_tmp}")"
		IFS="${DEF_IFS}"

		if [ "" == "${uu}" ];
		then
			user_usage=0
		else
			user_usage="${uu}"
		fi

		if [ "${user_alloc}" == "${acct_alloc}" ];
		then
			# default user balance is account balance
			user_bal="${acct_bal}"
		else
		    user_bal="$(echo "${user_alloc} - ${user_usage}" | bc -l)"
		fi

		#read user_usage user_alloc user_pct  <<< "get_user_usage "${user}"
		user_pct=$(echo "scale=3; 100 * ${user_usage-0} / ${user_alloc-0}" | bc -l)
		if [ "${acct_usage-0}" -ne "0" ];
		then
			acct_pct=$(echo "scale=3; 100 * ${user_usage-0} / ${acct_usage-0}" | bc -l)
		else
			acct_pct="0.00"
		fi

		if [ "TRUE" == "${ignore_no_usage}" ] && [ "0" == "${user_usage}" ];
		then
			printf ""
		else
			printf "%20s:   %12d   %12d     %10.3f %%   %10.3f %%   %12d\n" \
				"${u}" "${user_usage}" "${user_alloc}" "${user_pct}" "${acct_pct}" "${user_bal}"
		fi
	done

	# Print footer
	printf "%s\n\n" "${sgl}"

done

cleanup_and_exit 0

