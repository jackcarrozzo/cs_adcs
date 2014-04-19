PROJ=cs_adcs
TOPBLOCK=cs_adcs
QUBIN=/usr/local/altera/12.1sp1_243/quartus/linux64
ALTERALIBS=/usr/local/altera/12.1sp1_243/quartus/linux64

all: synth fit assemble netlist

synth:
	LD_LIBRARY_PATH=$(ALTERALIBS) $(QUBIN)/quartus_map --read_settings_files=on --write_settings_files=off $(PROJ) -c $(TOPBLOCK)

fit:
	LD_LIBRARY_PATH=$(ALTERALIBS) $(QUBIN)/quartus_fit --read_settings_files=off --write_settings_files=off $(PROJ) -c $(TOPBLOCK)

assemble:
	LD_LIBRARY_PATH=$(ALTERALIBS) $(QUBIN)/quartus_asm --read_settings_files=off --write_settings_files=off $(PROJ) -c $(TOPBLOCK)

timing:
	LD_LIBRARY_PATH=$(ALTERALIBS) $(QUBIN)/quartus_sta $(PROJ) -c $(TOPBLOCK)

netlist:
	LD_LIBRARY_PATH=$(ALTERALIBS) $(QUBIN)/quartus_eda --read_settings_files=off --write_settings_files=off $(PROJ) -c $(TOPBLOCK)

prog:
	LD_LIBRARY_PATH=$(ALTERALIBS) $(QUBIN)/quartus_pgm --no_banner -c 1 -m JTAG -o 'P;output_files/$(TOPBLOCK).sof'

jtagconfig:
	LD_LIBRARY_PATH=$(ALTERALIBS) $(QUBIN)/jtagconfig

clean:
	rm -fr db incremental_db output_files greybox_tmp simulation

