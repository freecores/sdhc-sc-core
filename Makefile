# Recursive makefile for simulations

LIBS = libaltera_mf libcycloneii
SIMS = grpCrc/unitCrc grpStrobesClocks/unitTimeoutGenerator
SYSVSIMS = grpSd/unitSdVerificationTestbench
SYNS = grpSd/unitTbdSd 

all: clean libs sim svsim syn

libs:
	for i in $(LIBS); do make -C src/$$i/sim; done

sim: libs
	for i in $(SIMS); do make -C src/$$i/sim; done

svsim: libs sim
	for i in $(SYSVSIMS); do make -C src/$$i/sim; done

syn:
	for i in $(SYNS); do make -C src/$$i/syn; done

clean:
	for i in $(SIMS); do make -C src/$$i/sim clean; done
	for i in $(SYSVSIMS); do make -C src/$$i/sim clean; done
	for i in $(SYNS); do make -C src/$$i/syn clean; done
	for i in $(LIBS); do make -C src/$$i/sim clean; done

