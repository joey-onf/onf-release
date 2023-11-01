#!/bin/bash
## -----------------------------------------------------------------------
## Intent: Gather release version information from helm charts.
##   1) gather Chart.yaml
##   2) Extract repository name from path
##   3) Extract version string
## -----------------------------------------------------------------------

declare -a -g errors=()

## -----------------------------------------------------------------------
## Intent: Display an error message then exit.
## -----------------------------------------------------------------------
function error()
{
    echo "${BASH_SOURCE[1]} ERROR: $*"
    exit 1
}


##----------------##
##---]  MAIN  [---##
##----------------##
[[ $# -eq 0 ]] && { echo "ERROR: sandbox path is required"; exit 1; }
sbx="$1"; shift

pushd "$sbx" || { error "pushd failed: $sbx"; }

# gather
/bin/pwd
readarray -t charts < <(find '.' -name 'Chart.yaml')
[[ ${#charts} -eq  0 ]] && { error "No charts found in $sbx"; }

for chart in "${charts[@]}";
do
    # extract repo name
    readarray -d'/' -t fields <<<"$chart"
    repo="${fields[*]: -2:1}"  # fields[-2]

    echo "CHART: $chart"
    readarray -t app_ver < <(\
			     grep --no-filename -i appVersion "$chart" \
				 | awk -F\# '{print $1}' \
				 | grep -i appversion	 \
				 | cut -d: -f2- \
	)
    declare -p app_ver
done

popd || { error "popd failed: $sbx"; }

# | xargs grep -i appVersion | awk -F\# '{print $1}' | grep -i appversion | tr ':' '\t' find sandbox/ -name 'Chart.yaml'

# [EOF]
