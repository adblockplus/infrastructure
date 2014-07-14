#!/bin/bash

cd /home/rsync/subscription/

for i in $(ls)
do
  hg pull -R $i -q
  hg update -R $i -q -r default --check
done

