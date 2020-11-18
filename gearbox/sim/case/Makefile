#===============================================================
#VARIABLES INITIALATION
#===============================================================

#case name 
case =

#waveform dump on
dumpon =
 
#random seed
seed =

#code coverage
cov =

#===============================================================
#VCS ARGUMENTS DEFINITION
#===============================================================
#should not be changed!#

#case name without postfix(.v)
CASE_NAME = $(case)

#DUV RTL file list
DUV_RTL_LIST = -f ${PRJ_PATH}/duv/list/rtl.list

#DUV others file list, such as memory model
DUV_OTHER_LIST =

#BENCH file list
TB_LIST = -f ${PRJ_PATH}/sim/list/bench.list

#Waveform dump switch
ifdef dumpon
  DUMP_ARG = +define+DUMPON \
             +define+FSDB_NAME=\"$(CASE_NAME).fsdb\" \
             -P ${VERDI_TAB} ${VERDI_PLI}
else
  DUMP_ARG =
endif

#whether and when to start the waveform dump
ifdef dumpon
  DUMPON_ARG = +dumpon=$(DUMPON)
else
  DUMPON_ARG =
endif

ifdef seed
  SEED_ARG = +ntb_random_seed=$(SEED)
else
  SEED_ARG = +ntb_random_seed_automatic
endif

#code coverage
ifdef cov
  COV_ARG = -cm line+cond+tgl+fsm+branch \
            -cm_dir ./coverage/$(CASE_NAME).vdb 
else
  COV_ARG =
endif

#VCS compilation arguments
VCS_COMP_ARG = -full64 \
               -debug \
               +cli+3 \
               +v2k \
               -sverilog \
               -timescale=1ns/1ns \
               +notimingchecks \
               +nospecify \
               $(DUMP_ARG) \
               $(TB_LIST) \
               $(DUV_RTL_LIST) \
               $(DUV_OTHER_LIST) \
               -l $(CASE_NAME)_comp.log \
               $(COV_ARG) \
               -o $(CASE_NAME).simv 

#=====================================================================
#MAKEFILE ARGUMENTS DEFINATION 
#=====================================================================
#should not be changed#

#excute the whole flow
all:clean comp run
cleanall: cleanfsdb

#clean the generate file except fsdb file
clean:
	\rm -rf *verdiLog* *FSDB* *simv* csrc* *.log *.dat ucli.key vcs.key *.conf *.Log *.rc *nWaveLog*

#clean the fsdb file
cleanfsdb:
	\rm -rf *.fsdb

#VCS compile
comp:
	vcs $(VCS_COMP_ARG) $(CASE_NAME).v
#VCS run simulation
run:
	./$(CASE_NAME).simv \
	-l $(CASE_NAME)_run.log \
	-ucli -i ${VCS_UCLI} \
	$(COV_ARG) \
	$(SEED_ARG) \
	$(DUMPON_ARG)
 
#view the coverage report
urg:
	cd coverage; \
	urg -full64 -dir *.vdb; \
	cd urgReport; \
	firefox hierarchy.html

#use verdi to view the code
code:
	verdi -nologo -sverilog \
	$(TB_LIST) $(DUV_OTHER_LIST) $(DUV_RTL_LIST) $(CASE_NAME).v &

#use nWave to view the waveform
wave:
	nWave -ssf *.fsdb &
.PHONE:clean



