#!/bin/bash
## -----------------------------------------------------------------------
## Intent: Gather release version information from helm charts.
##   1) gather Chart.yaml
##   2) Dxtract repository name from path
##   3) Extract version string
## -----------------------------------------------------------------------

# gather
readarray -t charts < <(find sandbox/ -name 'Chart.yaml')

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

# | xargs grep -i appVersion | awk -F\# '{print $1}' | grep -i appversion | tr ':' '\t' find sandbox/ -name 'Chart.yaml'

# [EOF]
