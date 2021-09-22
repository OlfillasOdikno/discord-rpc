#!/bin/bash

for i in "$@"; do
  case $i in
    --linux* | --win*) arch=${i#--};;
    --docker-image) docker=true; image=true ci=false;;
    --docker) docker=true; image=false ci=false;;
    --ci) docker=true; image=false ci=true;;
  esac
done

archs=(
  "linux32"
  "linux64"
  "win32"
  "win64"
  "linuxarmhf"
)

hosts=(
  ""
  ""
  "i686-w64-mingw32"
  "x86_64-w64-mingw32"
  "arm-linux-gnueabihf"
)

ccflags=(
  "-DCMAKE_CXX_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32"
  "-DCMAKE_CXX_FLAGS=-m64 -DCMAKE_C_FLAGS=-m64"
  "-DCMAKE_CXX_FLAGS=-static -DCMAKE_TOOLCHAIN_FILE=../XCompile.txt -DBUILD_SHARED_LIBS=ON"
  "-DCMAKE_CXX_FLAGS=-static -DCMAKE_TOOLCHAIN_FILE=../XCompile.txt -DBUILD_SHARED_LIBS=ON"
  "-DCMAKE_PREFIX_PATH=\"/usr/lib/arm-linux-gnueabihf/\" -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++"
)

stripflags=(
  "--strip-unneeded"
  "--strip-unneeded"
  ""
  ""
  "--strip-unneeded"
)

output=(
  "libdiscord-rpc.a"
  "libdiscord-rpc.a"
  "libdiscord-rpc.dll"
  "libdiscord-rpc.dll"
  "libdiscord-rpc.a"
)

if [ "$docker" = true ]; then
  if [ "$image" = true ]; then
    for i in ${!archs[@]}; do
      if [ ! -z ${arch} ] && [ ! ${archs[$i]} = ${arch} ]; then
        continue
      fi
      docker build -t discord-rpc-builder:${archs[$i]} - < docker/${archs[$i]}.Dockerfile
    done
  else
    for i in ${!archs[@]}; do
      if [ ! -z ${arch} ] && [ ! ${archs[$i]} = ${arch} ]; then
        continue
      fi
      if [ "$ci" = true ]; then
        docker run --rm -tv jenkins_home:/var/jenkins_home -w "$(pwd)" discord-rpc-builder:${archs[$i]} ./build.sh "--${archs[$i]}"
      else
        docker run --rm -tv "$(pwd)":/work -w /work discord-rpc-builder:${archs[$i]} ./build.sh "--${archs[$i]}"
      fi
    done
  fi
  exit
fi

for i in ${!archs[@]}; do
  if [ ! -z ${arch} ] && [ ! ${archs[$i]} = ${arch} ]; then
    continue
  fi
  
  mkdir -p "build_${archs[$i]}"
  (cd "build_${archs[$i]}" && cmake .. -DHOST=${hosts[$i]} ${ccflags[$i]} && make)
  prefix=`[ ! -z ${hosts[$i]} ] && echo ${hosts[$i]}-`
  ${prefix}strip ${stripflags[$i]} build_${archs[$i]}/src/${output[$i]}
done
