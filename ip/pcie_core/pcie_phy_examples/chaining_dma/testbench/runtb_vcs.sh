#!/bin/bash

QUARTUS_ROOTDIR='c:/intelfpga_lite/18.0/quartus'
PHY_TYPE_STRATIXVGX=0

[ -d lpm                ] || mkdir lpm
[ -d altera_mf          ] || mkdir altera_mf
[ -d sgate              ] || mkdir sgate
[ -d altgxb             ] || mkdir altgxb
[ -d stratixiigx_hssi   ] || mkdir stratixiigx_hssi
[ -d stratixiv_hssi     ] || mkdir stratixiv_hssi
[ -d stratixiv_pcie_hip ] || mkdir stratixiv_pcie_hip
[ -d altera             ] || mkdir altera
[ -d work               ] || mkdir work
if [ $PHY_TYPE_STRATIXVGX == 0 ]
then
   [ -d arriaii_hssi        ] || mkdir arriaii_hssi
   [ -d arriaii_pcie_hip    ] || mkdir arriaii_pcie_hip
   [ -d arriaiigz_hssi        ] || mkdir arriaiigz_hssi
   [ -d arriaiigz_pcie_hip    ] || mkdir arriaiigz_pcie_hip
   [ -d cycloneiv_hssi      ] || mkdir cycloneiv_hssi
   [ -d cycloneiv_pcie_hip  ] || mkdir cycloneiv_pcie_hip
fi

# Create VCS MX libraries
echo "--Tells VCS where the libraries are"       >  synopsys_sim.setup
echo "WORK > work"                               >> synopsys_sim.setup
echo "work : ./work"                             >> synopsys_sim.setup
echo "lpm : ./lpm"                               >> synopsys_sim.setup
echo "sgate  : ./sgate"                          >> synopsys_sim.setup
echo "altera : ./altera"                         >> synopsys_sim.setup
echo "altera_mf : ./altera_mf"                   >> synopsys_sim.setup
echo "stratixiigx_hssi : ./stratixiigx_hssi"     >> synopsys_sim.setup
echo "stratixiv_hssi : ./stratixiv_hssi"         >> synopsys_sim.setup
echo "stratixiv_pcie_hip : ./stratixiv_pcie_hip" >> synopsys_sim.setup

if [ $PHY_TYPE_STRATIXVGX == 0 ]
then
   echo "arriaii_hssi : ./arriaii_hssi"               >> synopsys_sim.setup
   echo "arriaii_pcie_hip : ./arriaii_pcie_hip"       >> synopsys_sim.setup
   echo "arriaiigz_hssi : ./arriaiigz_hssi"               >> synopsys_sim.setup
   echo "arriaiigz_pcie_hip : ./arriaiigz_pcie_hip"       >> synopsys_sim.setup
   echo "cycloneiv_hssi : ./cycloneiv_hssi"           >> synopsys_sim.setup
   echo "cycloneiv_pcie_hip : ./cycloneiv_pcie_hip"   >> synopsys_sim.setup
fi

echo "TIMEBASE = PS" >> synopsys_sim.setup

vhdlan -work lpm $QUARTUS_ROOTDIR/eda/sim_lib/220pack.vhd $QUARTUS_ROOTDIR/eda/sim_lib/220model.vhd
vhdlan -work altera_mf $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.vhd
vhdlan -work sgate $QUARTUS_ROOTDIR/eda/sim_lib/sgate_pack.vhd $QUARTUS_ROOTDIR/eda/sim_lib/sgate.vhd
vhdlan -work stratixiigx_hssi stratixiigx_hssi_components.vhd stratixiigx_hssi_atoms.vhd
vhdlan -work stratixiv_hssi $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_hssi_atoms.vhd
vhdlan -work stratixiv_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_pcie_hip_atoms.vhd

