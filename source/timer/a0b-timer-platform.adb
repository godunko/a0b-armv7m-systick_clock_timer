--
--  Copyright (C) 2024, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with A0B.ARMv7M.CMSIS;                use A0B.ARMv7M.CMSIS;
with A0B.ARMv7M.System_Control_Block; use A0B.ARMv7M.System_Control_Block;

separate (A0B.Timer)
package body Platform is

   ----------------------------
   -- Enter_Critical_Section --
   ----------------------------

   procedure Enter_Critical_Section
     renames A0B.ARMv7M.CMSIS.Disable_Interrupts;

   ----------------------------
   -- Leave_Critical_Section --
   ----------------------------

   procedure Leave_Critical_Section
     renames A0B.ARMv7M.CMSIS.Enable_Interrupts;

   ------------------
   -- Request_Tick --
   ------------------

   procedure Request_Tick is
   begin
      --  Request SysTick exception. Do synchronization after modification of
      --  the register in the System Control Space to avoid side effects.

      SCB.ICSR := (PENDSVSET => True, others => <>);
      Data_Synchronization_Barrier;
      Instruction_Synchronization_Barrier;
   end Request_Tick;

   --------------
   -- Set_Next --
   --------------

   procedure Set_Next
     (Span    : A0B.Time.Time_Span;
      Success : out Boolean)
   is
      pragma Unreferenced (Span);
      --  SysTick timer has a fixed tick duration.

   begin
      Success := True;
   end Set_Next;

end Platform;
