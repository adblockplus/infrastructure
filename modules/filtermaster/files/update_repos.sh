#!/bin/bash

cd /home/rsync/subscription/

for i in $(ls)
do
  hg pull -R $i -q --update
done

