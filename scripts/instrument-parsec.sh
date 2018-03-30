#!/bin/bash

usage="$(basename "$0")

This script runs all the pthread-PARSEC 3.0 benchmarks with the specified pin tool.

Options:
-h show this help text
-t number of threads (default 2)
-i input set (default test)
-r number of runs (default 1)
-o output directory
-f output file
-p pin tool
"
# defaults
<<<<<<< HEAD
benchmarks=(splash2x.ocean_ncp)
=======
benchmarks=(blackscholes)
>>>>>>> 2fed6c88ca30df8ae3fc20234944eaa708c5d085
threads=2
inputs=(test)
runs=1
output=$DATA_ROOT
file="output.txt"
parsecmgmt=$PARSEC_ROOT/bin/parsecmgmt
pin=$PIN_ROOT/pin.sh
pin_tool=""

while getopts "b:hi:r:t:o:p:f:" OPTION;
do
  case $OPTION in
    b)
      benchmarks=($OPTARG)
      ;;
    h)
      echo "$usage"
      exit 254
      ;;
    t)
      threads=$OPTARG
      ;;
    i)
      inputs=($OPTARG)
      ;;
    o)
      output=$OPTARG
      ;;
    p)
      pin_tool=$OPTARG
      ;;
    r)
      runs=$OPTARG
      ;;
    f)
      file=$OPTARG
      ;;
    *)
      echo "$usage"
      exit 254
      ;;
  esac
done

if [ "$benchmarks" == "all" ]
then
  benchmarks=(
  blackscholes
  bodytrack
  canneal
  #dedup
  facesim
  ferret
  #fluidanimate
  raytrace
  streamcluster
  swaptions
  #vips
  #splash2x.barnes
  splash2x.cholesky
  splash2x.fft
  #splash2x.fmm
  splash2x.ocean_cp
  splash2x.ocean_ncp
  #splash2x.radiosity
  #splash2x.raytrace
  splash2x.radix
  splash2x.volrend
  splash2x.water_nsquared
  splash2x.water_spatial
  )
elif [ "$benchmarks" == "parsec" ]
then
  benchmarks=(
  blackscholes
  bodytrack
  canneal
  #dedup
  facesim
  ferret
  #fluidanimate
  raytrace
  streamcluster
  swaptions
  vips
  )
elif [ "$benchmarks" == "splash2" ]
then
  benchmarks=(
  splash2x.fft
  splash2x.ocean_cp
  splash2x.radix
  splash2x.water_nsquared
  splash2x.water_spatial
  )
elif [ "$benchmarks" == "splash3" ]
then
  benchmarks=(
  splash2x.barnes
  splash2x.cholesky
  splash2x.fmm
  splash2x.ocean_ncp
  #splash2x.radiosity
  #splash2x.raytrace
  splash2x.volrend
  )
fi

if [ "$inputs" == "all" ]
then
  inputs=(
  simsmall
  simmedium
  simlarge
  native
  )
fi

mkdir -p $output

for run in `seq 1 $runs`;
do
  for input in "${inputs[@]}";
  do
    for benchmark in "${benchmarks[@]}";
    do
      # create directory
      output_dir=${output}/${input}/${threads}_threads/${benchmark}
      mkdir -p $output_dir

      # other runs may already exist and we don't want to overwrite them.
      # we assume everything is in sequential order.
      run_id=0
      for i in $(ls ${output_dir});
      do
        let run_id=$run_id+1
      done

      output_dir=$output_dir/$run_id
      mkdir -p $output_dir

      # track when the run started
      salt=`date +%Y%m%d_%H%M%S`
      echo ${salt} > ${output_dir}/salt.txt

      # output the system configuration and info
      lscpu > $output_dir/lscpu.txt

<<<<<<< HEAD
      pin_command="$pin -injection child -mt -t $pin_tool -numcaches $threads -instrAll 1 --"
=======
      pin_command="$pin -injection child -mt -t $pin_tool --"
>>>>>>> 2fed6c88ca30df8ae3fc20234944eaa708c5d085
      if [ "$pin_tool" == "none" ]
      then
        pin_command=""
      fi

      time_command="/usr/bin/time -f \"%e,%U,%S,%K,%M,%D,%F,%R,%W,%c,%w\" -o $output_dir/info.txt"

      # run benchmark
<<<<<<< HEAD
      # $parsecmgmt -a run -p $benchmark -i $input -n $threads -c gcc-pthreads \
      #  -s "$time_command $pin_command"
      $parsecmgmt -a run -p $benchmark -i $input -n $threads -c gcc-pthreads \
        -s "$pin_command"
=======
      $parsecmgmt -a run -p $benchmark -i $input -n $threads -c gcc-pthreads \
        -s "$time_command $pin_command"
>>>>>>> 2fed6c88ca30df8ae3fc20234944eaa708c5d085

      gzip $output_dir/$file

      # ensure unique salts
      sleep 1
    done
  done
done
