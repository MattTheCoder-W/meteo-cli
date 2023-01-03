#!/bin/bash

# Dependencies:
# - ueberzug
# - wget
# - imagemagick

# Author:
# MattTheCoder-W

VERSION="0.0.1"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	cache="/home/$USER/.cache/meteo";
	OS="linux";
elif [[ "$OSTYPE" == "darwin"* ]]; then
	cache="/Users/$USER/.cache/meteo";
	OS="mac";
else
	echo "[error] Your are running unsupported OS";
	exit;
fi

# ==================
# Prepare enviroment
# ==================

# Cache directory
if [[ ! -d "$cache" ]]; then
    echo "[info] creating cache directory; \`$cache\` ";
    if mkdir -p $cache; then
        echo "[success] cache directory created!"
    else
        echo "[error] cannot create cache directory. Check home dircetory write permissions!"
        exit
    fi
fi

# User configuration file
if [[ ! -f "$cache/meteo.conf" ]]; then
    echo "[info] creating default configuration file";
    if touch $cache/meteo.conf; then
        echo "[success] created config file";
    else
        echo "[error] cannot create config file. Check write permissions.";
        exit;
    fi
fi

# Prepare legend
legend_url="https://www.meteo.pl/um/metco/leg_um_pl_cbase_256.png";
if [[ ! -f "$cache/legend.png" ]]; then
    echo "[info] downloading legend image from \`$legend_url\`";
    if wget "$legend_url" -O $cache/legend.png --quiet; then
        echo "[success] downloaded legend image";
    else
        echo "[error] cannot download legend file. Check your internet connection or check URL manually.";
        exit;
    fi
fi

# Select region
if [[ ! -z ${region+x} ]]; then
    echo "[info] no region is selected. Preparing region selection wizard...";
fi

# Download chart
chart_url="https://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=DATE12&row=341&col=206&lang=pl";
datenow=$(date +%Y%m%d);
chart_url=$(echo $chart_url | sed -e "s/DATE/${datenow}/");

echo "[info] downloading weather chart from \`$chart_url\`";
if wget "$chart_url" -O $cache/chart.png --quiet; then
    echo "[success] downloaded chart"
else
    echo "[error] cannot downlad chart. Check your internet connection";
    exit
fi

# Join images
if convert +append $cache/legend.png $cache/chart.png $cache/weather.png; then
    echo "[success] joined images";
else
    echo "[error] cannot join images. Make sure you have installed imagemagick";
fi

# Display image

if [[ "$OS" == "linux" ]]; then
	source "`ueberzug library`"
	ImageLayer 0< <(
	ImageLayer::add [identifier]="example" [x]="0" [y]="0" [max_width]="$(tput cols)" [max_height]="$(tput lines)" [path]="$cache/weather.png"
	    read
	)
else
	open $cache/weather.png;
fi
