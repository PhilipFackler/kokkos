KOKKOS_PATH = ../..

# See $(KOKKOS_PATH)/Makefile.kokkos and $(KOKKOS_PATH)/generate_makefile.bash
KOKKOS_ARCH_OPTIONS="AMDAVX ARMv80 ARMv81 ARMv8-ThunderX Power7 Power8 Power9 \
	 WSM SNB HSW BDW SKX KNC KNL Kepler30 Kepler32 Kepler35 Kepler37 Maxwell50 \
	 Maxwell52 Maxwell53 Pascal60 Pascal61"

KOKKOS_DEVICE_OPTIONS="Cuda ROCm OpenMP Pthread Serial Qthreads"

# Configure paths to enable environment query in Makefile.kokkos to work
ROCM_HCC_PATH="config"
CXX="./config/cxx"
ipath="env CXX=$(CXX) env PATH=./config:$$PATH env ROCM_HCC_PATH=$(ROCM_HCC_PATH)"

# Defined in core/src/Makefile -- this should be consistent
gen_makefile=Makefile.kokkos
gen_cmakefile=kokkos.cmake

# Defined in Makefile.kokkos -- this should be consistent
gen_config=KokkosCore_config.tmp
gen_header=KokkosCore_config.h

# diff => 0 is no difference.  if => 0 is false
testbuild=if diff config/tmpstore/$1 config/results/$1; then echo OK $1; else echo not OK $1; fi
# Add grep so check value
testheadr=if test `diff config/tmpstore/$1 config/results/$1 | grep define` !=''; then echo OK $1; else echo not OK $1; fi

# testing tmp and cmakefile files is unnecessary
test:
	@for karch in "$(KOKKOS_ARCH_OPTIONS)"; do \
	  for device in "$(KOKKOS_DEVICE_OPTIONS)"; do \
         kkenv="env KOKKOS_ARCH=$$karch env KOKKOS_DEVICES=$$device"; \
	     "$(ipath)" "$$kkenv" make -e -f ../src/Makefile build-makefile-cmake-kokkos; \
		 prfx="$$karch"_"$$device"_; \
		 mv $(gen_makefile)  config/tmpstore/"$$prfx"$(gen_makefile);  \
		 mv $(gen_header) config/tmpstore/"$$prfx"$(gen_header); \
		 rm -f $(gen_config) $(gen_cmakefile); \
		 $(call testbuild,"$$prfx"$(gen_makefile)); \
		 $(call testheadr,"$$prfx"$(gen_header)); \
	  done; \
	done
