fifo_8b_inst : fifo_8b PORT MAP (
		aclr	 => aclr_sig,
		data	 => data_sig,
		rdclk	 => rdclk_sig,
		rdreq	 => rdreq_sig,
		wrclk	 => wrclk_sig,
		wrreq	 => wrreq_sig,
		q	 => q_sig,
		rdempty	 => rdempty_sig,
		wrfull	 => wrfull_sig
	);
