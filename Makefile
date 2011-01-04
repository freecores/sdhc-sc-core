# Recursive makefile for simulations

SIMS = grpCrc/unitCrc grpWishbone/unitWbSlave grpSd/unitSdCmd grpSd/unitSdCardModel
SYNS = grpCrc/unitCrc grpSd/unitSdCmd

sim:
	for i in $(SIMS); do make -C src/$$i/sim; done

syn:
	for i in $(SYNS); do make -C src/$$i/syn; done

clean:
	for i in $(SIMS); do make -C src/$$i/sim clean; done
	for i in $(SYNS); do make -C src/$$i/syn clean; done
