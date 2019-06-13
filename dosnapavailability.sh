#!/bin/bash
# Created by Jeffery Grantham 06/05/2019
slug=(nyc1 nyc2 nyc3 sfo1 sfo2)

echo "Started making all snapshots available to all US regions.		$(date)"

for image in `doctl compute image list --format ID --no-header`
do doctl compute image get $image --format Name --no-header
for region in `shuf -e ${slug[@]}`
do doctl compute image-action transfer $image --region $region >/dev/null 2>&1
done
done

echo "Completed making all snapshots available to all US regions.		$(date)"
