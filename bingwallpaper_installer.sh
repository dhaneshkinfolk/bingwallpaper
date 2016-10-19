#!/bin/sh

# Stop on errors.
set -e

mkdir -p $HOME/.local/bin
cat <<'EOF' > $HOME/.local/bin/bingwallpaper
#!/bin/bash
bing="http://www.bing.com"
api="/HPImageArchive.aspx?"
format="&format=js"
day="&idx=0"
market="&mkt=en-US"
# fetch how many (not really necessary)
const="&n=1"
size="1920x1080"
path="$HOME/Pictures/Bing/"
while [ 1 ]
do
    jsonUrl=$bing$api$format$day$market$const
    imgJson=$(curl -s $jsonUrl)
    imgURL=$bing$(echo $imgJson | grep -oP "url\":\"[^\"]*" | cut -d "\"" -f 3)
    imgName=${imgURL##*/}
    mkdir -p $path
    if ! (grep -q "JPEG image data" <<< $(file "$path$imgName")); then
       curl -s -o $path$imgName $imgURL
    fi
    if (grep -q "JPEG image data" <<< $(file "$path$imgName")); then
        current_bg=$(gsettings get org.gnome.desktop.background picture-uri)
        if [ "$current_bg" != "file://$path$imgName" ]; then
            gsettings set org.gnome.desktop.background picture-uri "file://$path$imgName"
            gsettings set org.gnome.desktop.background picture-options "zoom"
        fi
    fi
    sleep 10800
done
EOF

chmod a+x $HOME/.local/bin/bingwallpaper

# Creating Startup Link.
cat <<EOF > "$HOME/.config/autostart/bingwallpaper.desktop"
[Desktop Entry]
Name=Bing Wallpaper
Comment=Sets Bing Pic of the day as wallpaper.
Type=Application
Exec=$HOME/.local/bin/bingwallpaper
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true

EOF
chmod a+x "$HOME/.config/autostart/bingwallpaper.desktop"
echo "Running $HOME/.local/bin/bingwallpaper to update wallpaper now."
$HOME/.local/bin/bingwallpaper &



