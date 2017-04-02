#!/bin/sh
set -x

while true; do
    TIMESTAMP="$(date -u +"%Y-%m-%d_%H:%M:%S")"
    wget https://www.reddit.com/api/place/board-bitmap -O board-bitmap
    python board2png.py board-bitmap board-bitmap.png
    cp board-bitmap.png archive/board-bitmap-"$TIMESTAMP".png
    convert -crop 80x82+105+809 board-bitmap.png now.png
    convert -filter Point -resize 400%x now.png now_4x.png
    convert -filter Point -resize 400%x ref.png place_ref.png
    convert -filter Point -resize 800%x ref.png place_ref_8x_nogrid.png
    convert place_ref_8x_nogrid.png grid8x.png -composite touhou_place_ref_8x.png

    composite now_4x.png place_ref.png -compose difference diff_4x.png
    convert -brightness-contrast 70x70 diff_4x.png diff_4x_contrast.png

    convert diff_4x.png rgb:diff_4x.raw

    if cmp diff_4x.raw nodiff.raw; then
        echo "WIN $TIMESTAMP" >> win.txt
        mkdir win/"$TIMESTAMP"
        cp *.png *.gif win/"$TIMESTAMP"
    fi

    montage -geometry 320x328 -label "REFERENCE" place_ref.png ref_labeled.png
    montage -geometry 320x328 -label "$TIMESTAMP UTC" now_4x.png now_labeled.png
    montage -geometry 320x328 -label "DIFFERENCE" diff_4x_contrast.png diff_labeled.png

    convert -delay 100 ref_labeled.png now_labeled.png diff_labeled.png place_now_vs_ref.gif
    convert -delay 100 orig_labeled.png ref_labeled.png place_ref_vs_orig.gif

    echo CONVERTED

	# upload to webserver here...

    echo DONE
    sleep 30
done
