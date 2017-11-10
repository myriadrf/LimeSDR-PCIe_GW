#Copy and Rename .sof file by hardware version 
file copy -force -- output_files/LimeSDR-PCIE_lms7_trx.sof output_files/LimeSDR-PCIE_lms7_trx_HW_1.2.sof
qexec "quartus_cpf -c output_files/jic_gen_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-PCIE_lms7_trx_HW_1.2.jic" -submsgs [list "Ouput file saved in /output_files directory"]
post_message "*******************************************************************"
qexec "quartus_cpf -c output_files/rbf_gen_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-PCIE_lms7_trx_HW_1.2.rbf" -submsgs [list "Ouput file saved in /output_files directory"]
post_message "*******************************************************************"
