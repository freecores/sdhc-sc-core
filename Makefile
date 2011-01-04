# Recursive makefile for simulations

SIMS = grpCrc/unitCrc grpStrobesClocks/unitTimeoutGenerator
SYSVSIMS = grpSd/unitSdVerificationTestbench
SYNS = grpSd/unitTbdSd 

sim:
	for i in $(SIMS); do make -C src/$$i/sim; done

svsim: sim
	for i in $(SYSVSIMS); do make -C src/$$i/sim; done

syn:
	for i in $(SYNS); do make -C src/$$i/syn; done

clean:
	for i in $(SIMS); do make -C src/$$i/sim clean; done
	for i in $(SYNS); do make -C src/$$i/syn clean; done
