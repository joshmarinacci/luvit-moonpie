CFLAGS="-DSTANDALONE -D__STDC_CONSTANT_MACROS -D__STDC_LIMIT_MACROS -DTARGET_POSIX -D_LINUX -fPIC -DPIC -D_REENTRANT -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -U_FORTIFY_SOURCE -Wall -g -DHAVE_LIBOPENMAX=2 -DOMX -DOMX_SKIP64BIT -ftree-vectorize -pipe -DUSE_EXTERNAL_OMX -DHAVE_LIBBCM_HOST -DUSE_EXTERNAL_LIBBCM_HOST -DUSE_VCHIQ_ARM -Wno-psabi"
INCLUDES="-I/opt/vc/include/ -I/opt/vc/include/interface/vcos/pthreads"
LDFLAGS="-L/opt/vc/lib/ -lGLESv2 -lEGL -lopenmaxil -lbcm_host -lvcos -lvchiq_arm -L../libs/ilclient -L../libs/vgfont"


echo "compiling the lib"
gcc -c -Wall -Werror -fpic $CFLAGS $INCLUDES joshpi.c

echo "linking into a shared library"
gcc -shared $LDFLAGS -o libjoshpi.so joshpi.o

echo "compiling and linking a test app"
gcc -L./ -Wall $INCLUDES -o joshpitest joshpitest.c -ljoshpi

LD_LIBRARY_PATH=/home/josh/luvit-moonpie/experiments/rpi:$LD_LIBRARY_PATH
echo "running the test app"
echo ""
./joshpitest
