#!/bin/bash

archs=(
  "linux32"
  "linux64"
  "win32"
  "win64"
)

hosts=(
  ""
  ""
  "i686-w64-mingw32"
  "x86_64-w64-mingw32"
)

ccflags=(
  "-DCMAKE_CXX_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32"
  "-DCMAKE_CXX_FLAGS=-m64 -DCMAKE_C_FLAGS=-m64"
  "-DCMAKE_CXX_FLAGS=-static -DCMAKE_TOOLCHAIN_FILE=../XCompile.txt -DBUILD_SHARED_LIBS=ON"
  "-DCMAKE_CXX_FLAGS=-static -DCMAKE_TOOLCHAIN_FILE=../XCompile.txt -DBUILD_SHARED_LIBS=ON"
)

stripflags=(
  "--strip-unneeded"
  "--strip-unneeded"
  ""
  ""
)

output=(
  "libdiscord-rpc.a"
  "libdiscord-rpc.a"
  "libdiscord-rpc.dll"
  "libdiscord-rpc.dll"
)

for i in ${!archs[@]}; do
  mkdir -p "build_${archs[$i]}"
  (cd "build_${archs[$i]}" && cmake .. -DHOST=${hosts[$i]} ${ccflags[$i]} && make)
  prefix=`[ ! -z ${hosts[$i]} ] && echo ${hosts[$i]}-`
  ${prefix}strip ${stripflags[$i]} build_${archs[$i]}/src/${output[$i]}
done