if [ $PHY_TYPE_STRATIXVGX == 0 ]
then
   vhdlan -work arriaii_hssi $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_hssi_atoms.vhd
   vhdlan -work arriaii_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_pcie_hip_atoms.vhd
   vhdlan -work arriaiigz_hssi $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_hssi_atoms.vhd
   vhdlan -work arriaiigz_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_pcie_hip_atoms.vhd
   vhdlan -work cycloneiv_hssi $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_hssi_atoms.vhd
   vhdlan -work cycloneiv_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_pcie_hip_atoms.vhd
fi


# Verilog co-simulation
if [ $PHY_TYPE_STRATIXVGX == 1 ]
then
   cat sim_filelist_verilog_cosim |grep "\.v" | sed "s/^/-n /"                       >  sim_filelist_verilog_cosim_v2k.f
   echo "-n $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_pcie_hip_atoms.v"                  >> sim_filelist_verilog_cosim_v2k.f
   echo "-n $QUARTUS_ROOTDIR/eda/sim_lib/synopsys/stratixv_pcie_hip_atoms_ncrypt.v"  >> sim_filelist_verilog_cosim_v2k.f
   vlogan +define+ALTPCIETB_COSIM_MENTOR -work work +v2k -f sim_filelist_verilog_cosim_v2k.f

   cat sim_filelist_verilog_cosim |grep "\.sv" | sed "s/^/-n /"                 > sim_filelist_verilog_cosim_sv.f
   echo "-n $QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv"                       >> sim_filelist_verilog_cosim_sv.f
   echo "-n $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_hssi_atoms.v"                 >> sim_filelist_verilog_cosim_sv.f
   echo "-n $QUARTUS_ROOTDIR/eda/sim_lib/synopsys/stratixv_hssi_atoms_ncrypt.v" >> sim_filelist_verilog_cosim_sv.f
   vlogan -work work -sverilog -f sim_filelist_verilog_cosim_sv.f

   # Updating the component declaration for co-simulation of <variant>_core.vhd instantiating altpcie_hip_256_pipen1b
   VAR_CORE='../../../pcie_phy_core.vhd'
   if [ -f $VAR_CORE ] && [ `cat $VAR_CORE | grep -c altpcie_hip_256_pipen1b_component_declaration` == 0 ]
   then
      echo "Updating $VAR_CORE component declaration"
      CMP_VHDL='../../common/testbench/altpcie_hip_256_pipen1b_cmp.vhd'
      UNIQUE_STR='_______altrarrrrrrrrrrrrrrrrrrrrrraltr________'
      TFILE='tmp.txt'
      TFILE2='tmp2.txt'
      cat $VAR_CORE|sed "s/\t/   /g"|sed "s/ /$UNIQUE_STR/g">$TFILE
      INCOMPLETE_VHDL_COMPONENT_SECTION=0;
      echo ''>$TFILE2
      for line in `cat $TFILE`
      do
         line2=`echo $line|sed "s/$UNIQUE_STR/ /g"`
         if [ `echo $line2|grep -c COMPONENT` == 1 ]
         then
            INCOMPLETE_VHDL_COMPONENT_SECTION=1
         fi
         if [ $INCOMPLETE_VHDL_COMPONENT_SECTION == 0 ]
         then
            echo $line2 >> $TFILE2
         fi
         if [ `echo $line2|grep -c "END COMPONENT"` == 1 ]
         then
            echo " " >> $TFILE2
            echo " " >> $TFILE2
            cat $CMP_VHDL >> $TFILE2
            echo " " >> $TFILE2
            echo " " >> $TFILE2
            INCOMPLETE_VHDL_COMPONENT_SECTION=0
         fi
      done
      mv $TFILE2 $VAR_CORE
      [ -f $TFILE  ] && rm -f $TFILE
   fi
fi

vhdlan -work altera $QUARTUS_ROOTDIR/libraries/vhdl/altera/altera_europa_support_lib.vhd
vhdlan -list -work work -f sim_filelist

# run simulation
vcs -R pcie_phy_chaining_testbench -l transcript

cat transcript

