--
--  Copyright (C) 2024, Vadim Godunko
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with A0B.ARMv7M.Instructions;
with A0B.ARMv7M.SCS.SCB;

separate (A0B.Timer)
package body Platform is

   ----------------------------
   -- Enter_Critical_Section --
   ----------------------------

   procedure Enter_Critical_Section
     renames A0B.ARMv7M.Instructions.Disable_Interrupts;

   ----------------------------
   -- Leave_Critical_Section --
   ----------------------------

   procedure Leave_Critical_Section
     renames A0B.ARMv7M.Instructions.Enable_Interrupts;

   ------------------
   -- Request_Tick --
   ------------------

   procedure Request_Tick is
   begin
      --  Request SysTick exception. Do synchronization after modification of
      --  the register in the System Control Space to avoid side effects.

      A0B.ARMv7M.SCS.SCB.ICSR := (PENDSVSET => True, others => <>);
      A0B.ARMv7M.Instructions.Data_Synchronization_Barrier;
      A0B.ARMv7M.Instructions.Instruction_Synchronization_Barrier;
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
