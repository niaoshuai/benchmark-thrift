#!/bin/bash

if [ -f /etc/profile ]; then
    . /etc/profile
fi

if [ -f ~/.bash_profile ]; then
    . ~/.bash_profile
fi

function get_versions(){
  for element in `ls thrift`
  do
    if [[ -d thrift/$element ]]; then
      versions=$element","$versions
    fi
  done
  versions=${versions%,*}
}

function start(){
  BASE_DIR=$(cd $(dirname $0); pwd)
  CLASSPATH=$BASE_DIR/conf:$BASE_DIR/lib/*:$BASE_DIR/thrift/$version/*
  BIN_DIR=$(cd $(dirname $0); pwd)
  JAVA_OPTS="-server -Xmx16G -Xms16G -XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+ParallelRefProcEnabled -XX:ErrorFile=$BIN_DIR/hs_err_pid%p.log -Xloggc:$BIN_DIR/gc.log -XX:HeapDumpPath=$BIN_DIR -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+HeapDumpOnOutOfMemoryError"
  PID_FILE="$BIN_DIR/pid"
  if [ ! -s "$PID_FILE" ] || [[ "" == $(cat $PID_FILE) ]] || [ -z "$(ps -eo pid | grep -w $(cat $PID_FILE))" ]; then
    java $JAVA_OPTS -cp $CLASSPATH com.didiglobal.pressir.thrift.Main $* 2>&1
    echo $! > $PID_FILE
  else
    echo "error: application can not start duplicate! running pid=$(cat $PID_FILE)"
    exit 1
  fi
}

function validate(){
  # 获取工具支持的所有thrift version
  get_versions

  # 指定版本是否合规
  . $protocol >/dev/null 2>&1
  if [[ ${version} == "" ]]; then
    echo "${shell}: thrift version must be specified in thrift conf file"
    exit 1
  fi
  if [[ ${versions} != *$version* ]]; then
    echo "${shell}: the tool does not support the thrift version you specified yet. tool support "$versions""
    exit 1
  fi

  # 是否指定jar包
  if [[ $classpath == "" || $classpath != *.jar ]]; then
    echo "${shell}: jar information must be specified in thrift conf file"
    exit 1
  fi
}

function print_usage(){
  printf "\
Usage: ./${shell}.sh [options] thrift://<host>:<port>/<service>/<method>[?@<data_file>]

Options:
   -c <concurrency>       Number of multiple requests to make at a time
                          If no -c nor -q is specified, default value is 1 concurrency
   -q <throughput>        Number of requests issued in 1 Second
                          If no -c nor -q is specified, default value is 1 concurrency
   -t <timelimit>         how long the benchmark runs, 2 or 2s means 10 seconds, 2m for 2 minutes, 2h for 2 hours
                          If not specified, default value is 60 seconds
   -e <environment file>  Thrift environment configuration file, containing thrift version, protocol and transport etc.
                          If not specified, default value is conf/thrift.conf
   -h                     Display usage information (this message) and exit
   -v                     Print version number and exit

Where:
   <data_file>            A local file that contains request arguments, prefixed by a "@".
                          If the thrift method has parameters, <data_file> is mandatory.

Examples:
    # Benchmark a non-args thrift method
    ./bt.sh thrift://127.0.0.1:8090/service/method
    # Benchmark a non-args thrift method at 10 QPS for 5 minutes
    ./bt.sh -q 10 -D 5m thrift://127.0.0.1:8090/service/method
"
}

# 设置默认值
name="BenchmarkThrift"
shell="benchmark"
version="0.0.1"
params=""
types=0

while getopts ":n:c:D:q:p:d:hv" opt
do
  case "$opt" in
    c)
      concurrency="$OPTARG"
      types=$[types+1]
      params="-c $concurrency $params "
      ;;
    t)
      timelimit="$OPTARG"
      params="-D $timelimit $params "
      ;;
    q)
      throughput="$OPTARG"
      types=$[types+1]
      params="-q $throughput $params "
      ;;
    e)
      protocol="$OPTARG"
      params="-p $protocol $params "
      validate
      ;;
    d)
      param="$OPTARG"
      params="-d $param $params "
      ;;
    h)
      print_usage
      exit 1
      ;;
    v)
      printf "This is ${name}, version ${version}\n"
      exit 1
      ;;
    *)
      echo "${shell}: illegal option ${OPTARG}"
      print_usage
      exit 1
      ;;
    esac
done
if [[ ${types} == 2 ]];  then
  echo "${shell}: only one of -c or -q could be specified"
  print_usage
  exit 1
fi

if [[ ${protocol} == "" ]]; then
  echo "${shell}: thrift conf file was not specified by -p, the thrift.conf in the path(conf/) was used"
  print_usage
  exit 1
fi

if [[ ${timelimit} == "" ]]; then
  params="$params -D 60s"
fi

if [ $types == 0 ]; then
  params="$params -c 1"
fi

shift $(($OPTIND - 1))
if [[ $1 == "" ]];  then
  echo "${shell}: please enter thrift url"
  print_usage
  exit 1
fi
params="$params -u $1"

start $params
