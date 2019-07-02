#!/bin/bash

QUARTUS_ROOTDIR='c:/intelfpga_lite/18.0/quartus'
PHY_TYPE_STRATIXVGX=0

[ -d lpm                ] || mkdir lpm
[ -d altera_mf          ] || mkdir altera_mf
[ -d sgate              ] || mkdir sgate
[ -d stratixiigx_hssi   ] || mkdir stratixiigx_hssi
[ -d stratixiv_hssi     ] || mkdir stratixiv_hssi
[ -d stratixiv_pcie_hip ] || mkdir stratixiv_pcie_hip
[ -d altera             ] || mkdir altera
[ -d work          ] || mkdir work
if [ $PHY_TYPE_STRATIXVGX == 0 ]
then
   [ -d arriaii_hssi        ] || mkdir arriaii_hssi
   [ -d arriaii_pcie_hip    ] || mkdir arriaii_pcie_hip
   [ -d arriaiigz_hssi        ] || mkdir arriaiigz_hssi
   [ -d arriaiigz_pcie_hip    ] || mkdir arriaiigz_pcie_hip
   [ -d cycloneiv_hssi      ] || mkdir cycloneiv_hssi
   [ -d cycloneiv_pcie_hip  ] || mkdir cycloneiv_pcie_hip
fi

echo "SOFTINCLUDE $CDS_ROOT/tools/inca/files/cds.lib"       > cds.lib
echo "DEFINE lpm ./lpm"                                     >> cds.lib
echo "DEFINE altera_mf ./altera_mf"                         >> cds.lib
echo "DEFINE sgate ./sgate"                                 >> cds.lib
echo "DEFINE stratixiigx_hssi ./stratixiigx_hssi"           >> cds.lib
echo "DEFINE stratixiv_hssi ./stratixiv_hssi"               >> cds.lib
echo "DEFINE stratixiv_pcie_hip ./stratixiv_pcie_hip"       >> cds.lib
if [ $PHY_TYPE_STRATIXVGX == 0 ]
then
   echo "DEFINE arriaii_hssi ./arriaii_hssi"                >> cds.lib
   echo "DEFINE arriaii_pcie_hip ./arriaii_pcie_hip"        >> cds.lib
   echo "DEFINE arriaiigz_pcie_hip ./arriaiigz_pcie_hip"        >> cds.lib
   echo "DEFINE arriaiigz_hssi ./arriaiigz_hssi"                >> cds.lib
   echo "DEFINE cycloneiv_hssi ./cycloneiv_hssi"            >> cds.lib
   echo "DEFINE cycloneiv_pcie_hip ./cycloneiv_pcie_hip"    >> cds.lib
fi
echo "DEFINE work ./work"                         >> cds.lib
echo "DEFINE altera ./altera"                               >> cds.lib
echo "SOFTINCLUDE $CDS_ROOT/tools/inca/files/hdl.var"       > hdl.var

echo "set pack_assert_off {std_logic_arith numeric_std}" >  runtb_nc.do
echo "run"                                               >> runtb_nc.do

ncvhdl -v93 -relax -work lpm $QUARTUS_ROOTDIR/eda/sim_lib/220pack.vhd $QUARTUS_ROOTDIR/eda/sim_lib/220model.vhd
ncvhdl -v93 -relax -work altera_mf $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.vhd
ncvhdl -v93 -relax -work sgate $QUARTUS_ROOTDIR/eda/sim_lib/sgate_pack.vhd $QUARTUS_ROOTDIR/eda/sim_lib/sgate.vhd
ncvhdl -v93 -relax -work stratixiigx_hssi_components.vhd stratixiigx_hssi_atoms.vhd
ncvhdl -v93 -relax -work stratixiv_hssi $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_hssi_atoms.vhd
ncvhdl -v93 -relax -work stratixiv_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/stratixiv_pcie_hip_atoms.vhd

if [ $PHY_TYPE_STRATIXVGX == 0 ]
then
   ncvhdl -v93 -relax -work arriaii_hssi $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_hssi_atoms.vhd
   ncvhdl -v93 -relax -work arriaii_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaii_pcie_hip_atoms.vhd
   ncvhdl -v93 -relax -work arriaiigz_hssi $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_hssi_atoms.vhd
   ncvhdl -v93 -relax -work arriaiigz_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/arriaiigz_pcie_hip_atoms.vhd
   ncvhdl -v93 -relax -work cycloneiv_hssi $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_hssi_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_hssi_atoms.vhd
   ncvhdl -v93 -relax -work cycloneiv_pcie_hip $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_pcie_hip_components.vhd $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_pcie_hip_atoms.vhd
fi

# Verilog co-simulation
if [ $PHY_TYPE_STRATIXVGX == 1 ]
then
   cat sim_filelist_verilog_cosim |grep "\.v"                                     >  sim_filelist_verilog_cosim_v2k.f
   echo "$QUARTUS_ROOTDIR/eda/sim_lib/stratixv_pcie_hip_atoms.v"                  >> sim_filelist_verilog_cosim_v2k.f
   echo "$QUARTUS_ROOTDIR/eda/sim_lib/cadence/stratixv_pcie_hip_atoms_ncrypt.v"   >> sim_filelist_verilog_cosim_v2k.f
   ncvlog +define+ALTPCIETB_COSIM_MENTOR -work work -f sim_filelist_verilog_cosim_v2k.f

   cat sim_filelist_verilog_cosim |grep "\.sv"                                   >  sim_filelist_verilog_cosim_sv.f
   echo "$QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv"                           >> sim_filelist_verilog_cosim_sv.f
   echo "$QUARTUS_ROOTDIR/eda/sim_lib/stratixv_hssi_atoms.v"                     >> sim_filelist_verilog_cosim_sv.f
   echo "$QUARTUS_ROOTDIR/eda/sim_lib/cadence/stratixv_hssi_atoms_ncrypt.v"      >> sim_filelist_verilog_cosim_sv.f
   ncvlog -work work -SV -f sim_filelist_verilog_cosim_sv.f

   # Updating the component declaration for co-simulation of _core.vhd instantiating altpcie_hip_256_pipen1b
   VAR_CORE='../../../pcie_phy_core.vhd'
   if [ -f $VAR_CORE ] && [ `cat $VAR_CORE | grep -c altpcie_hip_256_pipen1b_component_declaration` == 0 ]
   then
      echo "Updating $VAR_CORE component declaration"
      CMP_VHDL='../../common/testbench/altpcie_hip_256_pipen1b_cmp.vhd'
      UNIQUE_STR='_______altrarrrrrrrrrrrrrrrrrrrrrraltr________'
      TFILE='tmp.txt'
      TFILE2='tmp2.txt'
      cat $VAR_CORE|sed "s/\t/    /g"|sed "s/ /$UNIQUE_STR/g">$TFILE
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
ncvhdl -v93 -relax -work altera $QUARTUS_ROOTDIR/libraries/vhdl/altera/altera_europa_support_lib.vhd
ncvhdl -v93 -relax -work work -nowarn UNXPCL -f sim_filelist

# run simulation
ncelab -ACCESS +r pcie_phy_chaining_testbench
ncsim -input runtb_nc.do pcie_phy_chaining_testbench -LOGFILE transcript

