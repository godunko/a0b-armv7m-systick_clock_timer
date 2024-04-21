--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Implementation of the Monotonic Time Clock and Timer on top of SysTick.
--
--  This package exports SysTick_Handler symbol to install exception handler.

pragma Restrictions (No_Elaboration_Code);

with A0B.Time;
with A0B.Types;

package A0B.ARMv7M.SysTick is

   use type A0B.Types.Unsigned_32;

   procedure Initialize
     (Use_Processor_Clock : Boolean;
      Clock_Frequency     : A0B.Types.Unsigned_32)
      with Pre =>
        Clock_Frequency mod 1_000_000 = 0
          and Clock_Frequency <= 2**20 * 1_000;
   --  Initialize SysTick timer

   function Clock return A0B.Time.Monotonic_Time;
   --  Return current monotonic time

end A0B.ARMv7M.SysTick;