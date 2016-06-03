qexec "quartus_cpf -c output_files/jic_gen_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-PCIE_lms7_trx.jic" -submsgs [list "Ouput file saved in /output_files directory"]
post_message "*******************************************************************"
qexec "quartus_cpf -c output_files/rbf_gen_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-PCIE_lms7_trx.rbf" -submsgs [list "Ouput file saved in /output_files directory"]
post_message "*******************************************************************"
