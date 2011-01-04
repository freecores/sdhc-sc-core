# Recursive makefile for simulations

SIMS = grpCrc/unitCrc grpWishbone/unitWbSlave grpSd/unitSdCmd grpSd/unitSdCardModel grpStrobesClocks/unitTimeoutGenerator grpRs232/unitRs232Tx grpSd/unitSdData grpSd/unitSdClockMaster
SYSVSIMS = grpSd/unitSdVerificationTestbench
SYNS = grpCrc/unitCrc grpSd/unitSdCmd grpSd/unitSdTop grpSd/unitTbdSd grpSd/unitSdData

sim:
	for i in $(SIMS); do make -C src/$$i/sim; done

svsim: sim
	for i in $(SYSVSIMS); do make -C src/$$i/sim; done

syn:
	for i in $(SYNS); do make -C src/$$i/syn; done

clean:
	for i in $(SIMS); do make -C src/$$i/sim clean; done
	for i in $(SYNS); do make -C src/$$i/syn clean; done
