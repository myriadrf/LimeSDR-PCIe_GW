-- ----------------------------------------------------------------------------
-- FILE:          litepcie_pkg.vhd
-- DESCRIPTION:   Package for litepcie modules
-- DATE:          09:43 AM Thursday, June 27, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Package declaration
-- ----------------------------------------------------------------------------
package litepcie_pkg is
   
   constant c_DMA_DATA_WIDTH   : integer := 64;
   constant c_CNTRL_DATA_WIDTH : integer := 512;
   
   -- Outputs from the DMA Writer
   type t_FROM_DMA_WRITER is record
      valid    : std_logic;
      last     : std_logic;
      data     : std_logic_vector(c_DMA_DATA_WIDTH-1 downto 0);
      enable   : std_logic;
   end record t_FROM_DMA_WRITER;
   
   -- Inputs to the DAM writer
   type t_TO_DMA_WRITER is record
      ready    : std_logic;
   end record t_TO_DMA_WRITER;

   -- Outputs from DMA READER
   type t_FROM_DMA_READER is record
      ready    : std_logic;
      enable   : std_logic;
   end record t_FROM_DMA_READER;
   
   -- Inputs to the DMA reader
   type t_TO_DMA_READER is record
      valid    : std_logic;
      last     : std_logic;
      data     : std_logic_vector(c_DMA_DATA_WIDTH-1 downto 0);
   end record t_TO_DMA_READER;
      
end package litepcie_pkg;


