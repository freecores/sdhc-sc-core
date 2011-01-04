# Recursive makefile for simulations

SIMS = grpCrc/unitCrc

sim:
	for i in $(SIMS); do make -C ../$$i/sim; done

clean:
	for i in $(SIMS); do make -C ../$$i/sim clean; done
