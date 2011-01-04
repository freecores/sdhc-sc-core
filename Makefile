# Recursive makefile for simulations

SIMS = grpCrc/unitCrc

sim:
	for i in $(SIMS); do make -C src/$$i/sim; done

clean:
	for i in $(SIMS); do make -C src/$$i/sim clean; done
